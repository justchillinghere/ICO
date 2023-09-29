import { task } from "hardhat/config";
import { BigNumber, ContractTransaction, ContractReceipt } from "ethers";
import { contractAddress } from "../hardhat.config";
import { Address } from "cluster";

task(
  "claim",
  "Transfers the reward to the holder and emits an event"
).setAction(async ({}, { ethers }) => {
  const Contract = await ethers.getContractFactory("Farming");
  const farmingContract = Contract.attach(contractAddress!);

  const farmingTx: ContractTransaction = await farmingContract.claimRewards();
  const farmingReceipt: ContractReceipt = await farmingTx.wait();

  const event = farmingReceipt.events?.find(
    (event) => event.event === "Claimed"
  );
  const addr: Address = event?.args!["addr"];
  const amount: BigNumber = event?.args!["amount"];
  console.log("Successfully claimed reward tokens");
  console.log(`Reward tokens been sent to the address: ${addr}`);
  console.log(`Reward amount: ${amount}`);
});
