pragma solidity ^0.8.0;

contract DeWork {
    struct Contract {
        address owner;
        address executor;
        address curator;
        uint256 value;
        string objective;
        bool approved;
    }
    
    mapping(uint256 => Contract) public contracts;
    mapping(address => uint256[]) public ownedContracts;
    mapping(address => uint256[]) public executedContracts;
    mapping(address => uint256[]) public curatedContracts;
    uint256 public contractCount;
    uint256 public poolBalance;
    
    event ContractCreated(uint256 id, address indexed owner, uint256 value);
    event ContractExecuted(uint256 id, address indexed executor);
    event ContractApproved(uint256 id, address indexed curator);
    event ContractRejected(uint256 id, address indexed curator);
    
    function createContract(string memory _objective) public payable {
        require(msg.value > 0, "Value must be greater than 0");
        
        uint256 id = contractCount;
        contracts[id] = Contract(msg.sender, address(0), address(0), msg.value, _objective, false);
        ownedContracts[msg.sender].push(id);
        contractCount++;
        poolBalance += msg.value;
        
        emit ContractCreated(id, msg.sender, msg.value);
    }
    
    function executeContract(uint256 id) public {
        Contract storage c = contracts[id];
        require(c.approved, "Contract must be approved");
        require(c.executor == address(0), "Contract already executed");
        require(c.owner == msg.sender, "Only owner can execute contract");
        
        c.executor = msg.sender;
        executedContracts[msg.sender].push(id);
        
        emit ContractExecuted(id, msg.sender);
    }
    
    function approveContract(uint256 id) public {
        Contract storage c = contracts[id];
        require(c.curator == msg.sender, "Only curator can approve contract");
        
        c.approved = true;
        poolBalance -= c.value;
        
        emit ContractApproved(id, msg.sender);
    }
    
    function rejectContract(uint256 id) public {
        Contract storage c = contracts[id];
        require(c.curator == msg.sender, "Only curator can reject contract");
        
        c.approved = false;
        poolBalance += c.value;
        
        emit ContractRejected(id, msg.sender);
    }
    
    function getOwnedContracts() public view returns (uint256[] memory) {
        return ownedContracts[msg.sender];
    }
    
    function getExecutedContracts() public view returns (uint256[] memory) {
        return executedContracts[msg.sender];
    }
    
    function getCuratedContracts() public view returns (uint256[] memory) {
        return curatedContracts[msg.sender];
    }
}
