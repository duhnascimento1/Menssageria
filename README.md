# Messageria de chamados  - PLSQL + PYTHON + NTFY

Sistema de mensageria assíncrona para notificações de Ordens de Serviço, integrando Oracle PL/SQL, Python e NTFY.
A solução garante que eventos de chamados sejam enviados automaticamente ao usuário final, com alta confiabilidade e zero acoplamento entre backend e canal de notificação.

______________________________________________________________________________________________________
📌 Arquitetura

┌──────────────────────────────┐
│          Sistema Oracle       │
│      (Trigger + PL/SQL)       │
└───────────────┬──────────────┘
                │ grava evento
                ▼
┌──────────────────────────────┐
│     Tabela de Fila (Oracle)   │
│     HSM_FILA_NOTIFICACAO      │
└───────────────┬──────────────┘
                │ leitura periódica
                ▼
┌──────────────────────────────┐
│          Serviço Python       │
│   (Windows Service + NTFY)    │
└───────────────┬──────────────┘
                │ envia payload
                ▼
┌──────────────────────────────┐
│              NTFY             │
│      Notificações push        │
└──────────────────────────────┘



______________________________________________________________________________________________________
📌 Fluxo Geral

Trigger PL/SQL detecta mudanças em Ordens de Serviço.

O evento é registrado na tabela de fila com status Pendente.

O serviço Python, executando continuamente, consome a fila.

A aplicação envia a notificação para o tópico configurado no NTFY.

Após o envio, o registro é atualizado como Processado.

O usuário recebe instantaneamente o alerta no app.

📌 Tabela de Fila (exemplo)
CREATE TABLE HSM_FILA_NOTIFICACAO (
    ID NUMBER GENERATED ALWAYS AS IDENTITY,
    ID_OS NUMBER,
    MENSAGEM VARCHAR2(4000),
    STATUS VARCHAR2(20) DEFAULT 'PENDENTE',
    DT_CRIACAO DATE DEFAULT SYSDATE,
    DT_PROCESSAMENTO DATE
);

📌 Trigger de Captura do Evento
CREATE OR REPLACE TRIGGER TG_OS_NOTIF
AFTER INSERT OR UPDATE ON ORDEM_SERVICO
FOR EACH ROW
BEGIN
    INSERT INTO HSM_FILA_NOTIFICACAO (ID_OS, MENSAGEM)
    VALUES (:NEW.ID_OS, 'OS atualizada pelo usuário.');
END;
/

______________________________________________________________________________________________________
📌 Serviço Python (Resumo Técnico)

Lê pendências no Oracle via cx_Oracle ou oracledb.

Publica no NTFY com requests.post.

Roda como Windows Service via pywin32.

Usa pooling simples para reprocessar filas pendentes.

Atualiza a tabela no Oracle após o envio.

______________________________________________________________________________________________________
📌 Exemplo de Payload Enviado ao NTFY
{
  "topic": "hsm_os",
  "title": "Ordem de Serviço",
  "message": "OS #1250 atualizada.",
  "priority": 3,
  "tags": ["info", "os"]
}


______________________________________________________________________________________________________
📌 Configuração e Instalação
1. Criar ambiente virtual
python -m venv venv


Ativar:

venv\Scripts\activate

2. Instalar dependências
pip install requests pywin32 oracledb

3. Configurar o serviço

Registrar no Windows:

python servico_notificador.py install
python servico_notificador.py start


Ver status:

sc query ServicoNotificadorOS

______________________________________________________________________________________________________
📌 Variáveis de Configuração

No arquivo Python:

NTFY_TOPIC = "NOME_DA_SUA_FILA"
NTFY_URL = "https://ntfy.sh"
INTERVALO_SEGUNDOS = 5


Oracle:

dsn = "host:porta/servico"
usuario = "SEU_USUARIO_DB"
senha = "******"

______________________________________________________________________________________________________
📌 Logs

O serviço gera logs no Event Viewer:

Windows Logs > Application > Source: PythonService

______________________________________________________________________________________________________
📌 Benefícios da Arquitetura

Comunicação 100% assíncrona

Tolerante a falhas

Baixo acoplamento entre sistemas

Entregas rápidas via push

Fácil de escalar e monitorar

______________________________________________________________________________________________________
📌 Melhorias Futuras

Reprocessamento automático de falhas

Dashboard de consumo da fila

Migração para mensagerias enterprise (Kafka / RabbitMQ)

Notificações segmentadas por tipo de OS
