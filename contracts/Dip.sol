pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dip is ERC20 {

  // fixed point math reference: https://forum.openzeppelin.com/t/designing-fixed-point-math-in-openzeppelin-contracts/2499

  private uint256 _lifespan;
  private bool _distributing;
  private uint256 _initialSupply;
  private mapping (address => bool) _shareCalculated;
  private mapping (address => uint256) _shares; // percentage ownership

  // need to override balanceOf function from base, even though it's not virtual

  // look into using beforeTokenTransfer hook for transfer controls

  // modifier checking if share was set

  // needs name, symbol, target token address, price oracle address
  constructor() {
    _lifespan = 365;
    _distributing = true;
  }

  // calculate balance based on percentage ownership and total supply
  // return unknown if shares not set
  function balanceOf(address account) view override {}

  // user locks target token or LP token during distribution period for dip tokens
  function lock() public {
    require(_distributing === true);
  }

  // end distribution period, sell lockup tokens, release locked LP tokens, add liquidity to the Dip pool
  function dip() public {
    _distributing = false;
    // sell lockup tokens
    // release locked LP tokens
    // buy dip tokens and ETH, and fund the Dip/ETH pool
    // calculate _shares for the Dip/ETH pool
  }

  // set a user's share relative to their percentage of the initial total supply
  function calculateShare(address account) public {
    require(_distributing === false);
  }

  // change adjustment factor, reward rebaser with Dip pool LP tokens
  function rebase() public {
    // reward LP token hoard divided by remaining _lifespan
    _lifespan.sub(1);
    // adjust total supply
  }

  // on transfer, calculate tokens available to transfer based on total supply times share, and then calculate two users shares from new balances

  // for balance, calculate total supply times share

  // instead of tracking token balances per user, we track shares of the variable total supply

  // total supply increases from minting, and then adjusts up and down through rebase

  // user shares can be set during the dip function call

  // user shares are relative to the initial supply and whether their shares have been set yet

  // only users whose shares have been set can call transfer and approve

  // we will need to track balances before the dip, and shares after the dip, deleting the balance after calculating share

  // we'll need a way to update the Dip contract with the address of the Dip/ETH pool after deployment
}
