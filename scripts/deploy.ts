import { ethers } from "hardhat";

async function main() {
  const ParityWallet = await ethers.getContractFactory("ParityWallet");
  const parityWallet = await ParityWallet.deploy(
    "0x5FbDB2315678afecb367f032d93F642f64180aa3"
  );

  await parityWallet.waitForDeployment();
  console.log("ParityWallet deployed to:", await parityWallet.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
