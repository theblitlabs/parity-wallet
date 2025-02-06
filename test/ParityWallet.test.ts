import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { ParityWallet, ERC20Mock } from "../typechain-types";

describe("ParityWallet", function () {
  let parityWallet: ParityWallet;
  let token: ERC20Mock;
  let owner: Signer;
  let user1: Signer;
  let user2: Signer;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("ERC20Mock");
    token = await Token.deploy("Test Token", "TKN");
    await token.waitForDeployment();

    const ParityWallet = await ethers.getContractFactory("ParityWallet");
    parityWallet = await ParityWallet.deploy(await token.getAddress());
    await parityWallet.waitForDeployment();

    // Mint tokens to users for testing
    await token.mint(await user1.getAddress(), ethers.parseEther("1000"));
    await token.mint(await user2.getAddress(), ethers.parseEther("1000"));
  });

  describe("addFunds", function () {
    it("should add funds to a new wallet", async function () {
      const user = user1;
      const amount = ethers.parseEther("1");
      const deviceId = "device-123";

      await token
        .connect(user)
        .approve(await parityWallet.getAddress(), amount);
      await parityWallet
        .connect(user)
        .addFunds(amount, deviceId, await user.getAddress());

      const wallet = await parityWallet.wallets(deviceId);
      expect(wallet.balance).to.equal(amount);
      expect(wallet.exists).to.be.true;
    });

    it("should allow updating wallet address with 0 amount", async function () {
      const user = user1;
      const deviceId = "device-123";
      const newAddress = await user2.getAddress();

      await parityWallet.connect(user).addFunds(0, deviceId, newAddress);
      const wallet = await parityWallet.wallets(deviceId);
      expect(wallet.walletAddress).to.equal(newAddress);
    });

    it("should fail when adding funds with invalid device ID", async function () {
      await expect(
        parityWallet.connect(user1).addFunds(100, "", await user1.getAddress())
      ).to.be.revertedWith("Device ID cannot be empty");
    });
  });

  describe("transferPayment", function () {
    it("should transfer funds between wallets", async function () {
      const creator = user1;
      const solver = user2;
      const amount = ethers.parseEther("1");
      const creatorDevice = "creator-123";
      const solverDevice = "solver-456";

      // Setup creator wallet
      await token
        .connect(creator)
        .approve(await parityWallet.getAddress(), amount);
      await parityWallet
        .connect(creator)
        .addFunds(amount, creatorDevice, await creator.getAddress());

      // Transfer payment
      await parityWallet
        .connect(creator)
        .transferPayment(creatorDevice, solverDevice, amount);

      const creatorWallet = await parityWallet.wallets(creatorDevice);
      const solverWallet = await parityWallet.wallets(solverDevice);

      expect(creatorWallet.balance).to.equal(0);
      expect(solverWallet.balance).to.equal(amount);
    });

    it("should fail transfer with insufficient balance", async function () {
      await token.connect(user1).approve(parityWallet.getAddress(), 100);
      await parityWallet
        .connect(user1)
        .addFunds(100, "device-1", await user1.getAddress());
      await expect(
        parityWallet.connect(user1).transferPayment("device-1", "device-2", 200)
      ).to.be.revertedWith("Insufficient balance");
    });

    it("should fail transfer with non-existent creator", async function () {
      await expect(
        parityWallet
          .connect(user1)
          .transferPayment("invalid-id", "device-2", 100)
      ).to.be.revertedWith("Creator device not registered");
    });
  });

  describe("withdrawFunds", function () {
    it("should withdraw funds to wallet address", async function () {
      const user = user1;
      const amount = ethers.parseEther("1");
      const deviceId = "device-123";
      const initialBalance = await token.balanceOf(await user.getAddress());

      await token.connect(user).approve(parityWallet.getAddress(), amount);
      await parityWallet
        .connect(user)
        .addFunds(amount, deviceId, await user.getAddress());

      await parityWallet.connect(user).withdrawFunds(deviceId, amount);

      const finalBalance = await token.balanceOf(await user.getAddress());
      expect(finalBalance).to.equal(initialBalance);
    });

    it("should fail withdrawal with invalid amount", async function () {
      await token.connect(user1).approve(parityWallet.getAddress(), 100);
      await parityWallet
        .connect(user1)
        .addFunds(100, "device-1", await user1.getAddress());
      await expect(
        parityWallet.connect(user1).withdrawFunds("device-1", 101)
      ).to.be.revertedWith("Insufficient balance");
    });

    it("should prevent withdrawal to zero address", async function () {
      await token.connect(user1).approve(parityWallet.getAddress(), 100);
      await parityWallet
        .connect(user1)
        .addFunds(100, "device-1", ethers.ZeroAddress);
      await expect(
        parityWallet.connect(user1).withdrawFunds("device-1", 100)
      ).to.be.revertedWith("No withdrawal address set");
    });
  });

  describe("updateWalletAddress", function () {
    it("should update withdrawal address", async function () {
      const user = user1;
      const deviceId = "device-123";
      const newAddress = await user2.getAddress();

      await parityWallet
        .connect(user)
        .addFunds(0, deviceId, await user.getAddress());
      await parityWallet
        .connect(user)
        .updateWalletAddress(deviceId, newAddress);

      const wallet = await parityWallet.wallets(deviceId);
      expect(wallet.walletAddress).to.equal(newAddress);
    });
  });

  describe("recoverTokens", function () {
    it("should allow owner to recover tokens", async function () {
      const amount = ethers.parseEther("100");
      await token.transfer(await parityWallet.getAddress(), amount);

      await parityWallet
        .connect(owner)
        .recoverTokens(await token.getAddress(), amount);

      const balance = await token.balanceOf(await owner.getAddress());
      expect(balance).to.be.gt(0);
    });

    it("should prevent non-owner from recovering tokens", async function () {
      await token.transfer(await parityWallet.getAddress(), 100);
      await expect(
        parityWallet.connect(user1).recoverTokens(await token.getAddress(), 100)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });
});

describe("ERC20Mock", function () {
  let token: ERC20Mock;

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("ERC20Mock");
    token = await Token.deploy("Test Token", "TKN");
  });

  it("should mint tokens correctly", async function () {
    const balance = await token.balanceOf(
      await (await ethers.getSigners())[0].getAddress()
    );
    expect(balance).to.equal(ethers.parseEther("1000000"));
  });

  it("should allow token transfers", async function () {
    const [owner, user1] = await ethers.getSigners();
    await token.transfer(await user1.getAddress(), 100);
    expect(await token.balanceOf(await user1.getAddress())).to.equal(100);
  });
});
