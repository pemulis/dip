pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./FixedPoint.sol";

contract Dip is ERC20 {
  using SafeMath for uint256;

  private address _targetToken;
  private address _baseToken;
  private address _targetPair;
  private address _dipPair;

  private bool _predip = true;
  private uint256 _startTime;
  private uint256 _initialSupply;
  private mapping (address => uint256) _shares;
  private mapping (address => mapping (address => uint256))  _shareAllowances;

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
    _startTime = block.timestamp;
  }

  function balanceOf(address account) public view override returns (uint256) {
    if (_predip === true) {
      return _balances[account];
    }
    if (_balances[account] > 0) {
      return FixedPoint.calculateMantissa(
        _balances[account],
        _initialSupply
      );
    }
    return FixedPoint.multiplyUintByMantissa(
      _totalSupply,
      _shares[account]
    );
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    if (_predip === true) {
      _transfer(_msgSender(), recipient, amount);
      return true;
    }
    if (shareCalculated[_msgSender()] === false) {
      _calculateShare(_msgSender());
    }
    amount = _convertAmountToShare(amount);
    require(_shares[_msgSender()] >= amount, "Insufficient balance.");
    _shares[_msgSender()].sub(amount);
    _shares[recipient].add(amount);
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    if (_predip === true) {
      return _allowances[owner][spender];
    }
    return FixedPoint.multiplyUintByMantissa(
      _totalSupply,
      _shareAllowances[owner][spender]
    );
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    if (_predip === true) {
      _approve(_msgSender(), spender, amount);
      return true;
    }
    if (_balances[_msgSender()] > 0) {
      _calculateShare(_msgSender());
    }
    amount = _convertAmountToShare(amount);
    _shareAllowances[_msgSender(), spender] = amount;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    if (_predip === true) {
      _transfer(sender, recipient, amount);
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
      return true;
    }
    if (_balances[sender] > 0) {
      _calculateShare(sender);
    }
    amount = _convertAmountToShare(amount);
    require(_shares[sender] >= amount, "Insufficient balance.");
    _shares[sender].sub(amount);
    _shares[recipient].add(amount);
  }

  function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
    if (_predip === true) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
    }
    if (_balances[_msgSender()] > 0) {
      _calculateShare(_msgSender());
    }
    addedValue = _convertAmountToShare(addedValue);
    _shareAllowances[_msgSender(), spender].add(addedValue);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
    if (_predip === true) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
      return true;
    }
    if (_balances[_msgSender()] > 0) {
      _calculateShare(_msgSender());
    }
    subtractedValue = _convertAmountToShare(subtractedValue);
    _shareAllowances[_msgSender(), spender].sub(subtractedValue);
  }

  function swap(uint256 amount) public {
    require(_predip === true, "The token distribution period is over.");
    IERC20(_targetToken).transferFrom(_msgSender(), address(this), amount);
    // sell target token
    // buy dip tokens and ETH and fund the Dip/ETH pool
  }

  function dip() public {
    require(block.timestamp >= _startTime.add(2 days), "Token distribution lasts for two days before the dip.");
    _predip = false;
    _calculateShare(_dipPair);
  }

  // set a user's share relative to their percentage of the initial total supply
  function _calculateShare(address account) internal {
    require(_predip === false, "The token distribution period is still active.");
    require(_balances[account] === 0, "Token share has already been calculated for this account.");
    uint256 share = FixedPoint.calculateMantissa(
      _balances[account],
      _initialSupply
    );
    delete _balances[account];
    _shares[account] = share;
  }

  function _convertAmountToShare(uint256 amount) internal {
    return FixedPoint.multiplyUintByMantissa(
      _totalSupply,
      amount
    );
  }

  // change total supply, reward rebaser with Dip pool LP tokens
  function rebase() public {
    // adjust total supply
    // reward LP token
  }
}



// protocol fee goes into multisig and address can be updated?
// dip LP tokens for specified pairs locked to farm doubledip tokens?
// doubledip tokens used to vote on new specified pairs, multisig, and spending?
// if share is not calculated for recipient, that's fine, and calling calculateShare will add to their current share from previous postdip transfers
// locking dip LP tokens to farm doubledip tokens incentivizes long-term liquidity for important pools








/* Outdated Notes */
// Double-dip tokens and double-dip functionality? Re-opening for a sale of additional dip tokens when approved by DD token holders. Project treasury fed by protocol fees collected when dip() is called. Dip tokens eligible for Double Dip token rewards determined by multisig or DD token holders. Double Dip only eligible to be triggered once a month. Double Dip locked for the first yeaer after launch to give time to set up a Double Dip DAO.

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
