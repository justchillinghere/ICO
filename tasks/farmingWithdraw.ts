import { task } from "hardhat/config";
import { BigNumber, ContractTransaction, ContractReceipt } from "ethers";
import { contractAddress } from "../hardhat.config";
import { Address } from "cluster";

task(
  "withdraw",
  "Withdraws all the money staked back to the owner. Emits an event"
).setAction(async ({}, { ethers }) => {
  const Contract = await ethers.getContractFactory("Farming");
  const farmingContract = Contract.attach(contractAddress!);

  const farmingTx: ContractTransaction = await farmingContract.withdraw();
  const farmingReceipt: ContractReceipt = await farmingTx.wait();

  const event = farmingReceipt.events?.find(
    (event) => event.event === "Withdraw"
  );
  const addr: Address = event?.args!["addr"];
  const amount: BigNumber = event?.args!["amount"];
  console.log("Successfully withdrawed tokens from the contract");
  console.log(`Tokens been sent to the address: ${addr}`);
  console.log(`Withdraw amount: ${amount}`);
});
