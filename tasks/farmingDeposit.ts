import { task } from "hardhat/config";
import { BigNumber, ContractTransaction, ContractReceipt } from "ethers";
import { ethers } from "ethers";
import { contractAddress } from "../hardhat.config";
import { Address } from "cluster";

task(
  "deposit",
  "Makes deposit to the farming contract \
   and transfers LP tokens to the contract for staking. \
   Emits event after successful deposit"
)
  .addParam("depositAmount", "Amount of tokens to stake")
  .setAction(async ({ depositAmount }, { ethers }) => {
    const Contract = await ethers.getContractFactory("Farming");
    const farmingContract = Contract.attach(contractAddress!);

    const farmingTx: ContractTransaction =
      await farmingContract.deposit(depositAmount);
    const farmingReceipt: ContractReceipt = await farmingTx.wait();

    const event = farmingReceipt.events?.find(
      (event) => event.event === "Deposited"
    );
    const addr: Address = event?.args!["addr"];
    const amount: BigNumber = event?.args!["amount"];
    console.log("Successfully deposited tokens for staking");
    console.log(`Address of the holder: ${addr}`);
    console.log(`Deposited amount: ${amount}`);
  });
