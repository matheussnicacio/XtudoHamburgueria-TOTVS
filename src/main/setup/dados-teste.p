CONNECT VALUE("c:\dados\xtudo2.db") -1 NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "Erro ao conectar com o banco de dados c:\dados\xtudo2.db" 
            VIEW-AS ALERT-BOX ERROR.
    RETURN.
END.

CREATE Cidades.
ASSIGN Cidades.CodCidade = 1
       Cidades.NomCidade = "São Paulo"
       Cidades.CodUF = "SP".

CREATE Cidades.
ASSIGN Cidades.CodCidade = 2
       Cidades.NomCidade = "Joinville"
       Cidades.CodUF = "SC".

CREATE Cidades.
ASSIGN Cidades.CodCidade = 3
       Cidades.NomCidade = "Araquari"
       Cidades.CodUF = "SC".

/* Inserir Produtos */
CREATE Produtos.
ASSIGN Produtos.CodProduto = 1
       Produtos.NomProduto = "X-Salada"
       Produtos.ValProduto = 8.50.

CREATE Produtos.
ASSIGN Produtos.CodProduto = 2
       Produtos.NomProduto = "Hambúrguer Simples"
       Produtos.ValProduto = 6.00.

CREATE Produtos.
ASSIGN Produtos.CodProduto = 3
       Produtos.NomProduto = "X-Burguer"
       Produtos.ValProduto = 10.00.

CREATE Produtos.
ASSIGN Produtos.CodProduto = 4
       Produtos.NomProduto = "X-Bacon"
       Produtos.ValProduto = 12.50.

CREATE Produtos.
ASSIGN Produtos.CodProduto = 5
       Produtos.NomProduto = "Refrigerante"
       Produtos.ValProduto = 3.50.

/* Inserir Clientes */
CREATE Clientes.
ASSIGN Clientes.CodCliente = 1
       Clientes.NomCliente = "Maria Silva"
       Clientes.CodEndereco = "Rua Guanabara 50"
       Clientes.CodCidade = 2
       Clientes.Observacao = "Cliente VIP".

CREATE Clientes.
ASSIGN Clientes.CodCliente = 2
       Clientes.NomCliente = "João Santos"
       Clientes.CodEndereco = "Av. Santos Dumont 1200"
       Clientes.CodCidade = 2
       Clientes.Observacao = "".

CREATE Clientes.
ASSIGN Clientes.CodCliente = 3
       Clientes.NomCliente = "Pedro Oliveira"
       Clientes.CodEndereco = "Av. Getúlio Vargas 300"
       Clientes.CodCidade = 2
       Clientes.Observacao = "".

CREATE Clientes.
ASSIGN Clientes.CodCliente = 4
       Clientes.NomCliente = "Cecília Costa"
       Clientes.CodEndereco = "Rua Miosotis 545"
       Clientes.CodCidade = 3
       Clientes.Observacao = "Cliente especial".

CREATE Pedidos.
ASSIGN Pedidos.CodPedido = 1
       Pedidos.CodCliente = 1
       Pedidos.DatPedido = TODAY
       Pedidos.ValPedido = 21.00
       Pedidos.Observacao = "Entrega rápida".

CREATE Pedidos.
ASSIGN Pedidos.CodPedido = 2
       Pedidos.CodCliente = 2
       Pedidos.DatPedido = TODAY - 1
       Pedidos.ValPedido = 56.00
       Pedidos.Observacao = "".

CREATE Itens.
ASSIGN Itens.CodPedido = 1
       Itens.CodItem = 1
       Itens.CodProduto = 1
       Itens.NumQuantidade = 2
       Itens.ValTotal = 17.00.

CREATE Itens.
ASSIGN Itens.CodPedido = 1
       Itens.CodItem = 2
       Itens.CodProduto = 5
       Itens.NumQuantidade = 1
       Itens.ValTotal = 3.50.

CREATE Itens.
ASSIGN Itens.CodPedido = 2
       Itens.CodItem = 1
       Itens.CodProduto = 3
       Itens.NumQuantidade = 5
       Itens.ValTotal = 50.00.

CREATE Itens.
ASSIGN Itens.CodPedido = 2
       Itens.CodItem = 2
       Itens.CodProduto = 2
       Itens.NumQuantidade = 1
       Itens.ValTotal = 6.00.

CURRENT-VALUE(seqCidade) = 3.
CURRENT-VALUE(seqProduto) = 5.
CURRENT-VALUE(seqCliente) = 4.
CURRENT-VALUE(seqPedido) = 2.

MESSAGE "Dados de teste inseridos com sucesso!" VIEW-AS ALERT-BOX INFORMATION.

DISCONNECT VALUE("c:\dados\xtudo2.db").