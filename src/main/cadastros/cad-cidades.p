USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 200.

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

DEFINE QUERY qCidades FOR Cidades SCROLLING.
DEFINE BUFFER bCidades FOR Cidades.

DEFINE FRAME f-cidades
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-export SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair SKIP(2)
    Cidades.CodCidade COLON 20 LABEL "Codigo"
    Cidades.NomCidade COLON 20 LABEL "Nome da Cidade"
    Cidades.CodUF COLON 20 LABEL "UF"
    WITH SIDE-LABELS THREE-D SIZE 140 BY 12
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Cidades".

/* Eventos de navegação */
ON 'choose' OF bt-pri DO:
    GET FIRST qCidades.
    RUN piMostra.
END.

ON 'choose' OF bt-ant DO:
    GET PREV qCidades.
    RUN piMostra.
END.

ON 'choose' OF bt-prox DO:
    GET NEXT qCidades.
    RUN piMostra.
END.

ON 'choose' OF bt-ult DO:
    GET LAST qCidades.
    RUN piMostra.
END.

/* Evento adicionar */
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-cidades.

    FIND LAST Cidades NO-LOCK NO-ERROR.
    IF AVAILABLE Cidades THEN
        DISPLAY Cidades.CodCidade + 1 @ Cidades.CodCidade WITH FRAME f-cidades.
    ELSE
        DISPLAY 1 @ Cidades.CodCidade WITH FRAME f-cidades.
    
    APPLY "ENTRY" TO Cidades.NomCidade IN FRAME f-cidades.
END.

/* Evento modificar */
ON 'choose' OF bt-mod DO:
    IF NOT AVAILABLE Cidades THEN RETURN.
    
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    RUN piMostra.
    APPLY "ENTRY" TO Cidades.NomCidade IN FRAME f-cidades.
END.

/* Evento eliminar */
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    IF NOT AVAILABLE Cidades THEN RETURN.
    
    FIND FIRST Clientes WHERE Clientes.CodCidade = Cidades.CodCidade NO-LOCK NO-ERROR.
    IF AVAILABLE Clientes THEN DO:
        MESSAGE "Nao é possível eliminar esta cidade pois esta sendo utilizada!"
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    MESSAGE "Confirma a eliminacao da cidade" Cidades.CodCidade "- " Cidades.NomCidade "?"
            UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
                
    IF lConf THEN DO:
        FIND bCidades WHERE bCidades.CodCidade = Cidades.CodCidade EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bCidades THEN DO:
            DELETE bCidades.
            RUN piOpenQuery.
            RUN piMostra.
        END.
    END.
END.

/* Evento salvar */
ON 'choose' OF bt-save DO:
    DEFINE VARIABLE cNome AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cUF AS CHARACTER NO-UNDO.
    
    ASSIGN cNome = Cidades.NomCidade:SCREEN-VALUE IN FRAME f-cidades
           cUF = Cidades.CodUF:SCREEN-VALUE IN FRAME f-cidades.
           
    /* Validações */
    IF cNome = "" OR cNome = ? THEN DO:
        MESSAGE "Nome da cidade e obrigatorio!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Cidades.NomCidade IN FRAME f-cidades.
        RETURN.
    END.
    
    IF cUF = "" OR cUF = ? THEN DO:
        MESSAGE "UF e obrigatoria!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Cidades.CodUF IN FRAME f-cidades.
        RETURN.
    END.
    
    IF LENGTH(cUF) <> 2 THEN DO:
        MESSAGE "UF deve ter exatamente 2 caracteres!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Cidades.CodUF IN FRAME f-cidades.
        RETURN.
    END.

    IF cAction = "add" THEN DO:
        CREATE bCidades.
        ASSIGN bCidades.CodCidade = INPUT Cidades.CodCidade.
    END.
    ELSE IF cAction = "mod" THEN DO:
        FIND bCidades WHERE bCidades.CodCidade = Cidades.CodCidade EXCLUSIVE-LOCK NO-ERROR.
    END.
    
    IF AVAILABLE bCidades THEN DO:
        ASSIGN bCidades.NomCidade = cNome
               bCidades.CodUF = CAPS(cUF).
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

ENABLE ALL WITH FRAME f-cidades.
WAIT-FOR WINDOW-CLOSE OF FRAME f-cidades.

/* Procedures internas */
PROCEDURE piMostra:
    IF AVAILABLE Cidades THEN DO:
        DISPLAY Cidades.CodCidade Cidades.NomCidade Cidades.CodUF
                WITH FRAME f-cidades.
    END.
    ELSE DO:
        CLEAR FRAME f-cidades.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Cidades THEN DO:
        ASSIGN rRecord = ROWID(Cidades).
    END.
    
    OPEN QUERY qCidades FOR EACH Cidades NO-LOCK.
    REPOSITION qCidades TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME f-cidades:
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

    DO WITH FRAME f-cidades:
        ASSIGN Cidades.CodCidade:SENSITIVE = FALSE  /* Nunca habilitado após inclusão */
               Cidades.NomCidade:SENSITIVE = pEnable
               Cidades.CodUF:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piExportar:
    DEFINE VARIABLE cArqCSV AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArqJSON AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aCidades AS JsonArray NO-UNDO.
    DEFINE VARIABLE oCidade AS JsonObject NO-UNDO.
    
    ASSIGN cArqCSV = "c:\dados\cidades.csv"
           cArqJSON = "c:\dados\cidades.json".
    
    /* Exporta CSV */
    OUTPUT TO VALUE(cArqCSV).
    PUT UNFORMATTED "Codigo;Cidade;UF" SKIP.
    FOR EACH Cidades NO-LOCK:
        PUT UNFORMATTED 
            Cidades.CodCidade ";"
            Cidades.NomCidade ";"
            Cidades.CodUF SKIP.
    END.
    OUTPUT CLOSE.
    
    /* Exporta JSON */
    aCidades = NEW JsonArray().
    FOR EACH Cidades NO-LOCK:
        oCidade = NEW JsonObject().
        oCidade:add("codigo", Cidades.CodCidade).
        oCidade:add("cidade", Cidades.NomCidade).
        oCidade:add("uf", Cidades.CodUF).
        aCidades:add(oCidade).
    END.
    aCidades:WriteFile(INPUT cArqJSON, INPUT YES, INPUT "utf-8").
    
    MESSAGE "Arquivos exportados:" SKIP
            cArqCSV SKIP
            cArqJSON
            VIEW-AS ALERT-BOX INFORMATION.
END PROCEDURE.