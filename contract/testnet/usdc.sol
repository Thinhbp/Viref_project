// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract usdc is  ERC20 {
    constructor() public ERC20("Fake USDC", "USDC") {
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mintToken(uint _amount) public {
        _mint(msg.sender, _amount);
    }
}