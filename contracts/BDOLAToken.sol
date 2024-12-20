// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BDOLAToken is ERC20 {
    address public admin;

    constructor() ERC20("BDOLA Token", "BDOLA") {
        admin = msg.sender;
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == admin, "Only admin can mint");
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        require(msg.sender == admin, "Only admin can burn");
        _burn(msg.sender, amount);
    }
}
