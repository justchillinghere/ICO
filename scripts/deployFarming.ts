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
  const MyContract = await ethers.getContractFactory("Farming");
  const myContract = await MyContract.deploy(
    tokenData.tokenLP.address,
    tokenData.tokenReward.address
  );

  await myContract.deployed();

  console.log(
    `The farming contract has been deployed to ${myContract.address}`
  );

  console.log("wait of delay...");
  await delay(30000); // delay 30 seconds
  console.log("starting verify token...");
  try {
    await run("verify:verify", {
      address: myContract!.address,
      contract: "contracts/Farming.sol:Farming",
      constructorArguments: [
        tokenData.tokenLP.address,
        tokenData.tokenReward.address,
      ],
    });
    console.log("verify success");
    return;
  } catch (e: any) {
    console.log(e.message);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
