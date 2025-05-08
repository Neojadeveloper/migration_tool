document.addEventListener('DOMContentLoaded', function () {
    // DOM Elements
    const uploadForm = document.getElementById('upload-form');
    const fileInput = document.getElementById('file-input');
    const fileName = document.getElementById('file-name');
    const optionsModal = document.getElementById('options-modal');
    const convertBtn = document.getElementById('convert-btn');
    const scriptBtn = document.getElementById('script-btn');
    const cancelOptions = document.getElementById('cancel-options');
    const progressModal = document.getElementById('progress-modal');
    const progressBar = document.getElementById('progress-bar');
    const progressPercent = document.getElementById('progress-percent');
    const progressMessage = document.getElementById('progress-message');
    const errorModal = document.getElementById('error-modal');
    const errorMessage = document.getElementById('error-message');
    const errorClose = document.getElementById('error-close');

    // Variables to store file data
    let currentFileId = null;
    let websocket = null;

    // Update file name display when file is selected
    fileInput.addEventListener('change', function () {
        if (this.files && this.files[0]) {
            const file = this.files[0];
            fileName.textContent = file.name;

            // Validate file extension
            if (!file.name.endsWith('.jsp')) {
                showError('Only .jsp files are allowed');
                fileInput.value = '';
                fileName.textContent = '';
            }
        } else {
            fileName.textContent = '';
        }
    });

    // Handle form submission
    uploadForm.addEventListener('submit', async function (e) {
        e.preventDefault();

        if (!fileInput.files || !fileInput.files[0]) {
            showError('Please select a file');
            return;
        }

        const file = fileInput.files[0];

        // Create FormData and append file
        const formData = new FormData();
        formData.append('file', file);

        try {
            // Upload the file
            const response = await fetch('/upload/', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || 'Upload failed');
            }

            const data = await response.json();
            currentFileId = data.file_id;

            // Show options modal
            showOptionsModal();

        } catch (error) {
            showError(error.message || 'An error occurred during upload');
        }
    });

    // Handle convert button click
    convertBtn.addEventListener('click', function () {
        if (currentFileId) {
            hideOptionsModal();
            processFile('convert');
        }
    });

    // Handle script button click
    scriptBtn.addEventListener('click', function () {
        if (currentFileId) {
            hideOptionsModal();
            processFile('script');
        }
    });

    // Handle cancel button click
    cancelOptions.addEventListener('click', function () {
        hideOptionsModal();
    });

    // Handle error close button click
    errorClose.addEventListener('click', function () {
        hideErrorModal();
    });

    // Process file with selected action
    async function processFile(action) {
        try {
            // Show progress modal
            showProgressModal();

            // Connect to WebSocket for progress updates
            connectWebSocket();

            // Start processing
            const response = await fetch('/process/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    file_id: currentFileId,
                    action: action
                })
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || 'Processing failed');
            }

            // Processing started successfully
            // Progress updates will come through WebSocket

        } catch (error) {
            hideProgressModal();
            showError(error.message || 'An error occurred during processing');
        }
    }

    // Connect to WebSocket for progress updates
    function connectWebSocket() {
        // Close existing connection if any
        if (websocket) {
            websocket.close();
        }

        // Create new WebSocket connection
        websocket = new WebSocket(`${window.location.protocol === 'https:' ? 'wss:' : 'ws:'}//${window.location.host}/ws/${currentFileId}`);

        websocket.onopen = function () {
            console.log('WebSocket connected');
        };

        websocket.onmessage = function (event) {
            const data = JSON.parse(event.data);
            updateProgress(data);

            // If processing is completed, trigger download
            if (data.status === 'completed' && data.output_file) {
                setTimeout(() => {
                    downloadFile();
                }, 1000);
            }

            // If there's an error, show error modal
            if (data.status === 'error') {
                hideProgressModal();
                showError(data.message || 'An error occurred during processing');
            }
        };

        websocket.onerror = function (error) {
            console.error('WebSocket error:', error);
            hideProgressModal();
            showError('Connection error. Please try again.');
        };

        websocket.onclose = function () {
            console.log('WebSocket disconnected');
        };
    }

    // Update progress bar and message
    function updateProgress(data) {
        progressBar.style.width = `${data.progress}%`;
        progressPercent.textContent = `${data.progress}%`;
        progressMessage.textContent = data.message || 'Processing...';
    }

    // Download the processed file
    function downloadFile() {
        if (!currentFileId) return;

        // Create a hidden link and trigger download
        const downloadLink = document.createElement('a');
        downloadLink.href = `/download/${currentFileId}`;
        downloadLink.style.display = 'none';
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);

        // Hide progress modal after a short delay
        setTimeout(() => {
            hideProgressModal();
            resetForm();
        }, 2000);
    }

    // Reset the form
    function resetForm() {
        fileInput.value = '';
        fileName.textContent = '';
        currentFileId = null;

        // Close WebSocket connection
        if (websocket) {
            websocket.close();
            websocket = null;
        }
    }

    // Show options modal
    function showOptionsModal() {
        optionsModal.style.display = 'flex';
    }

    // Hide options modal
    function hideOptionsModal() {
        optionsModal.style.display = 'none';
    }

    // Show progress modal
    function showProgressModal() {
        // Reset progress
        progressBar.style.width = '0%';
        progressPercent.textContent = '0%';
        progressMessage.textContent = 'Starting process...';

        progressModal.style.display = 'flex';
    }

    // Hide progress modal
    function hideProgressModal() {
        progressModal.style.display = 'none';
    }

    // Show error modal
    function showError(message) {
        errorMessage.textContent = message;
        errorModal.style.display = 'flex';
    }

    // Hide error modal
    function hideErrorModal() {
        errorModal.style.display = 'none';
    }
});