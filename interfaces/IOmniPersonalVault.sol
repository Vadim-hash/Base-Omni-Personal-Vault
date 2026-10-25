// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;
interface IOmniPersonalVault {
    function depositToVault() external payable;
    function executeBatchTransfer(address[] calldata recipients, uint256[] calldata amounts) external;
    function withdrawFromVault(uint256 amount) external;
}
