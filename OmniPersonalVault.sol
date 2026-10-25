// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

contract OmniPersonalVault {
    address payable public vaultOwner;
    string public vaultName;
    uint256 public totalLockedWei;
    bool public isVaultFrozen;

    mapping(address => bool) public trustedAddresses;
    mapping(address => uint256) public allowances;

    event TrustedAdded(address indexed account);
    event NameChanged(string newName);
    event Deposited(address indexed sender, uint256 amount);
    event BatchExecuted(uint256 totalAmount);
    event VaultFrozen(bool status);
    event AllowanceGranted(address indexed spender, uint256 amount);
    event TrustedRevoked(address indexed account);
    event Transferred(address indexed recipient, uint256 amount);
    event OwnerUpdated(address indexed newOwner);
    event Withdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == vaultOwner, "OmniVault: Not owner");
        _;
    }

    modifier whenNotFrozen() {
        require(!isVaultFrozen, "OmniVault: Frozen");
        _;
    }

    constructor() {
        vaultOwner = payable(msg.sender);
        vaultName = "Omni Base Personal Vault v1";
        isVaultFrozen = false;
        trustedAddresses[msg.sender] = true;
    }

    // 1. addTrustedAddress
    function addTrustedAddress(address toAdd) external onlyOwner {
        require(!trustedAddresses[toAdd], "OmniVault: Already trusted");
        trustedAddresses[toAdd] = true;
        emit TrustedAdded(toAdd);
    }

    // 2. changeVaultName
    function changeVaultName(string calldata newName) external onlyOwner {
        require(bytes(newName).length > 0, "OmniVault: Empty name");
        vaultName = newName;
        emit NameChanged(newName);
    }

    // 3. depositToVault
    function depositToVault() external payable whenNotFrozen {
        require(msg.value > 0, "OmniVault: Zero deposit");
        totalLockedWei += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // 4. executeBatchTransfer
    function executeBatchTransfer(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner whenNotFrozen {
        require(recipients.length == amounts.length, "OmniVault: Length mismatch");
        
        uint256 total = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }
        
        require(address(this).balance >= total, "OmniVault: Insufficient funds");
        totalLockedWei -= total;

        for (uint256 i = 0; i < recipients.length; i++) {
            (bool sent, ) = recipients[i].call{value: amounts[i]}("");
            require(sent, "OmniVault: Transfer failed");
        }
        
        emit BatchExecuted(total);
    }

    // 5. freezeVault
    function freezeVault(bool status) external onlyOwner {
        isVaultFrozen = status;
        emit VaultFrozen(status);
    }

    // 6. grantAllowance
    function grantAllowance(address spender, uint256 amount) external onlyOwner {
        allowances[spender] = amount;
        emit AllowanceGranted(spender, amount);
    }

    // 7. revokeTrustedAddress
    function revokeTrustedAddress(address toRemove) external onlyOwner {
        require(trustedAddresses[toRemove], "OmniVault: Not trusted");
        require(toRemove != vaultOwner, "OmniVault: Cannot revoke self");
        trustedAddresses[toRemove] = false;
        emit TrustedRevoked(toRemove);
    }

    // 8. transferToTrusted
    function transferToTrusted(address recipient, uint256 amount) external whenNotFrozen {
        require(trustedAddresses[recipient], "OmniVault: Recipient not trusted");
        require(msg.sender == vaultOwner || allowances[msg.sender] >= amount, "OmniVault: Unauthorized");
        require(address(this).balance >= amount, "OmniVault: Insufficient balance");

        if (msg.sender != vaultOwner) {
            allowances[msg.sender] -= amount;
        }
        totalLockedWei -= amount;

        (bool sent, ) = recipient.call{value: amount}("");
        require(sent, "OmniVault: Transfer failed");
        emit Transferred(recipient, amount);
    }

    // 9. updateOwner
    function updateOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "OmniVault: Zero address");
        vaultOwner = payable(newOwner);
        emit OwnerUpdated(newOwner);
    }

    // 10. withdrawFromVault
    function withdrawFromVault(uint256 amount) external onlyOwner whenNotFrozen {
        require(address(this).balance >= amount, "OmniVault: Insufficient funds");
        totalLockedWei -= amount;

        (bool sent, ) = vaultOwner.call{value: amount}("");
        require(sent, "OmniVault: Withdrawal failed");
        
        emit Withdrawn(vaultOwner, amount);
    }
}