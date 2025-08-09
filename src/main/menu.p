
DEFINE VARIABLE cDiretorioAtual AS CHARACTER NO-UNDO.

DEFINE BUTTON bt-cidades
    LABEL "Cidades"
    SIZE 14 BY 1.25.

DEFINE BUTTON bt-produtos  
    LABEL "Produtos"
    SIZE 14 BY 1.25.

DEFINE BUTTON bt-clientes
    LABEL "Clientes" 
    SIZE 14 BY 1.25.

DEFINE BUTTON bt-pedidos
    LABEL "Pedidos"
    SIZE 14 BY 1.25.

DEFINE BUTTON bt-sair
    LABEL "Sair"
    SIZE 14 BY 1.25.

DEFINE BUTTON bt-rel-clientes
    LABEL "Relatorio de Clientes"
    SIZE 28 BY 1.25.

DEFINE BUTTON bt-rel-pedidos
    LABEL "Relatorio de Pedidos" 
    SIZE 28 BY 1.25.

DEFINE FRAME f-menu
    bt-cidades AT 3 
    bt-produtos AT 18
    bt-clientes AT 33
    bt-pedidos AT 48
    bt-sair AT 63
    bt-rel-clientes AT 3 
    bt-rel-pedidos AT 32
    WITH THREE-D 
    SIZE 80 BY 4.5
    VIEW-AS DIALOG-BOX 
    TITLE "Hamburgueria XTudo".

/* Função para localizar arquivo em múltiplos diretórios */
FUNCTION fLocalizarArquivo RETURNS CHARACTER
   (INPUT cNomeArquivo AS CHARACTER):
   
   DEFINE VARIABLE cCaminhoCompleto AS CHARACTER NO-UNDO.
   DEFINE VARIABLE cDiretorios AS CHARACTER NO-UNDO EXTENT 20.
   DEFINE VARIABLE i AS INTEGER NO-UNDO.
   
   /* Obtém o diretório atual */
   ASSIGN cDiretorioAtual = ".".
   
   /* Configura os possíveis caminhos onde os arquivos podem estar */
   ASSIGN cDiretorios[1] = ""                                    /* PROPATH */
          cDiretorios[2] = "./"                                  /* Diretório atual */
          cDiretorios[3] = ".\"                                  /* Diretório atual Windows */
          cDiretorios[4] = "src/main/cadastros/"                 /* Estrutura Maven/Gradle */
          cDiretorios[5] = "src/main/relatorios/"                /* Relatórios */
          cDiretorios[6] = "src/main/"                           /* Main */
          cDiretorios[7] = "src/"                                /* Src */
          cDiretorios[8] = "cadastros/"                          /* Cadastros */
          cDiretorios[9] = "relatorios/"                         /* Relatórios */
          cDiretorios[10] = "../cadastros/"                      /* Cadastros nível acima */
          cDiretorios[11] = "../relatorios/"                     /* Relatórios nível acima */
          cDiretorios[12] = "src\main\cadastros\"                /* Windows */
          cDiretorios[13] = "src\main\relatorios\"               /* Windows */
          cDiretorios[14] = "src\main\"                          /* Windows */
          cDiretorios[15] = "cadastros\"                         /* Windows */
          cDiretorios[16] = "relatorios\"                        /* Windows */
          cDiretorios[17] = "C:\sistema\hamburgueria\"           /* Caminho absoluto comum */
          cDiretorios[18] = "C:\dados\"                          /* Outro caminho comum */
          cDiretorios[19] = "C:\progress\"                       /* Outro caminho comum */
          cDiretorios[20] = "C:\work\".                          /* Workspace comum */
   
   /* Primeiro verifica PROPATH (mais eficiente) */
   IF SEARCH(cNomeArquivo) <> ? THEN
       RETURN SEARCH(cNomeArquivo).
   
   /* Procura nos diretórios configurados */
   DO i = 1 TO 20:
       IF cDiretorios[i] = ? THEN NEXT.
       
       ASSIGN cCaminhoCompleto = cDiretorios[i] + cNomeArquivo.
       
       IF SEARCH(cCaminhoCompleto) <> ? THEN
           RETURN SEARCH(cCaminhoCompleto).
   END.
   
   /* Se não encontrou, retorna vazio */
   RETURN "".
END FUNCTION.

/* Procedure para executar arquivo com tratamento completo de erro */
PROCEDURE piExecutarArquivo:
    DEFINE INPUT PARAMETER pcNomeArquivo AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cCaminhoCompleto AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTitulo AS CHARACTER NO-UNDO.
    
    CASE pcNomeArquivo:
        WHEN "cad-cidades.p" THEN cTitulo = "Cadastro de Cidades".
        WHEN "cad-produtos.p" THEN cTitulo = "Cadastro de Produtos".
        WHEN "cad-clientes.p" THEN cTitulo = "Cadastro de Clientes".
        WHEN "cad-pedidos.p" THEN cTitulo = "Cadastro de Pedidos e Itens".
        WHEN "menu-relatorios.p" THEN cTitulo = "Menu de Relatórios".
        WHEN "rel-clientes.p" THEN cTitulo = "Relatório de Clientes".
        WHEN "rel-pedidos.p" THEN cTitulo = "Relatório de Pedidos".
        OTHERWISE cTitulo = pcNomeArquivo.
    END CASE.
    
    ASSIGN cCaminhoCompleto = fLocalizarArquivo(pcNomeArquivo).
    
    IF cCaminhoCompleto <> "" THEN DO:

        RUN VALUE(cCaminhoCompleto) NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "Erro ao executar " + cTitulo + ":" SKIP(2)
                    "Arquivo: " + pcNomeArquivo SKIP
                    "Caminho: " + cCaminhoCompleto SKIP(2)
                    "Erro: " + ERROR-STATUS:GET-MESSAGE(1) SKIP(2)
                    "Verifique se o arquivo não tem erros de sintaxe" SKIP
                    "ou dependências não atendidas."
                    VIEW-AS ALERT-BOX ERROR TITLE "Erro de Execucao".
        END.
    END.
    ELSE DO:

        MESSAGE "Arquivo nao encontrado: " + pcNomeArquivo SKIP(2)
                "O sistema procurou nos seguintes locais:" SKIP
                "• Diretório atual e PROPATH" SKIP
                "• src/main/cadastros/ (para cadastros)" SKIP
                "• src/main/relatorios/ (para relatórios)" SKIP
                "• cadastros/ e relatorios/" SKIP
                "• C:\sistema\hamburgueria\" SKIP
                "• Outros caminhos comuns" SKIP(2)
                "SOLUÇÕES:" SKIP
                "1. Coloque o arquivo no diretorio atual" SKIP
                "2. Configure o PROPATH no Progress" SKIP
                "3. Organize os arquivos nas pastas sugeridas"
                VIEW-AS ALERT-BOX WARNING TITLE "Arquivo Não Encontrado".
        
        RUN piConfigurarDiretorio.
    END.
END PROCEDURE.

PROCEDURE piConfigurarDiretorio:
    DEFINE VARIABLE cDiretorio AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lContinuar AS LOGICAL NO-UNDO.
    
    MESSAGE "Deseja informar o diretorio onde estao seus arquivos?"
            UPDATE lContinuar
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Configurar Diretorio".
            
    IF lContinuar THEN DO:
        UPDATE cDiretorio 
               LABEL "Diretorio dos arquivos"
               HELP "Exemplo: C:\meu-sistema\ ou /home/user/sistema/"
               WITH FRAME f-config
               SIDE-LABELS
               VIEW-AS DIALOG-BOX
               TITLE "Configuração de Diretório".
        
        IF cDiretorio <> "" THEN DO:

            IF SUBSTRING(cDiretorio, LENGTH(cDiretorio), 1) <> "\" AND
               SUBSTRING(cDiretorio, LENGTH(cDiretorio), 1) <> "/" THEN DO:
                IF INDEX(cDiretorio, "\") > 0 THEN
                    ASSIGN cDiretorio = cDiretorio + "\".
                ELSE
                    ASSIGN cDiretorio = cDiretorio + "/".
            END.
            
            MESSAGE "Diretório configurado:" SKIP
                    cDiretorio SKIP(2)
                    "Agora voce pode tentar acessar as opcoes novamente." SKIP
                    "Se ainda não funcionar, verifique se os arquivos" SKIP
                    "existem neste diretório."
                    VIEW-AS ALERT-BOX INFORMATION
                    TITLE "Configuração Salva".
        END.
    END.
END PROCEDURE.

/* Eventos dos botões - Cadastros */
ON CHOOSE OF bt-cidades IN FRAME f-menu DO:
    RUN piExecutarArquivo("cad-cidades.p").
END.

ON CHOOSE OF bt-produtos IN FRAME f-menu DO:
    RUN piExecutarArquivo("cad-produtos.p").
END.

ON CHOOSE OF bt-clientes IN FRAME f-menu DO:
    RUN piExecutarArquivo("cad-clientes.p").
END.

ON CHOOSE OF bt-pedidos IN FRAME f-menu DO:
    RUN piExecutarArquivo("cad-pedidos.p").
END.

/* Eventos dos botões - Relatórios */
ON CHOOSE OF bt-rel-clientes IN FRAME f-menu DO:
    RUN piExecutarArquivo("rel-clientes.p").
END.

ON CHOOSE OF bt-rel-pedidos IN FRAME f-menu DO:
    RUN piExecutarArquivo("rel-pedidos.p").
END.

/* Evento do botão Sair */
ON CHOOSE OF bt-sair IN FRAME f-menu DO:
    MESSAGE "Obrigado por usar o Sistema Hamburgueria XTudo!" 
            VIEW-AS ALERT-BOX INFORMATION TITLE "Ate logo!".
    APPLY "CLOSE" TO THIS-PROCEDURE.
    RETURN.
END.

/* Exibe a janela */
DO ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    VIEW FRAME f-menu.
    ENABLE ALL WITH FRAME f-menu.
    WAIT-FOR CHOOSE OF bt-sair IN FRAME f-menu OR WINDOW-CLOSE OF CURRENT-WINDOW.
END.

HIDE FRAME f-menu.