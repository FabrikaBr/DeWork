const Web3 = require('web3');
const web3 = new Web3('http://localhost:8545');

// Conecta à conta de um usuário da blockchain
web3.eth.personal.unlockAccount('0x...', 'senha', 600)
  .then(() => {
    // Cria o contrato inteligente
    const Contract = new web3.eth.Contract(contractAbi, contractAddress);

    // Preenche as informações do contrato com os dados do formulário
    const objContract = document.getElementById('obj_contract').value;
    const valueContract = document.getElementById('value_contract').value;
    const respContract = document.getElementById('resp_contract').value;
    const respExec = document.getElementById('resp_exec').value;
    const respAudit = document.getElementById('resp_audit').value;

    // Chama a função do contrato para criar o contrato inteligente
    Contract.methods.createContract(objContract, valueContract, respContract, respExec, respAudit).send()
      .then((receipt) => {
        // Imprime o recibo da transação
        console.log(receipt);
      });
  })
  .catch((error) => {
    console.error(error);
  });
