import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BaseProvider } from "ethers/node_modules/@ethersproject/providers";
import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import {
  MyToken,
  MyToken__factory,
  Farming,
  Farming__factory,
} from "../src/types";

function calculateReward(
  stakeAmount: BigNumber,
  percentage: number,
  amountOfEpochs: number
) {
  return stakeAmount.mul(percentage).mul(amountOfEpochs).div(10000);
}

/*
 *
 * Initialization arguments list:
 * 1. uint256 _totalAmount – total amount of tokens that can be staked
 * 2. uint256 _percentage – percentage for the staking (for one epoch).
 * NOTE: The boundaries for the percentage are 0 (0%) -> 10000 (100.00%)
 * 3. uint256 _epochDuration – duration of one epoch (in seconds). For convinience, take average values:
 * - 1 month ~ 2,592,000 seconds
 * 4. uint256 _amountOfEpochs – amount of epochs
 * 5. _startTime – in seconds from 1 January 1970. Better to use timestamps
 */

describe("Test farming contract", function () {
  let farmingContract: Farming;

  let tokenLP: MyToken;
  let tokenReward: MyToken;

  let stakeAmount: BigNumber = ethers.utils.parseUnits("1", "18");
  let percentage: number;
  let epochDuration: number;
  let amountOfEpochs: number;
  let rewardAmount: BigNumber;
  let startTime: number;

  let amountToDeposit = ethers.utils.parseUnits("1", "10");

  let owner: SignerWithAddress,
    user1: SignerWithAddress,
    user2: SignerWithAddress,
    users: SignerWithAddress[];

  beforeEach(async () => {
    [owner, user1, user2, ...users] = await ethers.getSigners();

    // Create tokens for staking and rewards
    const TokenFactory = (await ethers.getContractFactory(
      "MyToken"
    )) as MyToken__factory;
    tokenLP = await TokenFactory.deploy("TokenLP", "TLP");
    tokenReward = await TokenFactory.deploy("TokenLP", "TRD");

    // Create farming contracts for the pair of tokens
    const FarmingFactory = (await ethers.getContractFactory(
      "Farming"
    )) as Farming__factory;
    farmingContract = await FarmingFactory.deploy(
      tokenLP.address,
      tokenReward.address
    );

    percentage = 10;
    epochDuration = 2592000;
    amountOfEpochs = 3;
    rewardAmount = calculateReward(stakeAmount, percentage, amountOfEpochs);
    startTime = await time.latest();

    await tokenReward.approve(farmingContract.address, rewardAmount);

    await farmingContract.initialize(
      stakeAmount,
      percentage,
      epochDuration,
      amountOfEpochs,
      startTime
    );
  });

  describe("Test farming contract initialization", function () {
    // Setup default farming parameters and initialize farmng for a pair of tokens
    it("should have transfered correct amount of rewards to the contract after initialization", async () => {
      expect(await tokenReward.balanceOf(farmingContract.address)).to.be.equal(
        rewardAmount
      );
    });
    it("should fail to initialize pair twice", async () => {
      await expect(
        farmingContract.initialize(
          stakeAmount,
          percentage,
          epochDuration,
          amountOfEpochs,
          startTime
        )
      ).to.be.revertedWith("Already initialized");
    });
    it("should fail for not owner to initialize farming", async () => {
      const user1FarmingContract = farmingContract.connect(user1);
      await expect(
        user1FarmingContract.initialize(
          stakeAmount,
          percentage,
          epochDuration,
          amountOfEpochs,
          startTime
        )
      ).to.be.revertedWith("Not an owner");
    });
  });
  describe("Test deposit to the farming contract", function () {
    // Setup default farming parameters and initialize farmng for a pair of tokens
    it("should deposit tokens to the contract and check balance", async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await farmingContract.deposit(amountToDeposit);
      expect(await tokenLP.balanceOf(farmingContract.address)).to.be.equal(
        amountToDeposit
      );
    });
    it("should emit an event with correct arguments", async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await expect(farmingContract.deposit(amountToDeposit))
        .to.emit(farmingContract, "Deposited")
        .withArgs(owner.address, amountToDeposit);
    });
  });
  describe("Negative tests for deposit", function () {
    // Setup default farming parameters and initialize farmng for a pair of tokens

    it("should fail to deposit twice", async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit.mul(2));
      await farmingContract.deposit(amountToDeposit);
      await expect(farmingContract.deposit(amountToDeposit)).to.be.revertedWith(
        "User can deposit only once"
      );
    });
    it("should fail to deposit more tokens than limit set", async () => {
      amountToDeposit = stakeAmount.mul(2);
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await expect(farmingContract.deposit(amountToDeposit)).to.be.revertedWith(
        "Too many tokens contributed"
      );
    });
  });
  describe("Test withdraw from the farming contract", function () {
    // Setup default farming parameters and initialize farmng for a pair of tokens
    it("should let withdraw after claiming rewards", async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await farmingContract.deposit(amountToDeposit);
      let balanceAfterDeposit = await tokenLP.balanceOf(owner.address);

      await time.increase(epochDuration * (amountOfEpochs + 1));
      await farmingContract.claimRewards();
      await farmingContract.withdraw();
      expect(await tokenLP.balanceOf(owner.address)).to.be.equal(
        balanceAfterDeposit.add(amountToDeposit)
      );
    });
  });
  describe("Negative test withdraw", function () {
    // Setup default farming parameters and initialize farmng for a pair of tokens
    it("should fail to withdraw before claiming rewards", async () => {
      await expect(farmingContract.withdraw()).to.be.revertedWith(
        "Please claim before withdrawing"
      );
    });
  });
  describe("Test rewards", function () {
    beforeEach(async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await farmingContract.deposit(amountToDeposit);
      await time.increase(epochDuration * (amountOfEpochs + 1));
    });
    it("should return correct rewards", async () => {
      rewardAmount = calculateReward(
        amountToDeposit,
        percentage,
        amountOfEpochs
      );
      const oldRewardBalance = await tokenReward.balanceOf(owner.address);

      await farmingContract.claimRewards();
      expect(await tokenReward.balanceOf(owner.address)).to.be.equal(
        oldRewardBalance.add(rewardAmount)
      );
    });
    it("should emit an event with correct arguments", async () => {
      rewardAmount = calculateReward(
        amountToDeposit,
        percentage,
        amountOfEpochs
      );
      expect(await farmingContract.claimRewards())
        .to.emit(farmingContract, "ClaimedRewards")
        .withArgs(owner.address, rewardAmount);
    });
  });
  describe("Negative test rewards", function () {
    // Setup default farming parameters and initialize farmng for a pair of tokens
    it("should fail to get rewards before the farming ends", async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await farmingContract.deposit(amountToDeposit);
      await time.increase(epochDuration);
      await expect(farmingContract.claimRewards()).to.be.revertedWith(
        "Farming is not over yet"
      );
    });
    it("should fail to claim rewards for not a holder", async () => {
      amountToDeposit = ethers.utils.parseUnits("1", "10");
      await tokenLP.approve(farmingContract.address, amountToDeposit);
      await farmingContract.deposit(amountToDeposit);
      await time.increase(epochDuration * (amountOfEpochs + 1));
      const user1FarmingContract = farmingContract.connect(user1);
      await expect(user1FarmingContract.claimRewards()).to.be.revertedWith(
        "No token has been deposited by the account"
      );
    });
	it("should fail to claim more than once", async () => {
		amountToDeposit = ethers.utils.parseUnits("1", "10");
		await tokenLP.approve(farmingContract.address, amountToDeposit);
		await farmingContract.deposit(amountToDeposit);
		await time.increase(epochDuration * (amountOfEpochs + 1));
		farmingContract.claimRewards();
		await expect(farmingContract.claimRewards()).to.be.revertedWith(
		  "User already claimed"
		);
	  });
  });
});
