//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.18;

/**
 * @title IMyICO
 * @author justchillinghere
 * @dev Interface for the my implementation of an ICO contract.
 */
interface IMyICO {
    function buyToken(uint256 amount) external;

    function withdrawTokens() external;

    function getAvailableAmount(
        address user
    ) external view returns (uint256 availableAmount);

    function withdrawUSD() external;
}
