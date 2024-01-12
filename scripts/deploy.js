// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const GTTContract = await hre.ethers.getContractFactory("ERC20TokenGTT");
  const GTT = await GTTContract.deploy();
  await GTT.waitForDeployment();
  const ERC20TokenGTTAddr = GTT.target;
  console.log("ERC20TokenGTT contract has been deployed to: " + ERC20TokenGTTAddr);

  const TokenBankContract = await hre.ethers.getContractFactory("TokenBank");
  const TokenBank = await TokenBankContract.deploy(ERC20TokenGTTAddr);
  await TokenBank.waitForDeployment();
  const TokenBankAddr = TokenBank.target;
  console.log("TokenBank contract has been deployed to: " + TokenBankAddr);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
