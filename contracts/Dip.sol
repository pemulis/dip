pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dip is ERC20 {

  // fixed point math reference: https://forum.openzeppelin.com/t/designing-fixed-point-math-in-openzeppelin-contracts/2499

  private address _targetToken;
  private address _baseToken;
  private address _targetPair;
  private address _dipPair;

  private bool _predip = true;
  private uint256 _initialSupply;
  private mapping (address => bool) _shareCalculated;
  private mapping (address => uint256) _shares;

  constructor(address targetToken, address baseToken) ERC20('Dip V1', 'DIP-V1') {
    _targetToken = target;
    _baseToken = baseToken;
    address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    _targetPair = address(uint(keccak256(abi.encodePacked(
      hex'ff',
      factory,
      keccak256(abi.encodePacked(targetToken, baseToken)),
      hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
    ))));
    _dipPair = address(uint(keccak256(abi.encodePacked(
      hex'ff',
      factory,
      keccak256(abi.encodePacked(address(this), baseToken)),
      hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
    ))));
  }

  /* ERC20 Token Function Overrides */

  function balanceOf(address account) public view override returns (uint256) {
    if (_predip === true) {
      return _balances[account];
    } else {
      // return _shares * _totalSupply
    }
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    if (_predip === true) {
      _transfer(_msgSender(), recipient, amount);
      return true;
    } else {
      require(shareCalculated[_msgSender()] === true);
      require(shareCalculated[recipient] === true);
      // calculate balances in memory based on _shares * _totalSupply
      // transfer the amount and calculate new shares for each user
    }
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    if (_predip === true) {
      return _allowances[owner][spender];
    } else {
      require(shareCalculated[owner] === true);
    }
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    if (_predip === true) {
      _approve(_msgSender(), spender, amount);
      return true;
    } else {
      require(shareCalculated[_msgSender()] === true);
    }
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    if (_predip === true) {
      _transfer(sender, recipient, amount);
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
      return true;
    } else {
      require(shareCalculated[sender] === true);
      require(shareCalculated[recipient] === true);
    }
  }

  function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
    if (_predip === true) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
    } else {
      require(shareCalculated[_msgSender()] === true);
    }
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
    if (_predip === true) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
      return true;
    } else {
      require(shareCalculated[_msgSender()] === true);
    }
  }

  /* Dip specific functions */

  // user locks target token during distribution period for dip tokens
  // reject ERC20 transfers unless target token and in predip period?
  function lock() public {
    require(_predip === true);
  }

  // end distribution period, sell lockup tokens, add liquidity to the Dip pool
  function dip() public {
    _predip = false;
    // sell lockup tokens
    // buy dip tokens and ETH, and fund the Dip/ETH pool
    // calculate _shares for the Dip/ETH pool
  }

  // set a user's share relative to their percentage of the initial total supply
  function calculateShare(address account) public {
    require(_predip === false);
    require(shareCalculated[account] === false);
    // calculate share
    delete _balances[account];
  }

  // change total supply, reward rebaser with Dip pool LP tokens
  function rebase() public {
    // adjust total supply
    // reward LP token
  }

  // issue more dip tokens
  function doubledip() public {
    // only multisig or token holders
  }
}

/**

Double-dip tokens and double-dip functionality? Re-opening for a sale of additional dip tokens when approved by DD token holders. Project treasury fed by protocol fees collected when dip() is called.

**/














/* Outdated Notes */

// only users whose shares have been set can call transfer and approve
// balanceOf, transfer, approve, etc. will need to work differently depending on whether the dip happened or not
// we'll need a way to update the Dip contract with the address of the Dip/ETH pool after deployment


// we will need to track balances before the dip, and shares after the dip, deleting the balance after calculating share

  // total supply increases from minting, and then adjusts up and down through rebase

  // user shares can be set after the dip function call

  // user shares are initially set relative to the initial supply
  // instead of tracking token balances per user, we track shares of the variable total supply
  // for balance, calculate total supply times share

  // look into using beforeTokenTransfer hook for transfer controls

  // modifier checking if share was set

    // need to override balanceOf function from base, even though it's not virtual
