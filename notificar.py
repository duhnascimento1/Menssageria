import requests
import os
from dotenv import load_dotenv
from consultas import buscar_chamados

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

HIST_FILE = os.path.join(BASE_DIR, "sent_os.txt")

def carregar_historico():
    if not os.path.exists(HIST_FILE):
        return set()
    with open(HIST_FILE, "r") as f:
        return set(line.strip() for line in f.readlines())

def salvar_historico(lista):
    with open(HIST_FILE, "a") as f:
        for item in lista:
            f.write(item + "\n")

def enviar_notificacao(msg):
    url = f"https://ntfy.sh/{os.getenv('NTFY_TOPIC')}"
    r = requests.post(url, data=msg.encode('utf-8'))
    return r.status_code

def main():
    chamados = buscar_chamados()
    historico = carregar_historico()
    novos = []

    for msg in chamados:
        os_number = msg.split("\n")[0].replace("OS: ", "").strip()

        if os_number not in historico:
            enviar_notificacao(msg)
            novos.append(os_number)

    if novos:
        salvar_historico(novos)
