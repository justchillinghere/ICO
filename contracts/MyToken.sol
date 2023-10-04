// SPDX-License-Identifier: MIT
pragma solidity =0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MyToken
 * @dev A contract for a custom ERC20 token inherited from OpenZeppelin.
 */
contract MyToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint8 _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function addMinterRole(
        address newMinter
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, newMinter);
    }

    /**
     * @dev Mints new tokens and assigns them to the specified address.
     * Can only be called by the contract owner.
     *
     * @param to The address to which the new tokens will be assigned.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
