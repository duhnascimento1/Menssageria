PROMPT CREATE OR REPLACE PACKAGE pkg_msg_chamado_fila_hsm
CREATE OR REPLACE PACKAGE pkg_msg_chamado_fila_hsm AS

    PROCEDURE verifica_chamados;

    PROCEDURE insere_chamado(
        p_cd_os          IN NUMBER,
        p_nm_solicitante IN VARCHAR2,
        p_nm_setor     IN VARCHAR2,
        p_ds_servico     IN VARCHAR2,
        p_situacao       IN VARCHAR2,
        p_dt_pedido      IN VARCHAR2
    );

END pkg_msg_chamado_fila_hsm;
/

PROMPT CREATE OR REPLACE PACKAGE BODY pkg_msg_chamado_fila_hsm
CREATE OR REPLACE PACKAGE BODY pkg_msg_chamado_fila_hsm AS

    -------------------------------------------------------------------
    -- USADO PELA TRIGGER      (INSERE 1 CHAMADO)
    -------------------------------------------------------------------
    PROCEDURE insere_chamado(
        p_cd_os          IN NUMBER,
        p_nm_solicitante IN VARCHAR2,
        p_nm_setor       IN VARCHAR2,
        p_ds_servico     IN VARCHAR2,
        p_situacao       IN VARCHAR2,
        p_dt_pedido      IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO dbahsm.msg_chamado_fila_hsm (
            cd_os,
            nm_solicitante,
            nm_setor,
            ds_servico,
            situacao,
            dt_pedido
        )
        VALUES (
            p_cd_os,
            p_nm_solicitante,
            p_nm_setor,
            p_ds_servico,

            p_situacao,
            p_dt_pedido
        );

        --COMMIT;
    END insere_chamado;


    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- USADO POR JOB (VARRE A VIEW) + ADCIONAR COLUNA NA TABELA COM CONFIRMAÇÃO DE LEITURA + ADICIONAR O FILTRO AQUI+ CRIAR RETORNO DE UPDATE NO ARQUIVO .SQL E .PY NA TABELA DE CONFIRMAÇÃO DE ENVIO.
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE verifica_chamados IS

    CURSOR c_chamados IS
        SELECT
            C.cd_os,
            C.nm_solicitante,
            C.nm_setor,
            C.ds_servico,
            C.tp_situacao,
            C.dt_pedido
        FROM vdic_solicitacao_os C
        WHERE NOT EXISTS (
                SELECT 1
                  FROM dbahsm.msg_chamado_fila_hsm f
                 WHERE f.cd_os = C.cd_os
              )
        ORDER BY C.dt_pedido DESC;

BEGIN
    FOR r IN c_chamados LOOP

        INSERT INTO dbahsm.msg_chamado_fila_hsm (
            cd_os,
            nm_solicitante,
            nm_setor,
            ds_servico,
            situacao,
            dt_pedido
        )
        VALUES (
            r.cd_os,
            r.nm_solicitante,
            r.nm_setor,
            r.ds_servico,
            r.tp_situacao,
            TO_CHAR(r.dt_pedido, 'DD/MM/YYYY HH24:MI:SS')
        );

    END LOOP;

    COMMIT;
END verifica_chamados;


END pkg_msg_chamado_fila_hsm;
/

