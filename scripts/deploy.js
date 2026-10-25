const hre = require("hardhat");
async function main() {
  const VaultFactory = await hre.ethers.getContractFactory("OmniPersonalVault");
  const vault = await VaultFactory.deploy();
  await vault.deployed();
  console.log("-> Omni Personal Vault live at:", vault.address);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
