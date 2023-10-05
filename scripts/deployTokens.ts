import { ethers, run, network } from "hardhat";
import { tokenData } from "../hardhat.config";
import { MyToken, MyToken__factory } from "../src/types";

const delay = async (time: number) => {
  return new Promise((resolve: any) => {
    setInterval(() => {
      resolve();
    }, time);
  });
};

async function main() {
  const MyContract: MyToken__factory =
    await ethers.getContractFactory("MyToken");

  for (let token in tokenData) {
    const tokenContract: MyToken = await MyContract.deploy(
      tokenData[token].name,
      tokenData[token].symbol,
      tokenData[token].decimals
    );
    await tokenContract.deployed();
    tokenData[token].address = tokenContract.address;
    console.log(`Token ${token} has been deployed to ${tokenContract.address}`);

    console.log("wait of delay...");
    await delay(15000); // delay 15 seconds
    console.log("starting verify token...");
    try {
      await run("verify:verify", {
        address: tokenData[token].address,
        contract: "contracts/MyToken.sol:MyToken",
        constructorArguments: [
          tokenData[token].name,
          tokenData[token].symbol,
          tokenData[token].decimals,
        ],
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
