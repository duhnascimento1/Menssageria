PROMPT CREATE OR REPLACE TRIGGER dbahsm.trg_insere_fila_os_hsm
CREATE OR REPLACE TRIGGER dbahsm.trg_insere_fila_os_hsm
AFTER INSERT ON tb_solicitacao_os
FOR EACH ROW
WHEN (NEW.tp_situacao = 'S' AND NEW.cd_oficina IN (39,26))
DECLARE
  v_nome_setor dbamv.tb_setor.nm_setor%TYPE;
BEGIN
  SELECT s.nm_setor
    INTO v_nome_setor
    FROM dbamv.tb_setor s
   WHERE s.cd_setor = :NEW.cd_setor;

  dbahsm.pkg_msg_chamado_fila_hsm.insere_chamado(
     p_cd_os          => :NEW.cd_os,
     p_nm_solicitante => :NEW.nm_solicitante,
     p_nm_setor       => v_nome_setor,
     p_ds_servico     => :NEW.ds_servico,
     p_situacao       => :NEW.tp_situacao,
     p_dt_pedido      => TO_CHAR(:NEW.dt_pedido, 'DD/MM/YYYY HH24:MI:SS')
  );
END;
/

