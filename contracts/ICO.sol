//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.18;

import "./MyToken.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IMyICO.sol";

contract MyICO is IMyICO, AccessControl {
    struct User {
        uint256 purchased;
        uint256 claimed;
    }

    mapping(address => User) public users;
    address owner;
    MyToken public tstToken;
    MyToken public usdToken;
    uint256 public constant HUNDRED_PERCENT = 10_000; // 100.00%
    uint256 public claimStart;
    uint256 public usdToTstMultiplier = 2; // USD per TST token (no decimals)
    uint256 minPurchase = 10; // Min TST to buy
    uint256 maxPurchase = 100; // Max TST to buy

    event Claimed(address _user, uint256 _amountClaimed);
    event Deposited(address user, uint256 amountUSD, uint256 amountTST);

    constructor(address _tstToken, address _usdToken, uint256 _claimStart) {
        tstToken = MyToken(_tstToken);
        usdToken = MyToken(_usdToken);
        claimStart = _claimStart;
        owner = msg.sender;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function buyToken(uint256 usdAmount) external {
        require(block.timestamp < claimStart, "ICO has ended");
        require(usdAmount > 0, "Amount must be greater than 0");

        uint256 tstDecimalFactor = 10 ** tstToken.decimals();
        uint256 usdDecimalFactor = 10 ** usdToken.decimals();
        uint256 tstAmount = (usdAmount * tstDecimalFactor) /
            (usdToTstMultiplier * usdDecimalFactor);
        uint256 newTstBalance = users[msg.sender].purchased + tstAmount;
        require(
            (minPurchase * tstDecimalFactor <= newTstBalance) &&
                (newTstBalance <= maxPurchase * tstDecimalFactor),
            "User can own from 10 to 100 TST tokens on it's account"
        );
        users[msg.sender].purchased = newTstBalance;
        tstToken.transferFrom(msg.sender, address(this), usdAmount);
        emit Deposited(msg.sender, usdAmount, newTstBalance);
    }

    function _getClaimable(
        address user,
        uint8 percentage
    ) private view returns (uint256) {
        return ((users[user].purchased * percentage) / HUNDRED_PERCENT);
    }

    function getAvailableAmount(address user) public view returns (uint256) {
        uint256 tokensFreed;
        uint256 timeElapsed = (block.timestamp - claimStart) / 30 days;
        if (timeElapsed >= 1) tokensFreed = _getClaimable(user, 10);
        else if (timeElapsed >= 2) tokensFreed = _getClaimable(user, 30);
        else if (timeElapsed >= 3) tokensFreed = _getClaimable(user, 50);
        else if (timeElapsed >= 4) tokensFreed = _getClaimable(user, 100);
        return (tokensFreed - users[msg.sender].claimed);
    }

    function withdrawTokens() external {
        require(block.timestamp >= claimStart, "Claim has not started yet");
        uint256 availableAmount = getAvailableAmount(msg.sender);
        require(availableAmount > 0, "No tokens to withdraw");
        users[msg.sender].claimed += availableAmount;
        tstToken.mint(msg.sender, availableAmount);
        emit Claimed(msg.sender, availableAmount);
    }

    function withdrawUSD() external onlyRole(DEFAULT_ADMIN_ROLE) {
        usdToken.transfer(owner, usdToken.balanceOf(address(this)));
    }
}
