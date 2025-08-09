USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 320.

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

DEFINE BUTTON bt-add-item LABEL "Adicionar" SIZE 12 BY 1.
DEFINE BUTTON bt-mod-item LABEL "Modificar" SIZE 12 BY 1.
DEFINE BUTTON bt-del-item LABEL "Eliminar" SIZE 12 BY 1.
DEFINE BUTTON bt-save-item LABEL "Salvar" SIZE 12 BY 1.
DEFINE BUTTON bt-canc-item LABEL "Cancelar" SIZE 12 BY 1.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.
DEFINE VARIABLE cActionItem AS CHARACTER NO-UNDO.
DEFINE VARIABLE lPedidoNovo AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE iPedidoAtualGlobal AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE iCodigoItem AS INTEGER NO-UNDO.  /* Variável global para uso nos frames */

DEFINE QUERY qPedidos FOR Pedidos, Clientes, Cidades SCROLLING.
DEFINE QUERY qItens FOR Itens, Produtos SCROLLING.

DEFINE BUFFER bufPedidosWork FOR Pedidos.
DEFINE BUFFER bufClientesWork FOR Clientes.
DEFINE BUFFER bufCidadesWork FOR Cidades.
DEFINE BUFFER bufItensWork FOR Itens.
DEFINE BUFFER bufProdutosWork FOR Produtos.

/* Browse para os itens */
DEFINE BROWSE brw-itens QUERY qItens NO-LOCK DISPLAY
    Itens.CodItem COLUMN-LABEL "Item" FORMAT ">>>>9" WIDTH 6
    Itens.CodProduto COLUMN-LABEL "Codigo" FORMAT ">>>>9" WIDTH 8
    Produtos.NomProduto COLUMN-LABEL "Produto" FORMAT "x(30)" WIDTH 35
    Itens.NumQuantidade COLUMN-LABEL "Qtd" FORMAT ">>>>9" WIDTH 8
    Produtos.ValProduto COLUMN-LABEL "Valor Un." FORMAT ">>>>>>9.99" WIDTH 12
    Itens.ValTotal COLUMN-LABEL "Total" FORMAT ">>>>>>9.99" WIDTH 12
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95 BY 10 FIT-LAST-COLUMN.

DEFINE FRAME f-pedidos
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-export SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair SKIP(2)
    Pedidos.CodPedido COLON 20 LABEL "Pedido" FORMAT ">>>>9"
    Pedidos.DatPedido COLON 55 LABEL "Data" FORMAT "99/99/9999" SKIP
    Pedidos.CodCliente COLON 20 LABEL "Cliente" FORMAT ">>>>9"    
    Clientes.NomCliente AT 35 FORMAT "x(40)" NO-LABELS SKIP
    Clientes.CodEndereco COLON 20 LABEL "Endereco" FORMAT "x(50)" SKIP
    Clientes.CodCidade COLON 20 LABEL "Cidade" FORMAT ">>>>9"
    Cidades.NomCidade AT 35 FORMAT "x(30)" NO-LABELS SKIP
    Pedidos.ValPedido COLON 20 LABEL "Total" FORMAT ">>>>>>9.99" SKIP
    Pedidos.Observacao COLON 20 LABEL "Observacao" VIEW-AS EDITOR SIZE 70 BY 3 SCROLLBAR-VERTICAL SKIP(1)
    "ITENS DO PEDIDO:" AT 10 SKIP
    bt-add-item AT 10 bt-mod-item bt-del-item SKIP(1)
    brw-itens AT 10
    WITH SIDE-LABELS THREE-D SIZE 160 BY 40
         VIEW-AS DIALOG-BOX TITLE "Cadastro de Pedidos e Itens".

/* Frame para edição de itens */
DEFINE FRAME f-item
    "EDICAO DE ITEM DO PEDIDO" AT 5 SKIP
    Itens.CodItem COLON 20 LABEL "Codigo Item" FORMAT ">>>>9" SKIP
    Itens.CodProduto COLON 20 LABEL "Codigo Produto" FORMAT ">>>>9"
    "Pressione F4 para listar produtos" AT 35 SKIP
    Produtos.NomProduto COLON 20 FORMAT "x(50)" LABEL "Produto" SKIP
    Produtos.ValProduto COLON 20 LABEL "Valor Unitario" FORMAT ">>>>>>9.99" SKIP
    Itens.NumQuantidade COLON 20 LABEL "Quantidade" FORMAT ">>>>9" SKIP
    Itens.ValTotal COLON 20 LABEL "Valor Total" FORMAT ">>>>>>9.99" SKIP(1)
    bt-save-item AT 15 bt-canc-item
    WITH SIDE-LABELS THREE-D SIZE 75 BY 15 OVERLAY
         VIEW-AS DIALOG-BOX TITLE "Item do Pedido".

DEFINE FRAME f-input-item
    iCodigoItem COLON 15 LABEL "Codigo do Item" FORMAT ">>>>9"
    WITH SIDE-LABELS CENTERED TITLE "Modificar Item" VIEW-AS DIALOG-BOX.

DEFINE FRAME f-input-item-del  
    iCodigoItem COLON 15 LABEL "Codigo do Item" FORMAT ">>>>9"
    WITH SIDE-LABELS CENTERED TITLE "Eliminar Item" VIEW-AS DIALOG-BOX.

/* Eventos de navegação */
ON 'choose' OF bt-pri DO:
    GET FIRST qPedidos.
    RUN piAtualizaContexto.
    RUN piMostra.
    RUN piRefreshItens.
    ASSIGN lPedidoNovo = FALSE.
END.

ON 'choose' OF bt-ant DO:
    GET PREV qPedidos.
    RUN piAtualizaContexto.
    RUN piMostra.
    RUN piRefreshItens.
    ASSIGN lPedidoNovo = FALSE.
END.

ON 'choose' OF bt-prox DO:
    GET NEXT qPedidos.
    RUN piAtualizaContexto.
    RUN piMostra.
    RUN piRefreshItens.
    ASSIGN lPedidoNovo = FALSE.
END.

ON 'choose' OF bt-ult DO:
    GET LAST qPedidos.
    RUN piAtualizaContexto.
    RUN piMostra.
    RUN piRefreshItens.
    ASSIGN lPedidoNovo = FALSE.
END.

/* Evento adicionar pedido */
ON 'choose' OF bt-add DO:
    DEFINE VARIABLE iProxCod AS INTEGER NO-UNDO.
    
    IF cAction = "add" THEN DO:
        MESSAGE "Ja esta em modo de adicao de pedido!" SKIP
                "Complete a operação atual ou cancele."
                VIEW-AS ALERT-BOX WARNING.
        RETURN.
    END.
    
    ASSIGN cAction = "add"
           lPedidoNovo = TRUE.
    
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    CLEAR FRAME f-pedidos.
    
    /* Busca o próximo código */
    RUN piProximoCodigoPedido (OUTPUT iProxCod).
    ASSIGN iPedidoAtualGlobal = iProxCod.
    
    DISPLAY iProxCod @ Pedidos.CodPedido WITH FRAME f-pedidos.
    DISPLAY TODAY @ Pedidos.DatPedido WITH FRAME f-pedidos.
    ASSIGN Pedidos.Observacao:SCREEN-VALUE IN FRAME f-pedidos = "".
    
    ASSIGN Pedidos.CodPedido:SENSITIVE IN FRAME f-pedidos = FALSE.
    
    MESSAGE "Novo pedido iniciado com codigo:" iProxCod SKIP
            "Informe os dados obrigatorios e use 'Salvar' para confirmar."
            VIEW-AS ALERT-BOX INFORMATION.
    
    APPLY "ENTRY" TO Pedidos.CodCliente IN FRAME f-pedidos.
END.

/* Evento modificar pedido */
ON 'choose' OF bt-mod DO:
    IF NOT AVAILABLE Pedidos THEN DO:
        MESSAGE "Selecione um pedido para modificar!" 
                VIEW-AS ALERT-BOX WARNING.
        RETURN.
    END.
    
    ASSIGN cAction = "mod"
           lPedidoNovo = FALSE
           iPedidoAtualGlobal = Pedidos.CodPedido.
           
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    
    ASSIGN Pedidos.CodPedido:SENSITIVE IN FRAME f-pedidos = FALSE.
    
    RUN piMostra.
    APPLY "ENTRY" TO Pedidos.CodCliente IN FRAME f-pedidos.
END.

/* Evento eliminar pedido */
ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iItensExcluidos AS INTEGER NO-UNDO.
    
    IF NOT AVAILABLE Pedidos THEN DO:
        MESSAGE "Selecione um pedido para eliminar!" 
                VIEW-AS ALERT-BOX WARNING.
        RETURN.
    END.
    
    FOR EACH bufItensWork WHERE bufItensWork.CodPedido = Pedidos.CodPedido NO-LOCK:
        iItensExcluidos = iItensExcluidos + 1.
    END.
    
    MESSAGE "Confirma a eliminacao do pedido" Pedidos.CodPedido "?" SKIP
            "Serao eliminados" iItensExcluidos "itens em cascata."
            UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao em Cascata".
                
    IF lConf THEN DO:

        FOR EACH bufItensWork WHERE bufItensWork.CodPedido = Pedidos.CodPedido:
            DELETE bufItensWork.
        END.
        
        FIND bufPedidosWork WHERE bufPedidosWork.CodPedido = Pedidos.CodPedido EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bufPedidosWork THEN DO:
            DELETE bufPedidosWork.
            ASSIGN iPedidoAtualGlobal = 0.
            RUN piOpenQuery.
            RUN piMostra.
            RUN piRefreshItens.
            ASSIGN lPedidoNovo = FALSE.
            
            MESSAGE "Pedido e itens eliminados com sucesso!"
                    VIEW-AS ALERT-BOX INFORMATION.
        END.
    END.
END.

/* Validação do cliente */
ON 'leave' OF Pedidos.CodCliente IN FRAME f-pedidos DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iCliente AS INTEGER NO-UNDO.
    
    ASSIGN iCliente = INTEGER(Pedidos.CodCliente:SCREEN-VALUE IN FRAME f-pedidos) NO-ERROR.
    
    IF iCliente = 0 OR iCliente = ? THEN DO:
        MESSAGE "Codigo do cliente e obrigatorio!"
                VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    
    RUN piValidaClienteCompleto (INPUT iCliente, OUTPUT lValid).
    IF lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    
    IF AVAILABLE bufClientesWork THEN DO:
        DISPLAY bufClientesWork.NomCliente @ Clientes.NomCliente 
                bufClientesWork.CodEndereco @ Clientes.CodEndereco
                bufClientesWork.CodCidade @ Clientes.CodCidade
                WITH FRAME f-pedidos.
        
        IF AVAILABLE bufCidadesWork THEN DO:
            DISPLAY bufCidadesWork.NomCidade @ Cidades.NomCidade WITH FRAME f-pedidos NO-ERROR.
        END.
        ELSE DO:

            DISPLAY "" @ Cidades.NomCidade WITH FRAME f-pedidos NO-ERROR.
        END.
    END.
END.

/* Evento salvar pedido */
ON 'choose' OF bt-save DO:
    DEFINE VARIABLE iCliente AS INTEGER NO-UNDO.
    DEFINE VARIABLE dData AS DATE NO-UNDO.
    DEFINE VARIABLE cObs AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iCodPedido AS INTEGER NO-UNDO.
    
    ASSIGN iCliente = INTEGER(Pedidos.CodCliente:SCREEN-VALUE IN FRAME f-pedidos) NO-ERROR.
    ASSIGN dData = DATE(Pedidos.DatPedido:SCREEN-VALUE IN FRAME f-pedidos) NO-ERROR.
    ASSIGN cObs = Pedidos.Observacao:SCREEN-VALUE IN FRAME f-pedidos.
    ASSIGN iCodPedido = INTEGER(Pedidos.CodPedido:SCREEN-VALUE IN FRAME f-pedidos) NO-ERROR.
    
    RUN piValidaClienteCompleto (INPUT iCliente, OUTPUT lValid).
    IF lValid = NO THEN DO:
        MESSAGE "Cliente deve ser valido para gravar o pedido!"
                VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Pedidos.CodCliente IN FRAME f-pedidos.
        RETURN.
    END.
    
    IF dData = ? THEN DO:
        MESSAGE "Data e obrigatoria!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Pedidos.DatPedido IN FRAME f-pedidos.
        RETURN.
    END.

    IF cAction = "add" AND lPedidoNovo THEN DO:

        CREATE bufPedidosWork.
        ASSIGN bufPedidosWork.CodPedido = iCodPedido
               bufPedidosWork.CodCliente = iCliente
               bufPedidosWork.DatPedido = dData
               bufPedidosWork.ValPedido = 0
               bufPedidosWork.Observacao = cObs
               iPedidoAtualGlobal = iCodPedido.
    END.
    ELSE IF cAction = "mod" THEN DO:

        FIND bufPedidosWork WHERE bufPedidosWork.CodPedido = Pedidos.CodPedido EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bufPedidosWork THEN DO:
            ASSIGN bufPedidosWork.CodCliente = iCliente
                   bufPedidosWork.DatPedido = dData
                   bufPedidosWork.Observacao = cObs.
        END.
    END.
    
    /* Calcula total do pedido */
    RUN piCalculaTotalPedido.
    
    MESSAGE "Pedido gravado com sucesso!"
            VIEW-AS ALERT-BOX INFORMATION.
            
    ASSIGN lPedidoNovo = FALSE.

    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piOpenQuery.
    RUN piMostra.
    RUN piRefreshItens.
END.

/* Evento cancelar pedido */
ON 'choose' OF bt-canc DO:
    ASSIGN lPedidoNovo = FALSE.
    
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piOpenQuery.
    RUN piMostra.
    RUN piRefreshItens.
END.

/* EVENTOS DOS ITENS */
ON 'choose' OF bt-add-item DO:
    DEFINE VARIABLE iProxItem AS INTEGER NO-UNDO.
    
    IF lPedidoNovo THEN DO:
        MESSAGE "Salve o pedido primeiro antes de adicionar itens!"
                VIEW-AS ALERT-BOX WARNING.
        RETURN.
    END.
    
    IF NOT AVAILABLE Pedidos OR iPedidoAtualGlobal = 0 THEN DO:
        MESSAGE "Selecione um pedido valido primeiro!" 
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    RUN piAtualizaContexto.
    
    ASSIGN cActionItem = "add".
    
    RUN piProximoCodigoItemSeguro (INPUT iPedidoAtualGlobal, OUTPUT iProxItem).
    
    CLEAR FRAME f-item ALL.
    DISPLAY iProxItem @ Itens.CodItem WITH FRAME f-item.
    
    DO WITH FRAME f-item:
        ENABLE Itens.CodProduto Itens.NumQuantidade bt-save-item bt-canc-item.
        DISABLE Itens.CodItem Produtos.NomProduto Produtos.ValProduto Itens.ValTotal.
        
        ASSIGN Itens.CodProduto:SENSITIVE = TRUE
               Itens.NumQuantidade:SENSITIVE = TRUE
               bt-save-item:SENSITIVE = TRUE
               bt-canc-item:SENSITIVE = TRUE.
    END.
    
    VIEW FRAME f-item.
    APPLY "ENTRY" TO Itens.CodProduto IN FRAME f-item.
    WAIT-FOR CHOOSE OF bt-save-item OR CHOOSE OF bt-canc-item OR WINDOW-CLOSE OF FRAME f-item.
    
    HIDE FRAME f-item.
END.

/* Modificar item com seleção por código */
ON 'choose' OF bt-mod-item DO:
    DEFINE VARIABLE iCodigoItem AS INTEGER NO-UNDO.
    DEFINE VARIABLE lItemEncontrado AS LOGICAL NO-UNDO INITIAL FALSE.
    DEFINE VARIABLE lConfirma AS LOGICAL NO-UNDO.
    
    IF NOT AVAILABLE Pedidos OR iPedidoAtualGlobal = 0 THEN DO:
        MESSAGE "Selecione um pedido valido primeiro!" VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    RUN piAtualizaContexto.
    
    UPDATE iCodigoItem 
        WITH FRAME f-input-item
        TITLE "Modificar Item - Digite o codigo do item:".
    
    IF iCodigoItem = 0 OR iCodigoItem = ? THEN DO:
        MESSAGE "Codigo do item é obrigatorio!" VIEW-AS ALERT-BOX WARNING.
        RETURN.
    END.
    
    FIND FIRST bufItensWork WHERE bufItensWork.CodPedido = iPedidoAtualGlobal 
                               AND bufItensWork.CodItem = iCodigoItem 
                               NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE bufItensWork THEN DO:
        MESSAGE "Item" iCodigoItem "nao encontrado no pedido" iPedidoAtualGlobal "!" SKIP
                "Verifique o codigo informado."
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    FIND FIRST bufProdutosWork WHERE bufProdutosWork.CodProduto = bufItensWork.CodProduto 
                                  NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE bufProdutosWork THEN DO:
        MESSAGE "ERRO: Produto do item nao encontrado!" SKIP
                "Item pode estar com dados inconsistentes."
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    MESSAGE "Item encontrado:" SKIP
            "Codigo:" bufItensWork.CodItem SKIP
            "Produto:" bufProdutosWork.NomProduto SKIP
            "Quantidade atual:" bufItensWork.NumQuantidade SKIP
            "Valor atual: R$" bufItensWork.ValTotal SKIP(1)
            "Confirma a modificacao deste item?"
            UPDATE lConfirma
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Confirmar Modificacao".
    
    IF NOT lConfirma THEN RETURN.
    
    FIND FIRST Itens WHERE Itens.CodPedido = bufItensWork.CodPedido 
                       AND Itens.CodItem = bufItensWork.CodItem NO-LOCK NO-ERROR.
    
    FIND FIRST Produtos WHERE Produtos.CodProduto = bufItensWork.CodProduto NO-LOCK NO-ERROR.
    
    ASSIGN cActionItem = "mod".
    
    CLEAR FRAME f-item ALL.
    DISPLAY bufItensWork.CodItem @ Itens.CodItem 
            bufItensWork.CodProduto @ Itens.CodProduto 
            bufProdutosWork.NomProduto @ Produtos.NomProduto
            bufProdutosWork.ValProduto @ Produtos.ValProduto 
            bufItensWork.NumQuantidade @ Itens.NumQuantidade 
            bufItensWork.ValTotal @ Itens.ValTotal
            WITH FRAME f-item.
            
    DO WITH FRAME f-item:
        ENABLE Itens.CodProduto Itens.NumQuantidade bt-save-item bt-canc-item.
        DISABLE Itens.CodItem Produtos.NomProduto Produtos.ValProduto Itens.ValTotal.
        
        ASSIGN Itens.CodProduto:SENSITIVE = TRUE
               Itens.NumQuantidade:SENSITIVE = TRUE
               bt-save-item:SENSITIVE = TRUE
               bt-canc-item:SENSITIVE = TRUE.
    END.
    
    VIEW FRAME f-item.
    APPLY "ENTRY" TO Itens.CodProduto IN FRAME f-item.
    WAIT-FOR CHOOSE OF bt-save-item OR CHOOSE OF bt-canc-item OR WINDOW-CLOSE OF FRAME f-item.
    
    HIDE FRAME f-item.
END.

/* Eliminar item com seleção por código */
ON 'choose' OF bt-del-item DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iCodigoItem AS INTEGER NO-UNDO.
    DEFINE VARIABLE lItemEncontrado AS LOGICAL NO-UNDO INITIAL FALSE.
    
    IF NOT AVAILABLE Pedidos OR iPedidoAtualGlobal = 0 THEN DO:
        MESSAGE "Selecione um pedido valido primeiro!" VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    RUN piAtualizaContexto.
    
    UPDATE iCodigoItem 
        WITH FRAME f-input-item-del
        TITLE "Eliminar Item - Digite o codigo do item:".
    
    IF iCodigoItem = 0 OR iCodigoItem = ? THEN DO:
        MESSAGE "Codigo do item e obrigatório!" VIEW-AS ALERT-BOX WARNING.
        RETURN.
    END.
    
    FIND FIRST bufItensWork WHERE bufItensWork.CodPedido = iPedidoAtualGlobal 
                               AND bufItensWork.CodItem = iCodigoItem 
                               NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE bufItensWork THEN DO:
        MESSAGE "Item" iCodigoItem "nao encontrado no pedido" iPedidoAtualGlobal "!" SKIP
                "Verifique o codigo informado."
                VIEW-AS ALERT-BOX ERROR.
        RETURN.
    END.
    
    FIND FIRST bufProdutosWork WHERE bufProdutosWork.CodProduto = bufItensWork.CodProduto 
                                  NO-LOCK NO-ERROR.
    
    MESSAGE "Item encontrado:" SKIP
            "Codigo:" bufItensWork.CodItem SKIP
            "Produto:" (IF AVAILABLE bufProdutosWork THEN bufProdutosWork.NomProduto ELSE "Produto nao encontrado") SKIP
            "Quantidade:" bufItensWork.NumQuantidade SKIP
            "Valor: R$" bufItensWork.ValTotal SKIP(1)
            "CONFIRMA A ELIMINACAO DEFINITIVA deste item?"
            UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                TITLE "Eliminacao de Item".
                
    IF lConf THEN DO:

        FIND bufItensWork WHERE bufItensWork.CodPedido = iPedidoAtualGlobal 
                             AND bufItensWork.CodItem = iCodigoItem 
                             EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE bufItensWork THEN DO:

            DEFINE VARIABLE cProdutoEliminado AS CHARACTER NO-UNDO.
            DEFINE VARIABLE dValorEliminado AS DECIMAL NO-UNDO.
            
            ASSIGN cProdutoEliminado = (IF AVAILABLE bufProdutosWork THEN bufProdutosWork.NomProduto ELSE "Item " + STRING(iCodigoItem))
                   dValorEliminado = bufItensWork.ValTotal.
            
            DELETE bufItensWork.
            
            RUN piCalculaTotalPedido.
            RUN piRefreshItens.
            RUN piMostra.
            
            MESSAGE "Item eliminado com sucesso!" SKIP
                    "Item:" iCodigoItem SKIP
                    "Produto:" cProdutoEliminado SKIP
                    "Valor eliminado: R$" dValorEliminado
                    VIEW-AS ALERT-BOX INFORMATION.
        END.
        ELSE DO:
            MESSAGE "ERRO: Nao foi possível obter acesso exclusivo ao item!" SKIP
                    "O item pode estar sendo usado por outro processo."
                    VIEW-AS ALERT-BOX ERROR.
        END.
    END.
END.

/* Validação do produto no item */
ON 'leave' OF Itens.CodProduto IN FRAME f-item DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iProd AS INTEGER NO-UNDO.
    
    ASSIGN iProd = INTEGER(Itens.CodProduto:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    
    IF iProd = 0 OR iProd = ? THEN DO:
        MESSAGE "Codigo do produto e obrigatorio!"
                VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    
    RUN piValidaProduto (INPUT iProd, OUTPUT lValid).
    IF lValid = NO THEN DO:
        RETURN NO-APPLY.
    END.
    
    DISPLAY bufProdutosWork.NomProduto @ Produtos.NomProduto 
            bufProdutosWork.ValProduto @ Produtos.ValProduto 
            WITH FRAME f-item.
    RUN piCalculaItemTotal.
END.

/* F4 para listar produtos */
ON 'F4' OF Itens.CodProduto IN FRAME f-item DO:
    RUN piListaProdutos.
END.

ON 'leave' OF Itens.NumQuantidade IN FRAME f-item DO:
    RUN piCalculaItemTotal.
END.

/* Salvar item */
ON 'choose' OF bt-save-item DO:
    DEFINE VARIABLE iProd AS INTEGER NO-UNDO.
    DEFINE VARIABLE iQtd AS INTEGER NO-UNDO.
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iItemAtual AS INTEGER NO-UNDO.
    DEFINE VARIABLE lItemExiste AS LOGICAL NO-UNDO.
    
    ASSIGN iProd = INTEGER(Itens.CodProduto:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    ASSIGN iQtd = INTEGER(Itens.NumQuantidade:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    ASSIGN iItemAtual = INTEGER(Itens.CodItem:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    
    RUN piValidaProduto (INPUT iProd, OUTPUT lValid).
    IF lValid = NO THEN DO:
        MESSAGE "Produto deve ser valido para gravar o item!"
                VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Itens.CodProduto IN FRAME f-item.
        RETURN.
    END.
    
    IF iQtd <= 0 OR iQtd = ? THEN DO:
        MESSAGE "Quantidade deve ser maior que zero!" VIEW-AS ALERT-BOX ERROR.
        APPLY "ENTRY" TO Itens.NumQuantidade IN FRAME f-item.
        RETURN.
    END.
    
    IF cActionItem = "add" THEN DO:

        REPEAT:
            FIND FIRST bufItensWork WHERE bufItensWork.CodPedido = iPedidoAtualGlobal
                                       AND bufItensWork.CodItem = iItemAtual
                                       NO-LOCK NO-ERROR.
            
            IF NOT AVAILABLE bufItensWork THEN DO:
                LEAVE.
            END.
            ELSE DO:
                ASSIGN iItemAtual = iItemAtual + 1.
            END.
            
            IF iItemAtual > 9999 THEN DO:
                MESSAGE "ERRO: Nao foi possível gerar codigo de item!" VIEW-AS ALERT-BOX ERROR.
                RETURN.
            END.
        END.
        
        CREATE bufItensWork.
        ASSIGN bufItensWork.CodPedido = iPedidoAtualGlobal
               bufItensWork.CodItem = iItemAtual
               bufItensWork.CodProduto = iProd
               bufItensWork.NumQuantidade = iQtd
               bufItensWork.ValTotal = bufProdutosWork.ValProduto * iQtd.
    END.
    ELSE IF cActionItem = "mod" THEN DO:

        FIND bufItensWork WHERE bufItensWork.CodPedido = iPedidoAtualGlobal
                             AND bufItensWork.CodItem = iItemAtual 
                             EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bufItensWork THEN DO:
            ASSIGN bufItensWork.CodProduto = iProd
                   bufItensWork.NumQuantidade = iQtd
                   bufItensWork.ValTotal = bufProdutosWork.ValProduto * iQtd.
        END.
    END.
    
    MESSAGE "Item gravado com sucesso!" SKIP
            "Item:" iItemAtual SKIP
            "Pedido:" iPedidoAtualGlobal
            VIEW-AS ALERT-BOX INFORMATION.
    
    RUN piCalculaTotalPedido.
    RUN piRefreshItens.
    RUN piMostra.
    
    HIDE FRAME f-item.
END.

/* Cancelar item */
ON 'choose' OF bt-canc-item DO:
    HIDE FRAME f-item.
END.

/* Evento exportar */
ON CHOOSE OF bt-export DO:
    RUN piExportar.
END.

/* Inicialização */
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

ENABLE ALL WITH FRAME f-pedidos.
WAIT-FOR WINDOW-CLOSE OF FRAME f-pedidos.

PROCEDURE piAtualizaContexto:
    IF AVAILABLE Pedidos THEN DO:
        ASSIGN iPedidoAtualGlobal = Pedidos.CodPedido.
    END.
    ELSE DO:
        ASSIGN iPedidoAtualGlobal = 0.
    END.
END PROCEDURE.

PROCEDURE piMostra:
    IF AVAILABLE Pedidos THEN DO:

        DISPLAY Pedidos.CodPedido Pedidos.CodCliente 
                Clientes.NomCliente Clientes.CodEndereco
                Clientes.CodCidade
                Pedidos.DatPedido Pedidos.ValPedido 
                Pedidos.Observacao
                WITH FRAME f-pedidos.
        
        IF AVAILABLE Cidades THEN DO:
            DISPLAY Cidades.NomCidade WITH FRAME f-pedidos.
        END.
        ELSE DO:
            DISPLAY "Cidade nao cadastrada" @ Cidades.NomCidade WITH FRAME f-pedidos NO-ERROR.
        END.
    END.
    ELSE DO:
        CLEAR FRAME f-pedidos.
        ASSIGN Pedidos.Observacao:SCREEN-VALUE IN FRAME f-pedidos = "".
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    
    IF AVAILABLE Pedidos THEN DO:
        ASSIGN rRecord = ROWID(Pedidos).
    END.
    
    OPEN QUERY qPedidos 
        FOR EACH Pedidos NO-LOCK,
            FIRST Clientes WHERE Clientes.CodCliente = Pedidos.CodCliente NO-LOCK,
            FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK OUTER-JOIN.
    
    REPOSITION qPedidos TO ROWID rRecord NO-ERROR.
    
    RUN piAtualizaContexto.
END PROCEDURE.

PROCEDURE piRefreshItens:
    IF AVAILABLE Pedidos AND iPedidoAtualGlobal > 0 THEN DO:
        OPEN QUERY qItens 
            FOR EACH Itens WHERE Itens.CodPedido = iPedidoAtualGlobal NO-LOCK,
                FIRST Produtos WHERE Produtos.CodProduto = Itens.CodProduto NO-LOCK.
    END.
    ELSE DO:
        CLOSE QUERY qItens.
    END.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME f-pedidos:
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
               bt-canc:SENSITIVE = NOT pEnable
               bt-add-item:SENSITIVE = pEnable
               bt-mod-item:SENSITIVE = pEnable
               bt-del-item:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.

    DO WITH FRAME f-pedidos:
        ASSIGN Pedidos.CodPedido:SENSITIVE = FALSE  /* Sempre desabilitado */
               Pedidos.CodCliente:SENSITIVE = pEnable
               Pedidos.DatPedido:SENSITIVE = pEnable
               Pedidos.Observacao:SENSITIVE = pEnable.
        
        ASSIGN Clientes.NomCliente:SENSITIVE = FALSE
               Clientes.CodEndereco:SENSITIVE = FALSE
               Clientes.CodCidade:SENSITIVE = FALSE
               Cidades.NomCidade:SENSITIVE = FALSE.
    END.
END PROCEDURE.

PROCEDURE piValidaClienteCompleto:
    DEFINE INPUT PARAMETER pCodCliente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
  
    FIND FIRST bufClientesWork WHERE bufClientesWork.CodCliente = pCodCliente NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bufClientesWork THEN DO:
        MESSAGE "Cliente" pCodCliente "nao existe!" SKIP
                "Informe um codigo de cliente valido."
                VIEW-AS ALERT-BOX ERROR TITLE "Cliente Invalido".
        ASSIGN pValid = NO.
        RETURN.
    END.
    
    IF bufClientesWork.CodCidade <> 0 AND bufClientesWork.CodCidade <> ? THEN DO:
        FIND FIRST bufCidadesWork WHERE bufCidadesWork.CodCidade = bufClientesWork.CodCidade NO-LOCK NO-ERROR.
        IF NOT AVAILABLE bufCidadesWork THEN DO:
            MESSAGE "AVISO: Cliente" pCodCliente "possui codigo de cidade invalido!" SKIP
                    "Cidade:" bufClientesWork.CodCidade "nao existe no cadastro." SKIP(1)
                    "O pedido pode ser salvo, mas a cidade nao sera exibida." SKIP
                    "Corrija o cadastro do cliente posteriormente."
                    VIEW-AS ALERT-BOX WARNING TITLE "Cidade Invalida".
        END.
    END.
    ELSE DO:
        MESSAGE "AVISO: Cliente" pCodCliente "nao possui cidade cadastrada!" SKIP
                "O pedido pode ser salvo normalmente."
                VIEW-AS ALERT-BOX WARNING TITLE "Cliente sem Cidade".
    END.
    
    ASSIGN pValid = YES.
END PROCEDURE.

PROCEDURE piValidaCliente:
    DEFINE INPUT PARAMETER pCodCliente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    
    RUN piValidaClienteCompleto (INPUT pCodCliente, OUTPUT pValid).
END PROCEDURE.

PROCEDURE piValidaProduto:
    DEFINE INPUT PARAMETER pCodProduto AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
  
    FIND FIRST bufProdutosWork WHERE bufProdutosWork.CodProduto = pCodProduto NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bufProdutosWork THEN DO:
        MESSAGE "Produto" pCodProduto "nao existe!" SKIP
                "Informe um codigo de produto valido ou pressione F4."
                VIEW-AS ALERT-BOX ERROR TITLE "Produto Invalido".
        ASSIGN pValid = NO.
    END.
    ELSE 
       ASSIGN pValid = YES.
END PROCEDURE.

PROCEDURE piCalculaItemTotal:
    DEFINE VARIABLE iQtd AS INTEGER NO-UNDO.
    DEFINE VARIABLE dValor AS DECIMAL NO-UNDO.
    
    ASSIGN iQtd = INTEGER(Itens.NumQuantidade:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    ASSIGN dValor = DECIMAL(Produtos.ValProduto:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    
    IF iQtd > 0 AND dValor > 0 THEN
        DISPLAY iQtd * dValor @ Itens.ValTotal WITH FRAME f-item.
    ELSE
        DISPLAY 0 @ Itens.ValTotal WITH FRAME f-item.
END PROCEDURE.

PROCEDURE piCalculaTotalPedido:
    DEFINE VARIABLE dTotal AS DECIMAL NO-UNDO INITIAL 0.
    
    IF iPedidoAtualGlobal > 0 THEN DO:
        FIND bufPedidosWork WHERE bufPedidosWork.CodPedido = iPedidoAtualGlobal EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE bufPedidosWork THEN DO:

            FOR EACH bufItensWork WHERE bufItensWork.CodPedido = iPedidoAtualGlobal NO-LOCK:
                ASSIGN dTotal = dTotal + bufItensWork.ValTotal.
            END.
            ASSIGN bufPedidosWork.ValPedido = dTotal.
        END.
    END.
END PROCEDURE.

PROCEDURE piProximoCodigoPedido:
    DEFINE OUTPUT PARAMETER pCodigo AS INTEGER NO-UNDO.
    
    FOR EACH bufPedidosWork NO-LOCK BY bufPedidosWork.CodPedido DESCENDING:
        ASSIGN pCodigo = bufPedidosWork.CodPedido + 1.
        LEAVE.
    END.
    
    IF pCodigo = 0 OR pCodigo = ? THEN
        ASSIGN pCodigo = 1.
END PROCEDURE.

PROCEDURE piProximoCodigoItemSeguro:
    DEFINE INPUT PARAMETER pCodPedido AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pCodigo AS INTEGER NO-UNDO.
    DEFINE VARIABLE iMaior AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE iTentativa AS INTEGER NO-UNDO.
    DEFINE VARIABLE lFound AS LOGICAL NO-UNDO.
    
    FOR EACH bufItensWork WHERE bufItensWork.CodPedido = pCodPedido NO-LOCK
        BY bufItensWork.CodItem DESCENDING:
        ASSIGN iMaior = bufItensWork.CodItem.
        LEAVE.
    END.
    
    ASSIGN iTentativa = iMaior + 1.
    
    REPEAT:
        FIND FIRST bufItensWork WHERE bufItensWork.CodPedido = pCodPedido 
                                   AND bufItensWork.CodItem = iTentativa 
                                   NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE bufItensWork THEN DO:

            ASSIGN pCodigo = iTentativa
                   lFound = TRUE.
            LEAVE.
        END.
        ELSE DO:

            ASSIGN iTentativa = iTentativa + 1.
        END.
        
        IF iTentativa > (iMaior + 100) THEN DO:
            MESSAGE "ERRO CRITICO: Sistema nao conseguiu gerar codigo de item!" SKIP
                    "Pedido:" pCodPedido SKIP
                    "Ultimo código tentado:" iTentativa
                    VIEW-AS ALERT-BOX ERROR.
            ASSIGN pCodigo = 99999.  /* Valor de emergência */
            LEAVE.
        END.
    END.
    
    IF NOT lFound OR pCodigo = 0 OR pCodigo = ? THEN DO:
        ASSIGN pCodigo = 1.
    END.
    
END PROCEDURE.

PROCEDURE piListaProdutos:
    DEFINE VARIABLE iProdSelecionado AS INTEGER NO-UNDO.
    DEFINE VARIABLE cLista AS CHARACTER NO-UNDO.
    
    cLista = "Produtos Disponiveis:" + CHR(10) + CHR(10).
    FOR EACH bufProdutosWork NO-LOCK BY bufProdutosWork.CodProduto:
        cLista = cLista + STRING(bufProdutosWork.CodProduto, ">>>>9") + " - " + 
                 bufProdutosWork.NomProduto + " - R$ " + 
                 STRING(bufProdutosWork.ValProduto, ">>>>>>9.99") + CHR(10).
    END.
    
    cLista = cLista + CHR(10) + "Digite o codigo do produto desejado:".
    
    MESSAGE cLista VIEW-AS ALERT-BOX INFORMATION TITLE "Lista de Produtos".
END PROCEDURE.

PROCEDURE piExportar:
    DEFINE VARIABLE cArqCSV AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArqJSON AS CHARACTER NO-UNDO.
    DEFINE VARIABLE aPedidos AS JsonArray NO-UNDO.
    DEFINE VARIABLE oPedido AS JsonObject NO-UNDO.
    DEFINE VARIABLE aItens AS JsonArray NO-UNDO.
    DEFINE VARIABLE oItem AS JsonObject NO-UNDO.
    DEFINE VARIABLE iTotalPedidos AS INTEGER NO-UNDO.
    DEFINE VARIABLE iTotalItens AS INTEGER NO-UNDO.
    
    ASSIGN cArqCSV = "c:\dados\pedidos.csv"
           cArqJSON = "c:\dados\pedidos.json".
    
    FOR EACH bufPedidosWork NO-LOCK:
        iTotalPedidos = iTotalPedidos + 1.
        FOR EACH bufItensWork WHERE bufItensWork.CodPedido = bufPedidosWork.CodPedido NO-LOCK:
            iTotalItens = iTotalItens + 1.
        END.
    END.
    
    /* Verifica se o diretório existe */
    FILE-INFO:FILE-NAME = "c:\dados".
    IF FILE-INFO:FULL-PATHNAME = ? THEN DO:
        MESSAGE "Diretorio c:\dados nao existe!" SKIP
                "Criando diretório..." VIEW-AS ALERT-BOX WARNING.
        OS-CREATE-DIR "c:\dados".
    END.
    
    OUTPUT TO VALUE(cArqCSV).
    PUT UNFORMATTED "CodPedido;CodCliente;Cliente;Endereco;Cidade;Data;Total;Observacao" SKIP.
    FOR EACH bufPedidosWork NO-LOCK,
        FIRST bufClientesWork WHERE bufClientesWork.CodCliente = bufPedidosWork.CodCliente NO-LOCK:
        
        FIND FIRST bufCidadesWork WHERE bufCidadesWork.CodCidade = bufClientesWork.CodCidade NO-LOCK NO-ERROR.
        
        PUT UNFORMATTED 
            bufPedidosWork.CodPedido ";"
            bufPedidosWork.CodCliente ";"
            bufClientesWork.NomCliente ";"
            bufClientesWork.CodEndereco ";"
            (IF AVAILABLE bufCidadesWork THEN bufCidadesWork.NomCidade ELSE "CIDADE INEXISTENTE") ";"
            bufPedidosWork.DatPedido ";"
            bufPedidosWork.ValPedido ";"
            bufPedidosWork.Observacao SKIP.
    END.
    OUTPUT CLOSE.
    
    aPedidos = NEW JsonArray().
    FOR EACH bufPedidosWork NO-LOCK,
        FIRST bufClientesWork WHERE bufClientesWork.CodCliente = bufPedidosWork.CodCliente NO-LOCK:
        
        FIND FIRST bufCidadesWork WHERE bufCidadesWork.CodCidade = bufClientesWork.CodCidade NO-LOCK NO-ERROR.
        
        oPedido = NEW JsonObject().
        oPedido:add("codigo", bufPedidosWork.CodPedido).
        oPedido:add("codCliente", bufPedidosWork.CodCliente).
        oPedido:add("cliente", bufClientesWork.NomCliente).
        oPedido:add("endereco", bufClientesWork.CodEndereco).
        oPedido:add("cidade", IF AVAILABLE bufCidadesWork THEN bufCidadesWork.NomCidade ELSE "CIDADE INEXISTENTE").
        oPedido:add("data", STRING(bufPedidosWork.DatPedido)).
        oPedido:add("total", bufPedidosWork.ValPedido).
        oPedido:add("observacao", bufPedidosWork.Observacao).
        
        aItens = NEW JsonArray().
        FOR EACH bufItensWork WHERE bufItensWork.CodPedido = bufPedidosWork.CodPedido NO-LOCK,
            FIRST bufProdutosWork WHERE bufProdutosWork.CodProduto = bufItensWork.CodProduto NO-LOCK:
            oItem = NEW JsonObject().
            oItem:add("item", bufItensWork.CodItem).
            oItem:add("codProduto", bufItensWork.CodProduto).
            oItem:add("produto", bufProdutosWork.NomProduto).
            oItem:add("quantidade", bufItensWork.NumQuantidade).
            oItem:add("valorUnitario", bufProdutosWork.ValProduto).
            oItem:add("valorTotal", bufItensWork.ValTotal).
            aItens:add(oItem).
        END.
        oPedido:add("itens", aItens).
        aPedidos:add(oPedido).
    END.
    
    /* Salva o JSON */
    aPedidos:WriteFile(INPUT cArqJSON, INPUT YES, INPUT "utf-8") NO-ERROR.
    
    MESSAGE "EXPORTACAO CONCLUIDA COM SUCESSO!" SKIP(1)
            "Arquivos gerados:" SKIP
            "- CSV: " cArqCSV SKIP 
            "- JSON: " cArqJSON SKIP(1)
            "Totais exportados:" SKIP
            "- Pedidos: " iTotalPedidos SKIP
            "- Itens: " iTotalItens
            VIEW-AS ALERT-BOX INFORMATION TITLE "Exportacao".
            
END PROCEDURE.