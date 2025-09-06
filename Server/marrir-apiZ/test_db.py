from sqlalchemy import create_engine

DB_HOST = "localhost"
DB_PORT = "5432"  # Ensure this is the correct port
DB_NAME = "pathsin_db"
DB_USER = "postgres"
DB_PASS = "root"

# Use f-string to correctly format the database URI
DB_URI = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

engine = create_engine(DB_URI)

try:
    connection = engine.connect()
    print("Connection successful!")
    connection.close()  # Always close the connection when done
except Exception as e:
    print("Connection failed:", e)
