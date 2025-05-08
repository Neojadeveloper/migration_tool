# fastapi-form-app

This project is a FastAPI application that provides a simple form for user input. It demonstrates how to create a web application using FastAPI, Pydantic for data validation, and SQLAlchemy for database interaction.

## Project Structure

```
fastapi-form-app
├── src
│   ├── main.py          # Entry point of the FastAPI application
│   ├── forms
│   │   └── forms.py     # Form classes using Pydantic
│   ├── models
│   │   └── models.py    # Database models using SQLAlchemy
│   ├── routes
│   │   └── router.py    # Route definitions for the application
│   └── templates
│       ├── base.html     # Base HTML template
│       └── form.html     # HTML template for the form
├── requirements.txt      # Project dependencies
└── README.md             # Project documentation
```

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd fastapi-form-app
   ```

2. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

## Usage

To run the application, execute the following command:
```
uvicorn src.main:app --reload
```

Visit `http://127.0.0.1:8000` in your web browser to access the application.

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.