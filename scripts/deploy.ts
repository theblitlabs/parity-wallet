import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";
import * as dotenv from "dotenv";

// Load environment variables from .env
dotenv.config({ path: path.join(__dirname, "..", ".env") });

async function main() {
  // Get token address from environment
  const tokenAddress = process.env.TOKEN_ADDRESS;
  if (!tokenAddress) {
    throw new Error("TOKEN_ADDRESS not found in environment variables");
  }

  console.log("Deploying ParityWallet contract...");
  console.log(`Using token address: ${tokenAddress}`);

  const ParityWallet = await ethers.getContractFactory("ParityWallet");
  const parityWallet = await ParityWallet.deploy(tokenAddress);

  await parityWallet.waitForDeployment();
  const walletAddress = await parityWallet.getAddress();
  console.log("ParityWallet deployed to:", walletAddress);

  // Update .env file with wallet address
  const envPath = path.join(__dirname, "..", ".env");
  const envContent = fs.readFileSync(envPath, "utf-8");
  const updatedEnv = envContent.replace(
    /WALLET_ADDRESS=.*/,
    `WALLET_ADDRESS=${walletAddress}`
  );
  fs.writeFileSync(envPath, updatedEnv);
  console.log("Updated .env with new wallet address");

  // Log deployment details
  const [deployer] = await ethers.getSigners();
  console.log(`Deployed by: ${deployer.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
