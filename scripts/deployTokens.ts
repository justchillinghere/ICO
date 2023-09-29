import { ethers, run, network } from "hardhat";
import { tokenData } from "../hardhat.config";

const delay = async (time: number) => {
  return new Promise((resolve: any) => {
    setInterval(() => {
      resolve();
    }, time);
  });
};

async function main() {
  const MyContract = await ethers.getContractFactory("MyToken");

  const tokenLP = await MyContract.deploy(
    tokenData.tokenLP.name,
    tokenData.tokenLP.symbol
  );
  const tokenReward = await MyContract.deploy(
    tokenData.tokenReward.name,
    tokenData.tokenReward.symbol
  );
  await tokenLP.deployed();
  await tokenReward.deployed();

  tokenData.tokenLP.address = tokenLP.address;
  tokenData.tokenReward.address = tokenReward.address;

  console.log(`LP token has been deployed to ${tokenLP.address}`);
  console.log(`Reward token has been deployed to ${tokenReward.address}`);

  console.log("wait of delay...");
  await delay(30000); // delay 30 seconds
  console.log("starting verify token...");
  for (let key in tokenData) {
    try {
      await run("verify:verify", {
        address: tokenData[key].address,
        contract: "contracts/MyToken.sol:MyToken",
        constructorArguments: [tokenData[key].name, tokenData[key].symbol],
      });
      console.log("verify success");
      return;
    } catch (e: any) {
      console.log(e.message);
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
