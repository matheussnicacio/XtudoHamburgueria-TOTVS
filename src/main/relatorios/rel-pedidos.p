DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
DEFINE VARIABLE dTotalPedido AS DECIMAL NO-UNDO.

/* Gera o arquivo na pasta de dados */
ASSIGN cArq = "c:\dados\rel-pedidos.txt".

OUTPUT TO VALUE(cArq).

FOR EACH Pedidos NO-LOCK,
    FIRST Clientes WHERE Clientes.CodCliente = Pedidos.CodCliente NO-LOCK,
    FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK
    BY Pedidos.CodPedido:
    
    PUT "Pedido" AT 50 SKIP.
    PUT "Pedido: " Pedidos.CodPedido FORMAT ">>>>9" AT 0 SKIP.
    PUT "Data:" AT 0.
    PUT Pedidos.DatPedido FORMAT "99/99/9999" AT 0 SKIP.
    PUT "Nome: " Clientes.CodCliente FORMAT ">>>>9" "-" Clientes.NomCliente AT 0 SKIP.      
    PUT "Endereco: " AT 1.
    PUT (Clientes.CodEndereco).  
    PUT  " / ".
    PUT TRIM(Cidades.NomCidade).
    PUT "-".
    PUT (Cidades.CodUF) SKIP.   
    PUT "Observacao:"(Pedidos.Observacao) AT 0 SKIP(2).
    
    PUT "Item Produto" AT 1.
    PUT "Quantidade" AT 40.    
    PUT "Valor" AT 60 SKIP.    
    PUT "Total" AT 1 SKIP.
    PUT "--------------------------------------------------------------------------------------------------------" AT 1.              
    
    
    /* Lista dos itens do pedido */
    ASSIGN dTotalPedido = 0.
    FOR EACH Itens WHERE Itens.CodPedido = Pedidos.CodPedido NO-LOCK,
        FIRST Produtos WHERE Produtos.CodProduto = Itens.CodProduto NO-LOCK:
        
        PUT Itens.CodItem FORMAT ">9" AT 1.
        PUT Produtos.CodProduto FORMAT ">9" "-" Produtos.NomProduto FORMAT "x(25)" AT 5.
        PUT Itens.NumQuantidade FORMAT ">>>>>9" AT 45.
        PUT Produtos.ValProduto FORMAT ">>>>>>9.99" AT 60 SKIP.
        
        PUT Itens.ValTotal FORMAT ">>>>>>9.99" AT 1 SKIP.
            
        ASSIGN dTotalPedido = dTotalPedido + Itens.ValTotal.
    END.
    
    PUT "Total Pedido =" AT 40.
    PUT dTotalPedido FORMAT ">>>>>>9.99" SKIP(2).
    
    PUT SKIP(2).
END.

OUTPUT CLOSE.

OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).

MESSAGE "Relatorio gerado em:" SKIP cArq 
        VIEW-AS ALERT-BOX INFORMATION.