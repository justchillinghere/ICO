//SPDX-License-Identifier: Unlicense
pragma solidity =0.8.18;

/**
 * @title IMyICO
 * @author justchillinghere
 * @dev Interface for the my implementation of an ICO contract.
 */
interface IMyICO {
    /**
     * @dev Emitted when admin initializes the ICO contract.
     * Users can start buying TST tokens after this `_buyStart`
     * and start claiming rewards after this `_claimStart`.
     *
     */
    event Initialized(uint256 _buyStart, uint256 _claimStart);
    /**
     * @dev Emitted when `user` deposited `amountUSD` tokens
     * to buy `amountTST` amount of TST tokens .
     *
     */
    event Deposited(address user, uint256 amountUSD, uint256 amountTST);
    /**
     * @dev Emitted when `user` claimed `_amountClaimed` tokens
     *
     */
    event Claimed(address _user, uint256 _amountClaimed);

    /**
     * @dev Initializes the ICO contract with the specified parameters.
     * It sets the beggingings of buying and claiming periods.
     * @param _buyStart The absolute time in seconds of starting the ICO buying period.
     * @param _claimStart The absolute time in seconds of starting the ICO claiming period.
     * Requirements:
     * - The contract must not have been initialized before.
     * - The buy start must be in the future.
     * - The claim start must be after the buy start.
     * - Only the contract admin roles can call this function.
     * Emits an {Initialized} event.
     *
     */
    function initialize(uint256 _buyStart, uint256 _claimStart) external;

    /**
     * @dev Buys TST tokens with USD tokens.
     * @param amount The amount of USD tokens to be used to buy TST tokens.
     * Requirements:
     * - The ICO buying period must have started.
     * - The user must have enough USD tokens to buy the specified amount of TST tokens.
     * - The user must have set permission for the ICO contract to transfer USD tokens.
     * Emits a {Deposited} event.
     *
     */
    function buyToken(uint256 amount) external;

    /**
     * @dev Claims TST tokens for the caller.
     * After 1 month, the user can claim up to 10% of their purchased tokens.
     * After 2 months, the user can claim up to 30% of their purchased tokens.
     * After 3 months, the user can claim up to 50% of their purchased tokens.
     * After 4 months, the user can claim up to 100% of their purchased tokens.
     * Requirements:
     * - The ICO claiming period must have started.
     * - The caller must have TST tokens to claim.
     * Emits a {Claimed} event.
     */
    function withdrawTokens() external;

    /**
     *
     * @param user The address of the user to check.
     * @return The amount of TST tokens that the user can claim.
     */
    function getAvailableAmount(address user) external view returns (uint256);

    /**
     * @dev Withdraws all USD tokens from the contract to the owner of the contract.
     * Requirements:
     * - Only the contract admin roles can call this function.
     */
    function withdrawUSD() external;
}
