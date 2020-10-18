pragma solidity ^0.7.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "./FixedPoint.sol";

contract Dip is ERC20 {
  using SafeMath for uint256;
  IUniswapV2Router02 public UniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  private address _targetToken;
  private address _baseToken;
  private address _targetPair;
  private address _dipPair;
  private address _protocolFeeWallet;
  private address _protocolFee;

  private bool _predip = true;
  private uint256 _startTime;
  private uint256 _initialSupply;
  private mapping (address => uint256) _shares;
  private mapping (address => mapping (address => uint256))  _shareAllowances;

  constructor(address targetToken, address baseToken, address protocolFeeWallet) ERC20('Dip V1', 'DIP-V1') {
    _targetToken = target;
    _baseToken = baseToken;
    _protocolFeeWallet = protocolFeeWallet;
    address uniswapFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    _targetPair = address(uint(keccak256(abi.encodePacked(
      hex'ff',
      uniswapFactory,
      keccak256(abi.encodePacked(targetToken, baseToken)),
      hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
    ))));
    _dipPair = address(uint(keccak256(abi.encodePacked(
      hex'ff',
      uniswapFactory,
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

  function swap(uint256 amountIn, uint256 amountOut) public {
    require(_predip === true, "The token distribution period is over.");
    IERC20(_targetToken).transferFrom(_msgSender(), address(this), amountIn);
    IERC20(_targetToken).approve(address(UniswapV2Router02), amountIn);
    address[] memory path = new address[](2);
    path[0] = address(_targetToken);
    path[1] = address(_baseToken);
    uint[] memory amounts = UniswapV2Router02.swapExactTokensForTokens(
      amountIn,
      amountOut,
      path,
      this(address),
      block.timestamp
    );
    uint256 _actualAmountOut = amounts[1];
    uint256 _swapFee = _actualAmountOut.div(100).mul(5);
    uint256 _amountLeft = _actualAmountOut.sub(_swapFee);
    _protocolFee.add(_swapFee);
    _mint(_msgSender(), amountIn);
    // use 50% of _amountLeft to buy dip tokens

    // fund the dip/basetoken pool

  }

  function dip() public {
    require(block.timestamp >= _startTime.add(2 days), "Token distribution lasts for two days before the dip.");
    _predip = false;
    _calculateShare(_dipPair);
    IERC20(_baseToken).transfer(_protocolFeeWallet, _protocolFee);
  }

  function rebase() public {
    // adjust total supply up or down based on target token price
    // reward LP token
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
}



// protocol fee goes into multisig and address can be updated?
// dip LP tokens for specified pairs locked to farm doubledip tokens?
// doubledip tokens used to vote on new specified pairs, multisig, and spending?
// if share is not calculated for recipient, that's fine, and calling calculateShare will add to their current share from previous postdip transfers
// locking dip LP tokens to farm doubledip tokens incentivizes long-term liquidity for important pools
// for token distro, amountOut should be calculated at the UI level
