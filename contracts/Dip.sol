pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dip is ERC20 {

  // need to override balanceOf function from base, even though it's not virtual

  // look into using beforeTokenTransfer hook for transfer controls

  // needs name, symbol, target token address, price oracle address
  constructor() {}

  private uint256 _globalNonce;
  mapping (address => uint256) private _userNonces;
  private uint256 _rebaseDilution;

  // calculate balance based on percentage ownership and dilution
  function balanceOf() view override {}

  // user locks target token or LP token during distribution period for dip tokens
  function lock() {}

  // end distribution period, sell lockup tokens, and release LP tokens
  function dip() {}

  // nonce increments and token balances adjust up or down
  function rebase() {}
}
