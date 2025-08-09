USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

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

DEFINE QUERY qClientes FOR Clientes, Cidades SCROLLING.
DEFINE BUFFER bClientes FOR Clientes.
DEFINE BUFFER bCidades FOR Cidades.

DEFINE FRAME f-clientes
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-export SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair SKIP(2)
    Clientes.CodCliente COLON 20 LABEL "Codigo"
    Clientes.NomCliente COLON 20 LABEL "Nome"
    Clientes.CodEndereco COLON 20 LABEL "Endereco"
    Clientes.CodCidade COLON 20 LABEL "Codigo Cidade"
    Cidades.NomCidade COLON 20 LABEL "Nome Cidade"
    Clientes.Observacao COLON 20 LABEL "Observacao" VIEW-AS EDITOR SIZE 50 BY 3 SCROLLBAR-VERTICAL
    WITH SIDE-LABELS THREE-D SIZE 140 BY 18
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Clientes".

/* Eventos de navegação */
ON 'choose' OF bt-pri DO:
    GET FIRST qClientes.
    RUN piMostra.
END.

ON 'choose' OF bt-ant DO:
    GET PREV qClientes.
    RUN piMostra.
END.

ON 'choose' OF bt-prox DO:
    GET NEXT qClientes.
    RUN piMostra.
END.

ON 'choose' OF bt-ult DO:
    GET LAST qClientes.
    RUN piMostra.
END.

/* Evento adicionar */
ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-clientes.
    DISPLAY NEXT-VALUE(seqCliente) @ Clientes.CodCliente WITH FRAME f-clientes.
    ASSIGN Clientes.Observacao:SCREEN-VALUE IN FRAME f-clientes = "".
    APPLY "ENTRY" TO Clientes.NomCliente IN FRAME f-clientes.
END.

/* Evento modificar */
ON 'choose' OF bt-mod DO:
    IF NOT AVAILABLE Clientes THEN RETURN.
    
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    RUN piMostra.
    APPLY "ENTRY" TO Clientes.NomCliente IN FRAME f-clientes.
END.

/* Evento eliminar */
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    
    IF NOT AVAILABLE Clientes THEN RETURN.
    
    FIND FIRST Pedidos WHERE Pedidos.CodCliente = Clientes.CodCliente NO-LOCK NO-ERROR.
    IF AVAILABLE Pedidos THEN DO:
        MESSAGE "Nao e possivel eliminar este cliente pois possui pedidos!"
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    MESSAGE "Confirma a eliminacao do cliente" Clientes.CodCliente "- " Clientes.NomCliente "?"
            UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao".
                
    IF lConf THEN DO:
        FIND bClientes WHERE bClientes.CodCliente = Clientes.CodCliente EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bClientes THEN DO:
            DELETE bClientes.
            RUN piOpenQuery.
            RUN piMostra.
        END.
    END.
END.

/* Validação da cidade ao sair do campo */
ON 'leave' OF Clientes.CodCidade IN FRAME f-clientes DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iCidade AS INTEGER NO-UNDO.
    
    ASSIGN iCidade = INTEGER(Clientes.CodCidade:SCREEN-VALUE IN FRAME f-clientes) NO-ERROR.
    RUN piValidaCidade (INPUT iCidade, OUTPUT lValid).
    IF lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY bCidades.NomCidade @ Cidades.NomCidade WITH FRAME f-clientes.
END.

/* Evento salvar */
ON 'choose' OF bt-save DO:
    DEFINE VARIABLE cNome AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cEndereco AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iCidade AS INTEGER NO-UNDO.
    DEFINE VARIABLE cObs AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    
    ASSIGN cNome = Clientes.NomCliente:SCREEN-VALUE IN FRAME f-clientes.
    ASSIGN cEndereco = Clientes.CodEndereco:SCREEN-VALUE IN FRAME f-clientes.
    ASSIGN iCidade = INTEGER(Clientes.CodCidade:SCREEN-VALUE IN FRAME f-clientes) NO-ERROR.
    ASSIGN cObs = Clientes.Observacao:SCREEN-VALUE IN FRAME f-clientes.
           
    /* Validações */
    IF cNome = "" OR cNome = ? THEN DO:
        MESSAGE "Nome do cliente e obrigatorio!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Clientes.NomCliente IN FRAME f-clientes.
        RETURN.
    END.
    
    RUN piValidaCidade (INPUT iCidade, OUTPUT lValid).
    IF lValid = NO THEN DO:
        APPLY "ENTRY" TO Clientes.CodCidade IN FRAME f-clientes.
        RETURN.
    END.

    IF cAction = "add" THEN DO:
        CREATE bClientes.
        ASSIGN bClientes.CodCliente = INPUT Clientes.CodCliente.
    END.
    ELSE IF cAction = "mod" THEN DO:
        FIND bClientes WHERE bClientes.CodCliente = Clientes.CodCliente EXCLUSIVE-LOCK NO-ERROR.
    END.
    
    IF AVAILABLE bClientes THEN DO:
        ASSIGN bClientes.NomCliente = cNome
               bClientes.CodEndereco = cEndereco
               bClientes.CodCidade = iCidade
               bClientes.Observacao = cObs.
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

ENABLE ALL WITH FRAME f-clientes.
WAIT-FOR WINDOW-CLOSE OF FRAME f-clientes.

/* Procedures internas */
PROCEDURE piMostra:
    IF AVAILABLE Clientes THEN DO:
        DISPLAY Clientes.CodCliente Clientes.NomCliente 
                Clientes.CodEndereco Clientes.CodCidade
                Cidades.NomCidade Clientes.Observacao
                WITH FRAME f-clientes.
    END.
    ELSE DO:
        CLEAR FRAME f-clientes.
        ASSIGN Clientes.Observacao:SCREEN-VALUE IN FRAME f-clientes = "".
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Clientes THEN DO:
        ASSIGN rRecord = ROWID(Clientes).
    END.
    
    OPEN QUERY qClientes 
        FOR EACH Clientes NO-LOCK,
            FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK.
    
    REPOSITION qClientes TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME f-clientes:
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

    DO WITH FRAME f-clientes:
        ASSIGN Clientes.CodCliente:SENSITIVE = FALSE  /* Nunca habilitado após inclusão */
               Clientes.NomCliente:SENSITIVE = pEnable
               Clientes.CodEndereco:SENSITIVE = pEnable
               Clientes.CodCidade:SENSITIVE = pEnable
               Clientes.Observacao:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piValidaCidade:
    DEFINE INPUT PARAMETER pCodCidade AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
  
    FIND FIRST bCidades WHERE bCidades.CodCidade = pCodCidade NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bCidades THEN DO:
        MESSAGE "Cidade" pCodCidade "nao existe!"
                VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.

PROCEDURE piExportar:
    DEFINE VARIABLE cArqCSV AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArqJSON AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aClientes AS JsonArray NO-UNDO.
    DEFINE VARIABLE oCliente AS JsonObject NO-UNDO.
    
    ASSIGN cArqCSV = "c:\dados\clientes.csv"
           cArqJSON = "c:\dados\clientes.json".
    
    /* Exporta CSV */
    OUTPUT TO VALUE(cArqCSV).
    PUT UNFORMATTED "Codigo;Nome;Endereco;CodCidade;Cidade;Observacao" SKIP.
    FOR EACH Clientes NO-LOCK,
        FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK:
        PUT UNFORMATTED 
            Clientes.CodCliente ";"
            Clientes.NomCliente ";"
            Clientes.CodEndereco ";"
            Clientes.CodCidade ";"
            Cidades.NomCidade ";"
            Clientes.Observacao SKIP.
    END.
    OUTPUT CLOSE.
    
    /* Exporta JSON */
    aClientes = NEW JsonArray().
    FOR EACH Clientes NO-LOCK,
        FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK:
        oCliente = NEW JsonObject().
        oCliente:add("codigo", Clientes.CodCliente).
        oCliente:add("nome", Clientes.NomCliente).
        oCliente:add("endereco", Clientes.CodEndereco).
        oCliente:add("codCidade", Clientes.CodCidade).
        oCliente:add("cidade", Cidades.NomCidade).
        oCliente:add("observacao", Clientes.Observacao).
        aClientes:add(oCliente).
    END.
    aClientes:WriteFile(INPUT cArqJSON, INPUT YES, INPUT "utf-8").
    
    MESSAGE "Arquivos exportados:" SKIP
            cArqCSV SKIP
            cArqJSON
            VIEW-AS ALERT-BOX INFORMATION.
END PROCEDURE.