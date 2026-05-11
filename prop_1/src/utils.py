import logging
from pathlib import Path
from config import log_dir, log_file

def setup_logging():
    # --------------------------------------------------
    # Configure application logging.
    # --------------------------------------------------
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