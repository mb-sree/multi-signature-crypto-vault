// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EasyMultiSigVault {

    event Deposit(address sender, uint amount);
    event Submit(uint txId);
    event Approve(address owner, uint txId);
    event Revoke(address owner, uint txId);
    event Execute(uint txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public requiredApprovals;

    struct Transaction {
        address to;
        uint value;
        bool executed;
    }

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "You are not an owner");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Need at least 1 owner");
        require(_required > 0 && _required <= _owners.length, "Invalid number of required approvals");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid address");
            require(!isOwner[owner], "Duplicate owner");
            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredApprovals = _required;
    }

    // ==================
    // FUND THE VAULT
    // ==================
    // Just call this function with Value set to 5 ether at the top
    function deposit() external payable {
        require(msg.value > 0, "Send some ETH");
        emit Deposit(msg.sender, msg.value);
    }

    // ==================
    // MAIN FUNCTIONS
    // ==================
    function submit(address _to, uint _valueInEther) external onlyOwner {
        uint valueInWei = _valueInEther * 1 ether;
        require(valueInWei <= address(this).balance, "Not enough ETH in vault");
        transactions.push(Transaction(_to, valueInWei, false));
        emit Submit(transactions.length - 1);
    }

    function approve(uint _txId) external onlyOwner {
        require(_txId < transactions.length, "Transaction does not exist");
        require(!transactions[_txId].executed, "Already executed");
        require(!approved[_txId][msg.sender], "Already approved by you");
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function revoke(uint _txId) external onlyOwner {
        require(_txId < transactions.length, "Transaction does not exist");
        require(!transactions[_txId].executed, "Already executed");
        require(approved[_txId][msg.sender], "You have not approved this");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function execute(uint _txId) external onlyOwner {
        require(_txId < transactions.length, "Transaction does not exist");
        Transaction storage t = transactions[_txId];
        require(!t.executed, "Already executed");
        require(getApprovalCount(_txId) >= requiredApprovals, "Not enough approvals yet");
        require(address(this).balance >= t.value, "Not enough ETH in vault");
        t.executed = true;
        (bool success, ) = t.to.call{value: t.value}("");
        require(success, "Transfer failed");
        emit Execute(_txId);
    }

    // ==================
    // VIEW FUNCTIONS
    // ==================
    function getApprovalCount(uint _txId) public view returns (uint count) {
        for (uint i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) count++;
        }
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txId) external view returns (
        address to,
        uint value,
        bool executed,
        uint approvalCount
    ) {
        Transaction storage t = transactions[_txId];
        return (t.to, t.value, t.executed, getApprovalCount(_txId));
    }
}
