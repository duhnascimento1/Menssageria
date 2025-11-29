PROMPT CREATE TABLE msg_chamado_fila_hsm
CREATE TABLE msg_chamado_fila_hsm (
  cd_os          NUMBER        NOT NULL,
  nm_solicitante VARCHAR2(50)  NULL,
  nm_setor       VARCHAR2(50)  NULL,
  ds_servico     VARCHAR2(500) NULL,
  situacao       VARCHAR2(30)  NULL,
  dt_pedido      VARCHAR2(50)  NULL
)
  STORAGE (
    NEXT       1024 K
  )
/

PROMPT ALTER TABLE msg_chamado_fila_hsm ADD PRIMARY KEY
ALTER TABLE msg_chamado_fila_hsm
  ADD PRIMARY KEY (
    cd_os
  )
  USING INDEX
    STORAGE (
      NEXT       1024 K
    )
/


