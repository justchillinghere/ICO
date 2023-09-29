//SPDX-License-Identifier: Unlicense
pragma solidity =^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IMyICO.sol";

contract MyICO is IMyICO {
	struct User {
		uint256 purchased;
		uint256 claimed;
	}
	using SafeERC20 for IERC20Metadata;
	
	mapping (address => User) public users;
	IERC20Metadata public tstToken;
    IERC20Metadata public usdToken;
	uint256 public constant HUNDRED_PERCENT = 10_000; // 100.00%
	uint256 public claimStart;
    uint256 public tokenPrice = 2; // TST per USD token
	uint256 minPurchase = 10; // Min TST to buy
	uint256 maxPurchase = 100; // Max TST to buy
	
	event Claimed(address _user, uint256 _amountClaimed);
	event Deposited(address user, uint256 amountUSD, uint256 amountTST);

	constructor(address _tstToken, address _usdToken, uint256 _claimStart) {
		tstToken = IERC20Metadata(_tstToken);
		usdToken = IERC20Metadata(_usdToken);
		claimStart = _claimStart;
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

	function buyToken(uint256 amount) external {
		require(block.timestamp < claimStart, "ICO has ended");
		require(amount > 0, "Amount must be greater than 0");
		require(
			minPurchase <= amount <= maxPurchase 
			&& users[msg.sender].purchased <= maxPurchase, 
			"User can have 10 – 100 TST tokens on it's account"
			);
		uint256 purchased = amount * tokenPrice;
		tstToken.transferFrom(msg.sender, address(this),  amount);
		users[msg.sender].purchased += purchased;
		emit Deposited(msg.sender, amount, purchased);
	}

	function _getClaimable(uint8 percentage) private returns (uint256){
		return ((users[msg.sender].purchased *
            percentage) / HUNDRED_PERCENT);
	}
	
	function getAvailableAmount(address user) returns (uint256) {
		uint256 tokensFreed;
		uint256 timeElapsed = (block.timestamp - claimStart) / 30 days;
		if (timeElapsed >= 1)
			tokensFreed = _getClaimable(10);
		else if (timeElapsed >= 2)
			tokensFreed = _getClaimable(30);
		else if (timeElapsed >= 3)
			tokensFreed = _getClaimable(50);
		else if (timeElapsed >= 4)
			tokensFreed = _getClaimable(100);
		return (tokensFreed - users[msg.sender].claimed);
	}
	
	function withdrawTokens() external {
		require(block.timestamp >= claimStart, "Claim has not started yet");
		uint256 availableAmount = getAvailableAmount(msg.sender);
		require(_availableAmount > 0 && , "No tokens to withdraw");
		users[msg.sender].claimed += availableAmount;
		tstToken.mint(msg.sender, availableAmount);
		emit Claimed(msg.sender, availableAmount);
	}

	function withdrawUSD() external onlyAdmin {
		usdToken.transfer(owner, usdToken.balanceOf(address(this)));
	}
}
