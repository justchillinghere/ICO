//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

/**
 * @title IFarming
 * @dev Interface for the Farming contract.
 */
interface IFarming {
    struct User {
        uint256 stakedAmount;
        uint256 depositTime;
        bool claimed;
    }

    /**
     * @dev Initializes the farming contract with the specified parameters.
     * The reward tokens will be transfered from the owner to the contract
     * in the amount of the full reward with percentage.
     * @param _totalAmount The total amount of tokens to be distributed as rewards.
     * @param _percentage The percentage of rewards to be distributed per epoch.
     * @param _epochDuration The duration of each epoch in seconds.
     * @param _amountOfEpochs The total number of epochs.
     * @param _startTime The start time of the farming period.
     *
     * Requirements:
     * - The contract must not have been initialized before.
     *
     */
    function initialize(
        uint256 _totalAmount,
        uint256 _percentage,
        uint256 _epochDuration,
        uint256 _amountOfEpochs,
        uint256 _startTime
    ) external;

    /**
     * @dev Deposits tokens into the farming contract.
     * @param _amount The amount of tokens to be deposited.
     *
     * Requirements:
     * - The farming period must have started.
     * - The amount of tokens to be deposited must not exceed the remaining tokens available for staking.
     * - The user must not have already made a deposit.
     */
    function deposit(uint256 _amount) external;

    /**
     * @dev Withdraws tokens from the farming contract.
     *
     * Requirements:
     * - The user must have already claimed their rewards.
     * - The staking period must have ended.
     */
    function withdraw() external;

    /**
     * @dev Claims rewards from the farming contract.
     * Users can claim their earned rewards from the farming contract
     * after the staking period has ended.
     *
     * Requirements:
     * - The user must have staked tokens.
     * - The staking period must have ended.
     * - The user must not have already claimed their rewards.
     */
    function claimRewards() external;
}
