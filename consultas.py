from db import get_connection

def buscar_chamados():
    conn = get_connection()
    if not conn:
        return []

    cur = conn.cursor()

    sql = """
        SELECT 
            'OS: ' || cd_os || CHR(13) || CHR(10) ||
            'SOLICITANTE: ' || nm_solicitante || CHR(13) || CHR(10) ||
            'SETOR: ' || nm_setor || CHR(13) || CHR(10) ||
            'DESCRIÇÃO: ' || ds_servico
        FROM dbahsm.msg_chamado_fila_hsm
    """

    cur.execute(sql)
    dados = [row[0] for row in cur.fetchall()]

    cur.close()
    conn.close()
    return dados
