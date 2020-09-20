pragma solidity ^0.7.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dip is ERC20 {

  private uint256 _globalNonce;
  mapping (address => uint256) private _userNonces;
  private uint256 _rebaseDilution;
  private bool _distributing;

  // need to override balanceOf function from base, even though it's not virtual

  // look into using beforeTokenTransfer hook for transfer controls

  // needs name, symbol, target token address, price oracle address
  constructor() {
    _globalNonce = 0;
    _distributing = true;
  }

  // calculate balance based on percentage ownership and dilution
  function balanceOf() view override {}

  // user locks target token or LP token during distribution period for dip tokens
  function lock() {}

  // end distribution period, sell lockup tokens, and release LP tokens
  function dip() {
    _distributionActive = false;
  }

  // nonce increments and token balances adjust up or down
  function rebase() {
    _globalNonce.add(1);
  }

  function _recalculateBalance(address account) private {
    uint256 _difference = _globalNonce.sub(_userNonces[account])
    _userNonces[account] = _globalNonce;
  }

  /**
   * @dev See {IERC20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) public override returns (bool) {
      _recalculateBalance(recipient);
      _transfer(_msgSender(), recipient, amount);
      return true;
  }

  /**
   * @dev See {IERC20-allowance}.
   */
  function allowance(address owner, address spender) public view override returns (uint256) {
      return _allowances[owner][spender];
  }

  /**
   * @dev See {IERC20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) public override returns (bool) {
      _recalculateBalance(recipient);
      _approve(_msgSender(), spender, amount);
      return true;
  }

  /**
   * @dev See {IERC20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {ERC20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for ``sender``'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
      _recalculateBalance(recipient);
      _transfer(sender, recipient, amount);
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
      return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
      _recalculateBalance(recipient);
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IERC20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
      _recalculateBalance(recipient);
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
      return true;
  }
}
