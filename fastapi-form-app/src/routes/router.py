from fastapi import (
    APIRouter,
    UploadFile,
    WebSocket,
    File,
    HTTPException,
    BackgroundTasks,
)
import shutil
import uuid
import os
from core.log import log_info
from core.lang4 import to_fill
from core.matrix import matrix
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
from typing import Dict
import asyncio
from core.exceptions import MatrixError


router = APIRouter()
templates = Jinja2Templates(directory="src/templates")

# Store active connections and processing status
active_connections: Dict[str, WebSocket] = {}
processing_status: Dict[str, Dict] = {}


class ProcessRequest(BaseModel):
    file_id: str
    action: str  # "convert" or "script"


@router.get("/", response_class=HTMLResponse)
async def base():
    return FileResponse("templates/static/index.html")


@router.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    # Validate file extension
    if not file.filename.endswith(".jsp"):
        raise HTTPException(status_code=400, detail="Only .jsp files are allowed")

    # Generate unique ID for this upload
    file_id = str(uuid.uuid4())
    file_location = f"uploads/{file_id}_{file.filename}"

    # Save the file
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    log_info(f"File uploaded: {file.filename} as {file_location}")

    return {"file_id": file_id, "filename": file.filename, "location": file_location}


@router.post("/process/")
async def process_file(request: ProcessRequest, background_tasks: BackgroundTasks):
    file_id = request.file_id
    action = request.action

    try:
        # Find the uploaded file
        uploaded_files = [
            f for f in os.listdir("uploads") if f.startswith(f"{file_id}_")
        ]
        if not uploaded_files:
            raise HTTPException(status_code=404, detail="Uploaded file not found")

        file_path = f"uploads/{uploaded_files[0]}"
        original_filename = uploaded_files[0].replace(f"{file_id}_", "")

        # Initialize processing status
        processing_status[file_id] = {
            "status": "processing",
            "progress": 0,
            "message": f"Starting {action} operation...",
            "output_file": None,
        }

        # Process the file based on the selected action
        if action == "convert":
            # Start processing in background
            background_tasks.add_task(
                to_fill_the_lang4, file_id, file_path, original_filename
            )
        elif action == "script":
            # Start processing in background
            background_tasks.add_task(
                make_script_matrix, file_id, file_path, original_filename
            )
        else:
            raise HTTPException(status_code=400, detail="Invalid action")

        return {"file_id": file_id, "status": "processing"}
    except MatrixError as me:
        processing_status[file_id].update(
            {
                "status": "warming",
                "progress": 100,
                "message": me.message,
                "error_code": me.error_code,
            }
        )


async def to_fill_the_lang4(file_id: str, file_path: str, original_filename: str):
    try:
        # Update status
        processing_status[file_id]["message"] = "To fill the lang4..."

        # Simulate progress updates
        for i in range(1, 10):
            processing_status[file_id]["progress"] = i * 10
            await asyncio.sleep(0.5)  # Simulate processing time

            # Send progress update to WebSocket if connected
            if file_id in active_connections:
                await active_connections[file_id].send_json(processing_status[file_id])

        # Actual processing
        output_dir = "outputs"
        output_path = to_fill(file_path, output_dir)

        if output_path:
            base_name = os.path.splitext(original_filename)[0]
            output_filename = f"{base_name}_converted.jsp"
            final_path = f"outputs/{file_id}_{output_filename}"

            # Rename the output file to include the file_id
            shutil.move(output_path, final_path)

            processing_status[file_id].update(
                {
                    "status": "completed",
                    "progress": 100,
                    "message": "Conversion completed successfully!",
                    "output_file": final_path,
                }
            )
        else:
            processing_status[file_id].update(
                {
                    "status": "error",
                    "progress": 100,
                    "message": "Conversion failed. No errors found or processing error occurred.",
                }
            )

    except Exception as e:
        log_info.error(f"Error in convert task: {str(e)}")
        processing_status[file_id].update(
            {"status": "error", "progress": 100, "message": f"Error: {str(e)}"}
        )

    # Send final status update
    if file_id in active_connections:
        await active_connections[file_id].send_json(processing_status[file_id])


async def make_script_matrix(file_id: str, file_path: str, original_filename: str):
    try:
        # Update status
        processing_status[file_id]["message"] = "Generating MATRIX script..."

        # Simulate progress updates
        for i in range(1, 10):
            processing_status[file_id]["progress"] = i * 10
            await asyncio.sleep(0.5)  # Simulate processing time

            # Send progress update to WebSocket if connected
            if file_id in active_connections:
                await active_connections[file_id].send_json(processing_status[file_id])

        # Actual processing
        output_dir = "outputs"
        output_path = matrix(file_path, output_dir)

        if output_path:
            base_name = os.path.splitext(original_filename)[0]
            output_filename = f"{base_name}_matrix.sql"
            final_path = f"outputs/{file_id}_{output_filename}"

            # Rename the output file to include the file_id
            shutil.move(output_path, final_path)

            processing_status[file_id].update(
                {
                    "status": "completed",
                    "progress": 100,
                    "message": "Script generation completed successfully!",
                    "output_file": final_path,
                }
            )
        else:
            processing_status[file_id].update(
                {
                    "status": "error",
                    "progress": 100,
                    "message": "Script generation failed. No errors found or processing error occurred.",
                }
            )

    except Exception as e:
        log_info(f"Error in script task: {str(e)}")
        processing_status[file_id].update(
            {"status": "error", "progress": 100, "message": f"Error: {str(e)}"}
        )

    # Send final status update
    if file_id in active_connections:
        await active_connections[file_id].send_json(processing_status[file_id])


@router.websocket("/ws/{file_id}")
async def websocket_endpoint(websocket: WebSocket, file_id: str):
    await websocket.accept()
    active_connections[file_id] = websocket

    try:
        # Send initial status if available
        if file_id in processing_status:
            await websocket.send_json(processing_status[file_id])

        # Keep connection open and handle disconnection
        while True:
            await websocket.receive_text()
    except Exception as e:
        log_info(f"WebSocket error: {str(e)}")
    finally:
        if file_id in active_connections:
            del active_connections[file_id]


@router.get("/download/{file_id}")
async def download_file(file_id: str, background_tasks: BackgroundTasks):
    if file_id not in processing_status:
        raise HTTPException(status_code=404, detail="File ID not found")

    status = processing_status[file_id]
    if status["status"] != "completed" or not status["output_file"]:
        raise HTTPException(
            status_code=400,
            detail="File processing not completed or no output file available",
        )

    output_file = status["output_file"]
    if not os.path.exists(output_file):
        raise HTTPException(status_code=404, detail="Output file not found")

    # Schedule cleanup after download
    background_tasks.add_task(cleanup_files, file_id)

    return FileResponse(
        path=output_file,
        filename=os.path.basename(output_file).replace(f"{file_id}_", ""),
        media_type="application/octet-stream",
    )


async def cleanup_files(file_id: str):
    """Clean up uploaded and output files after download"""
    try:
        # Wait a bit to ensure download has started
        await asyncio.sleep(5)

        # Clean up uploaded file
        uploaded_files = [
            f for f in os.listdir("uploads") if f.startswith(f"{file_id}_")
        ]
        for file in uploaded_files:
            file_path = f"uploads/{file}"
            if os.path.exists(file_path):
                os.remove(file_path)
                log_info(f"Removed uploaded file: {file_path}")

        # Clean up output file
        output_files = [f for f in os.listdir("outputs") if f.startswith(f"{file_id}_")]
        for file in output_files:
            file_path = f"outputs/{file}"
            if os.path.exists(file_path):
                os.remove(file_path)
                log_info(f"Removed output file: {file_path}")

        # Clean up status
        if file_id in processing_status:
            del processing_status[file_id]

    except Exception as e:
        log_info(f"Error during cleanup: {str(e)}")


# @router.get("/form", response_class=HTMLResponse)
# async def get_form(request: Request):
#     return templates.TemplateResponse("form.html", {"request": request})


# @router.post("/form")
# async def submit_form(name: str = Form(...), email: str = Form(...)):
#     form_data = FormData(name=name, email=email)
#     # Process the form data (e.g., save to database)
#     return {"message": "Form submitted successfully!", "data": form_data}
