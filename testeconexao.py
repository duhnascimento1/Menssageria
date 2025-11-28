
from db import get_connection

conn = get_connection()

if conn:
    print(" Conexão com Oracle realizada com sucesso!")

    # Testa uma query simples
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM dual")
    print(" Teste de consulta OK:", cur.fetchone())

    cur.close()
    conn.close()
else:
    print("Não foi possível conectar no banco.")
