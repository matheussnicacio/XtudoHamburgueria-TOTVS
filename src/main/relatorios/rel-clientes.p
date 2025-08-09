DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.

DEFINE FRAME f-cab HEADER
    SPACE(35) "Relatório de Clientes" SKIP(1)
    "Codigo Nome" SPACE(8) "Endereco" SPACE(20) "Cidade" SPACE(8) "Observação" SKIP
    "------- ----------- ------------------------- ----------- -----------" SKIP
    WITH PAGE-TOP WIDTH 120 NO-BOX STREAM-IO.
    
DEFINE FRAME f-dados
    Clientes.CodCliente COLUMN-LABEL "" FORMAT ">>>>9" SPACE(1)
    Clientes.NomCliente COLUMN-LABEL "" FORMAT "x(10)" SPACE(1)
    Clientes.CodEndereco COLUMN-LABEL "" FORMAT "x(25)" SPACE(1)
    Cidades.NomCidade COLUMN-LABEL "" FORMAT "x(10)" SPACE(1)
    Clientes.Observacao COLUMN-LABEL "" FORMAT "x(20)"
    WITH DOWN WIDTH 120 NO-LABELS.

ASSIGN cArq = "c:\dados\rel-clientes.txt".
OUTPUT TO VALUE(cArq) PAGE-SIZE 60 PAGED.

VIEW FRAME f-cab.

FOR EACH Clientes NO-LOCK,
    FIRST Cidades WHERE Cidades.CodCidade = Clientes.CodCidade NO-LOCK
    BY Clientes.NomCliente:
    
    DISPLAY 
        Clientes.CodCliente 
        Clientes.NomCliente 
        Clientes.CodEndereco
        Cidades.NomCidade
        Clientes.Observacao
        WITH FRAME f-dados.
END.

OUTPUT CLOSE.

OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
MESSAGE "Relatorio gerado em:" SKIP cArq VIEW-AS ALERT-BOX INFORMATION.