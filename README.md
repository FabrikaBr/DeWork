# DeWork
 This is the Blockchain dedicated to the DeWork protocol, 
proof of work will be implemented initially due to reduced demand, 
as soon as we reach maturity level 2, 
tests will be carried out and the migration to proof of stake will be available. 

O contrato DeWork acima tem como objetivo fornecer uma estrutura operacional para a criação e execução de contratos inteligentes. O contrato armazena informações sobre os contratos criados, como o objetivo, o valor alocado, o dono do contrato, o executor e o curador.

Os contratos são criados utilizando a função createContract, que recebe como parâmetro o objetivo do contrato e o valor alocado. O valor alocado é adicionado ao fundo garantidor (poolBalance) do contrato.

Os contratos podem ser executados utilizando a função executeContract, que permite que o dono do contrato execute-o. Para que um contrato seja executado, ele deve estar totalmente financiado (ou seja, o valor total deve estar disponível na pool operacional) e deve ter sido auditado pelo curador designado.

Para executar um contrato, o dono do contrato deve chamar a função executeContract passando o endereço do contrato como argumento. A função executeContract irá verificar se o contrato está totalmente financiado e se foi auditado pelo curador. Se o contrato estiver em conformidade, a função irá transferir o valor total do contrato da pool operacional para o executor designado e registrar a execução do contrato.

Se um contrato não estiver em conformidade, a função executeContract irá falhar e o contrato permanecerá em seu estado atual. O dono do contrato pode tentar executar o contrato novamente após corrigir quaisquer problemas.

A função executeContract também é responsável por calcular e distribuir as proporções apropriadas do valor total do contrato para o executor, curador e pool operacional. A fórmula utilizada para determinar as proporções é a seguinte:

executorAmount = valorTotal * (proporçãoExecutor / 100)
curatorAmount = valorTotal * (proporçãoCurador / 100)
poolAmount = valorTotal - executorAmount - curatorAmount

Onde proporçãoExecutor, proporçãoCurador e valorTotal são definidos no contrato.

Com essas funções e variáveis em seu contrato DeWork, você tem uma estrutura básica para criar e executar contratos de serviços profissionais descentralizados. 
