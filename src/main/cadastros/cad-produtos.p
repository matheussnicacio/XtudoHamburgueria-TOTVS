CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-pri LABEL "<<" SIZE 5 BY 1.
DEFINE BUTTON bt-ant LABEL "<" SIZE 5 BY 1.
DEFINE BUTTON bt-prox LABEL ">" SIZE 5 BY 1.
DEFINE BUTTON bt-ult LABEL ">>" SIZE 5 BY 1.
DEFINE BUTTON bt-add LABEL "Adicionar" SIZE 12 BY 1.
DEFINE BUTTON bt-mod LABEL "Modificar" SIZE 12 BY 1.
DEFINE BUTTON bt-del LABEL "Eliminar" SIZE 12 BY 1.
DEFINE BUTTON bt-save LABEL "Salvar" SIZE 12 BY 1.
DEFINE BUTTON bt-canc LABEL "Cancelar" SIZE 12 BY 1.
DEFINE BUTTON bt-export LABEL "Exportar" SIZE 12 BY 1.
DEFINE BUTTON bt-sair LABEL "Sair" SIZE 12 BY 1 AUTO-ENDKEY.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY qProdutos FOR Produtos SCROLLING.
DEFINE BUFFER bProdutos FOR Produtos.

DEFINE FRAME f-produtos
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-export SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair SKIP(2)
    Produtos.CodProduto COLON 20 LABEL "Codigo"
    Produtos.NomProduto COLON 20 LABEL "Produto"
    Produtos.ValProduto COLON 20 LABEL "Valor"
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Produtos".

/* Eventos de navegação */
ON 'choose' OF bt-pri DO:
    GET FIRST qProdutos.
    RUN piMostra.
END.

ON 'choose' OF bt-ant DO:
    GET PREV qProdutos.
    RUN piMostra.
END.

ON 'choose' OF bt-prox DO:
    GET NEXT qProdutos.
    RUN piMostra.
END.

ON 'choose' OF bt-ult DO:
    GET LAST qProdutos.
    RUN piMostra.
END.

/* Evento adicionar */
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-produtos.
    
    FIND LAST Produtos NO-LOCK NO-ERROR.
    IF AVAILABLE Produtos THEN
        DISPLAY Produtos.CodProduto + 1 @ Produtos.CodProduto WITH FRAME f-produtos.
    ELSE
        DISPLAY 1 @ Produtos.CodProduto WITH FRAME f-produtos.
    
    APPLY "ENTRY" TO Produtos.NomProduto IN FRAME f-produtos.
END.

/* Evento modificar */
ON 'choose' OF bt-mod DO:
    IF NOT AVAILABLE Produtos THEN RETURN.
    
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    RUN piMostra.
    APPLY "ENTRY" TO Produtos.NomProduto IN FRAME f-produtos.
END.

/* Evento eliminar */
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    IF NOT AVAILABLE Produtos THEN RETURN.
    
    FIND FIRST Itens WHERE Itens.CodProduto = Produtos.CodProduto NO-LOCK NO-ERROR.
    IF AVAILABLE Itens THEN DO:
        MESSAGE "Nao e possivel eliminar este produto pois esta sendo utilizado em pedidos!"
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    MESSAGE "Confirma a eliminacao do produto" Produtos.CodProduto "- " Produtos.NomProduto "?"
            UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
                
    IF lConf THEN DO:
        FIND bProdutos WHERE bProdutos.CodProduto = Produtos.CodProduto EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bProdutos THEN DO:
            DELETE bProdutos.
            RUN piOpenQuery.
            RUN piMostra.
        END.
    END.
END.

/* Evento salvar */
ON 'choose' OF bt-save DO:
    DEFINE VARIABLE cProduto AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dValor AS DECIMAL NO-UNDO.
    
    ASSIGN cProduto = Produtos.NomProduto:SCREEN-VALUE IN FRAME f-produtos
           dValor = DECIMAL(Produtos.ValProduto:SCREEN-VALUE IN FRAME f-produtos) NO-ERROR.
           
    /* Validações */
    IF cProduto = "" OR cProduto = ? THEN DO:
        MESSAGE "Nome do produto e obrigatorio!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Produtos.NomProduto IN FRAME f-produtos.
        RETURN.
    END.
    
    IF dValor <= 0 THEN DO:
        MESSAGE "Valor deve ser maior que zero!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Produtos.ValProduto IN FRAME f-produtos.
        RETURN.
    END.

    IF cAction = "add" THEN DO:
        CREATE bProdutos.
        ASSIGN bProdutos.CodProduto = INPUT Produtos.CodProduto.
    END.
    ELSE IF cAction = "mod" THEN DO:
        FIND bProdutos WHERE bProdutos.CodProduto = Produtos.CodProduto EXCLUSIVE-LOCK NO-ERROR.
    END.
    
    IF AVAILABLE bProdutos THEN DO:
        ASSIGN bProdutos.NomProduto = cProduto
               bProdutos.ValProduto = dValor.
    END.

    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piOpenQuery.
    RUN piMostra.
END.

/* Evento cancelar */
ON 'choose' OF bt-canc DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piMostra.
END.

/* Evento exportar */
ON CHOOSE OF bt-export DO:
    RUN piExportar.
END.

/* Inicialização */
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

ENABLE ALL WITH FRAME f-produtos.
WAIT-FOR WINDOW-CLOSE OF FRAME f-produtos.

/* Procedures internas */
PROCEDURE piMostra:
    IF AVAILABLE Produtos THEN DO:
        DISPLAY Produtos.CodProduto Produtos.NomProduto Produtos.ValProduto
                WITH FRAME f-produtos.
    END.
    ELSE DO:
        CLEAR FRAME f-produtos.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Produtos THEN DO:
        ASSIGN rRecord = ROWID(Produtos).
    END.
    
    OPEN QUERY qProdutos FOR EACH Produtos NO-LOCK.
    REPOSITION qProdutos TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME f-produtos:
        ASSIGN bt-pri:SENSITIVE = pEnable
               bt-ant:SENSITIVE = pEnable
               bt-prox:SENSITIVE = pEnable
               bt-ult:SENSITIVE = pEnable
               bt-add:SENSITIVE = pEnable
               bt-mod:SENSITIVE = pEnable
               bt-del:SENSITIVE = pEnable
               bt-export:SENSITIVE = pEnable
               bt-sair:SENSITIVE = pEnable
               bt-save:SENSITIVE = NOT pEnable
               bt-canc:SENSITIVE = NOT pEnable.
    END.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME f-produtos:
        ASSIGN Produtos.CodProduto:SENSITIVE = FALSE
               Produtos.NomProduto:SENSITIVE = pEnable
               Produtos.ValProduto:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piExportar:
    DEFINE VARIABLE cArqCSV AS CHARACTER NO-UNDO.
    
    ASSIGN cArqCSV = "produtos.csv".
    
    /* Exporta apenas CSV para compatibilidade */
    OUTPUT TO VALUE(cArqCSV).
    PUT UNFORMATTED "Codigo;Produto;Valor" SKIP.
    FOR EACH Produtos NO-LOCK:
        PUT UNFORMATTED 
            Produtos.CodProduto ";"
            Produtos.NomProduto ";"
            Produtos.ValProduto SKIP.
    END.
    OUTPUT CLOSE.
    
    MESSAGE "Arquivo exportado: " cArqCSV
            VIEW-AS ALERT-BOX INFORMATION.
END PROCEDURE.