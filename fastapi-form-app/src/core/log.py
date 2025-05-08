import logging


logger = logging.getLogger(__name__)


def log_info(message: str):
    logging.basicConfig(level=logging.INFO)
    """Log an info message."""
    logger.info(message)
