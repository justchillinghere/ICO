//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Farming
 * @dev A contract for staking and farming tokens.
 * Takes a staking token and a reward token in the constructor.
 *
 * @notice This contract allows users to deposit tokens
 * and earn rewards over a specified duration.
 * The rewards are distributed proportionally
 * based on the staked amount and the duration of the farming period.
 * Withdrawal and rewards can be claimed by the user
 * only after the staking period has ended.
 * The user must claim rewards before withdrawing.
 *
 */
contract Farming {
    using SafeERC20 for IERC20Metadata;

    struct User {
        uint256 stakedAmount;
        uint256 depositTime;
        bool claimed;
    }

    uint256 public constant HUNDRED_PERCENT = 10_000; // 100.00%

    address public owner;

    IERC20Metadata public stakingToken; // LP token

    IERC20Metadata public rewardToken; // token A or erc20

    uint256 public tokensLeft;

    uint256 public percentage;

    uint256 public startTime;

    uint256 public epochDuration;

    uint256 public amountOfEpochs;

    bool public initialized;

    mapping(address => User) public users;

    /**
     * @dev Emitted when a user deposits tokens into the farming contract.
     * @param addr The address of the user who deposited tokens.
     * @param amount The amount of tokens deposited.
     */
    event Deposited(address indexed addr, uint256 amount);

    /**
     * @dev Emitted when a user withdraws tokens from the farming contract.
     * @param addr The address of the user who withdrew tokens.
     * @param amount The amount of tokens withdrawn.
     */
    event Withdraw(address indexed addr, uint256 amount);

    /**
     * @dev Emitted when a user claims rewards from the farming contract.
     * @param addr The address of the user who claimed rewards.
     * @param amount The amount of rewards claimed.
     */
    event Claimed(address indexed addr, uint256 amount);

    constructor(address _tstToken, address _usdToken) {
        owner = msg.sender;
        tstToken = IERC20Metadata(_tstToken);
        usdToken = IERC20Metadata(_usdToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
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
        uint256 _percentage, // 0 ~ 100.00% => 0 ~ 10000
        uint256 _epochDuration,
        uint256 _amountOfEpochs,
        uint256 _startTime
    ) external onlyOwner {
        require(!initialized, "Already initialized");
        initialized = true;
        tokensLeft = _totalAmount;
        percentage = _percentage;
        startTime = _startTime;
        amountOfEpochs = _amountOfEpochs;
        epochDuration = _epochDuration;

        rewardToken.safeTransferFrom(
            msg.sender,
            address(this),
            ((_totalAmount * _percentage * _amountOfEpochs) / HUNDRED_PERCENT)
        );
    }

    /**
     * @dev Deposits tokens into the farming contract.
     * Users can deposit tokens to participate in the farming program.
     * The tokens will be staked for a specified duration and users will earn rewards based on their staked amount.
     * @param _amount The amount of tokens to be deposited.
     *
     * Requirements:
     * - The farming period must have started.
     * - The amount of tokens to be deposited must not exceed the remaining tokens available for staking.
     * - The user must not have already made a deposit.
     */
    function deposit(uint256 _amount) external {
        require(startTime <= block.timestamp, "Farming is not up yet!");
        require(_amount <= tokensLeft, "Too many tokens contributed");
        require(
            users[msg.sender].stakedAmount == 0,
            "User can deposit only once"
        );

        users[msg.sender] = User({
            stakedAmount: _amount,
            depositTime: block.timestamp,
            claimed: false
        });

        tokensLeft -= _amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposited(msg.sender, _amount);
    }

    /**
     * @dev Withdraws tokens from the farming contract.
     * Users can withdraw their staked tokens from the farming contract
     * after the staking period has ended and they have claimed their rewards.
     *
     * Requirements:
     * - The user must have already claimed their rewards.
     */
    function withdraw() public {
        require(users[msg.sender].claimed, "Please claim before withdrawing");
        uint256 amountToTransfer = users[msg.sender].stakedAmount;
        users[msg.sender].stakedAmount = 0;
        users[msg.sender].depositTime = 0;
        stakingToken.safeTransfer(msg.sender, amountToTransfer);
        emit Withdraw(msg.sender, amountToTransfer);
    }

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
    function claimRewards() external {
        require(
            users[msg.sender].stakedAmount > 0,
            "No token has been deposited by the account"
        );
        require(
            users[msg.sender].depositTime + epochDuration * amountOfEpochs <=
                block.timestamp,
            "Farming is not over yet"
        );
        require(!users[msg.sender].claimed, "User already claimed");

        uint256 rewardToTransfer = (users[msg.sender].stakedAmount *
            percentage *
            amountOfEpochs) / HUNDRED_PERCENT;

        users[msg.sender].claimed = true;
        rewardToken.safeTransfer(msg.sender, rewardToTransfer);
        emit Claimed(msg.sender, rewardToTransfer);
    }
}
