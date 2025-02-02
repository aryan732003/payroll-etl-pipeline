import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.types import NVARCHAR
from config import Config  
import pyodbc
import sys
import logging

# Setup logging for better traceability
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Database connection string
conn_str = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={Config.DB_SERVER};DATABASE={Config.DB_NAME};UID={Config.DB_USER};PWD={Config.DB_PASSWORD}"

# Target table in SQL Server
target_table = "ExcelImportPayroll"
engine = create_engine(Config.SQLALCHEMY_DATABASE_URI)

# Load CSV data
csv_file = r"D:\\PayrollSystem.py\\data\\PayRollData.csv"  
df = pd.read_csv(csv_file, encoding="utf-8")

# Clean and fix column data types
df["Email"] = df["Email"].astype(str).str.strip().fillna("")
df["PhoneNumber"] = df["PhoneNumber"].astype(str).str.strip().fillna("")


def check_for_duplicates(df):
    """
    Checks for duplicates in the DataFrame based on Email or PhoneNumber.
    If any duplicate is found, stops the script execution.
    """
    with pyodbc.connect(conn_str) as cnxn:
        with cnxn.cursor() as cursor:
            for index, row in df.iterrows():
                email = row['Email']
                phone_number = row['PhoneNumber']

                cursor.execute(f"""
                    SELECT COUNT(*) 
                    FROM {target_table}
                    WHERE Email = ? OR PhoneNumber = ?
                """, (email, phone_number))

                count = cursor.fetchone()[0]
                
                if count > 0:
                    logging.error(f"Duplicate found for Email: {email} or PhoneNumber: {phone_number}. Aborting insertion.")
                    raise ValueError(f"Duplicate found for Email: {email} or PhoneNumber: {phone_number}. Aborting insertion.")


def truncate_table():
    """
    Truncates the target table before data insertion.
    """
    with pyodbc.connect(conn_str) as cnxn:
        with cnxn.cursor() as cursor:
            try:
                logging.info(f"Truncating table: {target_table}")
                cursor.execute(f"TRUNCATE TABLE {target_table}")
                cnxn.commit()
                logging.info("✅ Table truncated successfully.")
            except Exception as e:
                logging.error(f"❌ Error truncating table {target_table}: {e}")
                raise


def insert_data_to_sql(df):
    """
    Inserts the DataFrame into the target SQL Server table.
    """
    df.to_sql(
        target_table, 
        con=engine, 
        if_exists="append", 
        index=False, 
        dtype={"Email": NVARCHAR(255), "PhoneNumber": NVARCHAR(30)}
    )
    logging.info("✅ Data successfully inserted into the Employees table.")


def execute_stored_procedures():
    """
    Executes a series of stored procedures sequentially.
    """
    procedures = [
        "LoadDepartment",
        "LoadDesignation",
        "LoadEmployees",
        "LoadPayroll",
        "LoadTimesheet",
        "MergeLeaveRecords"
    ]
    
    with pyodbc.connect(conn_str) as cnxn:
        with cnxn.cursor() as cursor:
            for sp in procedures:
                try:
                    logging.info(f"Executing stored procedure: {sp}")
                    cursor.execute(f"EXEC {sp}")
                    cnxn.commit()
                    logging.info(f"✅ {sp} executed successfully.")
                except Exception as e:
                    logging.error(f"❌ Error executing {sp}: {e}")
                    raise  # Raise the error to stop further execution


def main():
    try:
        logging.info("Starting the process of importing data.")
        
        # Ask the user if they want to truncate the table before insertion
        user_input = input("Do you want to truncate the table before inserting data? (yes/no): ").strip().lower()
        
        if user_input == "yes":
            truncate_table()
        
        # After truncating, ask the user if they want to insert the data
        insert_data_input = input("Do you want to insert the data after truncating? (yes/no): ").strip().lower()
        
        if insert_data_input == "no":
            logging.info("Exiting the script as user opted not to insert data.")
            sys.exit(0)  # Exit the script without inserting data
        
        # Check for duplicates before inserting
        check_for_duplicates(df)

        # If no duplicates, proceed with data insertion
        insert_data_to_sql(df)

        # Execute stored procedures if insertion was successful
        execute_stored_procedures()

    except Exception as e:
        logging.error(f"❌ Error: {e}")
        sys.exit(1)  # Stop the script in case of an error


# Execute the main function
if __name__ == "__main__":
    main()
