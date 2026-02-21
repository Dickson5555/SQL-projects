import pyodbc
def connect_db(username,password):
   conn = pyodbc.connect(
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=localhost\\SQLEXPRESS;"
    "Database=University;"
    f"UID={username};"
    f"PWD={password};"
    )
   return conn