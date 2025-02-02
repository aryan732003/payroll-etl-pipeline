import logging
from sqlalchemy import create_engine
from config import Config  
from sqlalchemy.exc import OperationalError
import time

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def test_database_connection():
    """
    Test the connection to the database using SQLAlchemy engine.
    Logs success or failure with detailed messages.
    """
    engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)

   
    retry_attempts = 3
    retry_delay = 5  # seconds

    for attempt in range(1, retry_attempts + 1):
        try:
            
            with engine.connect() as connection:
                logging.info("✅ Connection successful!")
                return 
        except OperationalError as e:
            logging.error(f"❌ Connection failed on attempt {attempt}/{retry_attempts}: {e}")
            if attempt < retry_attempts:
                logging.info(f"🔄 Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
            else:
                logging.error("❌ Maximum retry attempts reached. Please check your database connection settings.")
                return

if __name__ == "__main__":
    test_database_connection()
