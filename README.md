# DeWork4Us
 This is the Blockchain dedicated to the DeWork protocol, 
proof of work will be implemented initially due to reduced demand, 
as soon as we reach maturity level 2, 
tests will be carried out and the migration to proof of stake will be available. 

 The above DeWork contract aims to provide an operational framework for the creation and execution of smart contracts. The contract stores information about the created contracts, such as the objective, allocated value, contract owner, executor, and curator.

Contracts are created using the createContract function, which takes the contract objective and allocated value as parameters. The allocated value is added to the contract's guarantee fund (poolBalance).

Contracts can be executed using the executeContract function, which allows the contract owner to execute it. For a contract to be executed, it must be fully funded (i.e., the total value must be available in the operational pool) and must have been audited by the designated curator.

To execute a contract, the contract owner must call the executeContract function, passing the contract address as an argument. The executeContract function will verify if the contract is fully funded and if it has been audited by the curator. If the contract is compliant, the function will transfer the total value of the contract from the operational pool to the designated executor and record the contract's execution.

If a contract is not compliant, the executeContract function will fail, and the contract will remain in its current state. The contract owner can attempt to execute the contract again after addressing any issues.

The executeContract function is also responsible for calculating and distributing the appropriate proportions of the total contract value to the executor, curator, and operational pool. The formula used to determine the proportions is as follows:

executorAmount = totalValue * (executorProportion / 100)
curatorAmount = totalValue * (curatorProportion / 100)
poolAmount = totalValue - executorAmount - curatorAmount

Where executorProportion, curatorProportion, and totalValue are defined in the contract.

With these functions and variables in your DeWork contract, you have a basic framework for creating and executing decentralized professional service contracts.
