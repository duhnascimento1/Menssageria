import oracledb
import os
from dotenv import load_dotenv

load_dotenv()

# Habilitar modo thick
oracledb.init_oracle_client(lib_dir=r"C:\oracle\instantclient")

def get_connection():
    try:
        conn = oracledb.connect(
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            service_name=os.getenv("DB_SERVICE")
        )
        return conn
    except Exception as e:
        print("Erro ao conectar no banco:")
        print(e)
        return None

