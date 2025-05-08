from core.config import MODULE_CODE


class MatrixError(Exception):
    def __init__(self, message: str, error_code: str = None):
        self.message = message
        self.error_code = error_code or f"{MODULE_CODE}_MATRIX_ERROR"
        super().__init__(self.message)
