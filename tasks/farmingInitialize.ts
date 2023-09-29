import { task } from "hardhat/config";
import { ethers } from "ethers";
import { BigNumber, ContractTransaction, ContractReceipt } from "ethers";
import { contractAddress } from "../hardhat.config";
import { types } from "hardhat/config";

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
async function getLastBlockTimestamp(): Promise<number> {
  const provider = ethers.providers.getDefaultProvider();
  const blockNumber: number = await provider.getBlockNumber();
  const block: any = await provider.getBlock(blockNumber);
  const timestamp: number = block.timestamp;
  return timestamp;
}

task(
  "initialize",
  "Initializes the farming contract for the pair of token. \
  Transfers reward tokens to the farming contract"
)
  .addParam("totalAmount", "Total amount of tokens that can be staked")
  .addParam("percentage", "Percentage for the staking (for the one epoch)")
  .addParam("epochDuration", "Duration of one epoch (in seconds)")
  .addParam("amountOfEpochs", "Amount of epochs")
  .addParam("startTime", "In seconds from the last block time", 0, types.int)
  .setAction(
    async (
      { totalAmount, percentage, epochDuration, amountOfEpochs, startTime },
      { ethers }
    ) => {
      const Contract = await ethers.getContractFactory("Farming");
      const farmingContract = Contract.attach(contractAddress!);
      const timeToStart = (await getLastBlockTimestamp()) + startTime;
      console.log("Started initialization");
      const farmingTx: ContractTransaction = await farmingContract.initialize(
        totalAmount,
        percentage,
        epochDuration,
        amountOfEpochs,
        timeToStart
      );
      console.log("Started waiting");
      const farmingReceipt: ContractReceipt = await farmingTx.wait();
      console.log("Initialized farming parameters");
    }
  );
