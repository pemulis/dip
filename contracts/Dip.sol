pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dip is ERC20 {

  // fixed point math reference: https://forum.openzeppelin.com/t/designing-fixed-point-math-in-openzeppelin-contracts/2499

  private uint256 _lifespan;
  private uint256 _adjustmentFactor;
  private bool _distributing;

  // need to override balanceOf function from base, even though it's not virtual

  // look into using beforeTokenTransfer hook for transfer controls

  // needs name, symbol, target token address, price oracle address
  constructor() {
    _lifespan = 365;
    _adjustmentFactor = 1;
    _distributing = true;
  }

  // calculate balance based on percentage ownership and dilution
  function balanceOf() view override {}

  // user locks target token or LP token during distribution period for dip tokens
  function lock() {}

  // end distribution period, sell lockup tokens, release locked LP tokens, add liquidity to the Dip pool
  function dip() {
    _distributionActive = false;
  }

  // change adjustment factor, reward rebaser with Dip pool LP tokens
  function rebase() {
    // reward LP token hoard divided by remaining _lifespan
    _lifespan.sub(1);
  }
}
