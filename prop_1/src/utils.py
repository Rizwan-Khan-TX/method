import logging
from pathlib import Path
from config import log_dir, log_file

# Configure application logging.
def setup_logging():
    Path(log_dir).mkdir(
        parents=True,
        exist_ok=True
    )

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
    )