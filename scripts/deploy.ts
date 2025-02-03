import { ethers, run } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const TOKEN_ADDRESS = process.env.TOKEN_ADDRESS;
  if (!TOKEN_ADDRESS) {
    throw new Error("TOKEN_ADDRESS is not defined in .env");
  }

  // Deploy StakeWallet contract (which acts as the runner/solver wallet)
  const StakeWallet = await ethers.getContractFactory("StakeWallet");
  const walletContract = await StakeWallet.deploy(TOKEN_ADDRESS);
  await walletContract.waitForDeployment();

  console.log("StakeWallet deployed to:", await walletContract.getAddress());

  // Wait for several block confirmations
  await walletContract.deploymentTransaction()?.wait(5);

  // Verify contract on Etherscan if needed (ensure you have set up your Etherscan API key)
  console.log("Verifying contract on Etherscan...");
  try {
    await run("verify:verify", {
      address: await walletContract.getAddress(),
      constructorArguments: [TOKEN_ADDRESS],
    });
  } catch (error) {
    console.log("Error verifying StakeWallet:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
