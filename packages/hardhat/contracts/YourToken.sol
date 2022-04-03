pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    constructor() ERC20("Gold", "GLD") {
        // _mint( ~~~YOUR FRONTEND ADDRESS HERE~~~~ , 1000 * 10 ** 18);
        _mint(0x23D4e5c75ec487112b70E9E4c0F1D2c0abCA7162, 1000 * 10 ** 18);
    }
}
