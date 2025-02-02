import os
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

class Config:
    """
    Base configuration class with shared settings for all environments.
    """
    # Database credentials should come from environment variables for security
    DB_USER = os.getenv("DB_USER", "default_user")  # Default to 'default_user' if not set
    DB_PASSWORD = os.getenv("DB_PASSWORD", "default_password")  # Default to 'default_password'
    DB_SERVER = os.getenv("DB_SERVER", "localhost")  # Default to 'localhost'
    DB_NAME = os.getenv("DB_NAME", "PayrollSystem")  # Default to 'PayrollSystem'

    # SQLAlchemy database URI specifically for SQL Server using pyodbc
    SQLALCHEMY_DATABASE_URI = f"mssql+pyodbc://{DB_USER}:{DB_PASSWORD}@{DB_SERVER}/{DB_NAME}?driver=ODBC+Driver+17+for+SQL+Server"

    # SQLAlchemy settings
    SQLALCHEMY_TRACK_MODIFICATIONS = False  # Disable modification tracking to save resources

    # Secret key for security (used for session management, CSRF, etc.)
    SECRET_KEY = os.getenv("SECRET_KEY", "default_secret_key")

    # Simplified Logging configuration (no need for environment variable)
    LOGGING_LEVEL = "INFO"  # Default to INFO level, can change to DEBUG or ERROR if required
    LOGGING_FORMAT = "%(asctime)s - %(levelname)s - %(message)s"

    @staticmethod
    def init_app(app):
        """Initialize the app with the configuration values."""
        pass

class DevelopmentConfig(Config):
    """Development environment specific configuration."""
    DEBUG = True
    DB_SERVER = os.getenv("DB_SERVER_DEV", "localhost")  # Override server for dev environment if needed
    SQLALCHEMY_DATABASE_URI = f"mssql+pyodbc://{Config.DB_USER}:{Config.DB_PASSWORD}@{DB_SERVER}/{Config.DB_NAME}?driver=ODBC+Driver+17+for+SQL+Server"

class ProductionConfig(Config):
    """Production environment specific configuration."""
    DEBUG = False
    DB_SERVER = os.getenv("DB_SERVER_PROD", "prod_server")
    SQLALCHEMY_DATABASE_URI = f"mssql+pyodbc://{Config.DB_USER}:{Config.DB_PASSWORD}@{DB_SERVER}/{Config.DB_NAME}?driver=ODBC+Driver+17+for+SQL+Server"

class TestingConfig(Config):
    """Testing environment specific configuration."""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"  # Use an in-memory database for testing
    SQLALCHEMY_TRACK_MODIFICATIONS = False
