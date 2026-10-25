# Omni Personal Vault

A highly secure, decentralized personal treasury protocol deployed on the Base L2 network. Omni Vault is designed as a foundational self-custody smart contract, allowing the owner to securely lock native assets, delegate allowances to trusted secondary wallets, and execute gas-optimized batch transactions.

## System Mechanics
* **Delegated Allowances:** The vault owner can grant specific spending limits to external addresses (e.g., automated trading bots or secondary hardware wallets). These delegates can only transfer funds to explicitly whitelisted `trustedAddresses`.
* **Emergency Freeze:** In the event of a compromised private key or external market threat, the owner can instantly trigger `freezeVault`, blocking all outgoing transfers, batch executions, and deposits until the system is deemed secure.
* **Batch Execution:** The `executeBatchTransfer` function allows the owner to route multiple payments to different addresses in a single transaction, significantly reducing cumulative gas costs compared to standard individual transfers.

## Architecture
Developed using Solidity `0.8.37`. The protocol heavily enforces the Checks-Effects-Interactions pattern across all withdrawal and transfer functions. State variables tracking total locked balances are updated prior to executing raw `call` operations to completely eliminate reentrancy vectors.
