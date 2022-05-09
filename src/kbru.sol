// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/52eeebecda140ebaf4ec8752ed119d8288287fac/contracts/token/ERC20/ERC20.sol";


contract Kbru is ERC20 {

    address public minter;
    mapping(address => uint256) private _sendAmount;

    event SendToken(address from, address to, uint256 value);
    event MultiSendToken(address from, address[] to, uint256 value);

    event DebugUint(uint debugInt);
    event DebugAddress(address debugAddress);

    constructor() ERC20("Kbru Token", "KBRU") {    // decialはデフォルトで18
        _mint(msg.sender, 10000000 * 10**18); // 1000万 x 10^18
        minter = msg.sender;
    }

    function mint(uint amount) public {
        require(msg.sender == minter);    // ミントはコントラクトの製作者のみが可能な仕様
        require(amount < 1e60);
        _mint(msg.sender, amount * 10**18);
    }

    function multiSafeTransfer(address[] calldata receivers, uint amount) public {
        require(amount * receivers.length <= balanceOf(msg.sender), "Insufficient balance.");

        for (uint i=0; i< receivers.length; i++) {
            _transfer(msg.sender, receivers[i], amount);
            _sendAmount[msg.sender] += amount;  // update total send amount
        }

        emit MultiSendToken( msg.sender, receivers, amount );
    }

    function transferKbru(
        address to,
        uint256 amount
    ) public returns (bool) {
        _transfer(msg.sender, to, amount);

        // update total send amount
        _sendAmount[msg.sender] += amount;

        return true;
    }
    
    function sendAmountOf(address account) public view returns (uint256) {
        return _sendAmount[account];
    }

    // invalidate transfer function
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        emit DebugAddress(to);
        emit DebugUint(amount);
        return true;
    }

}