// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MyToken
 * @dev A fully compliant ERC-20 token implementation from scratch.
 *      Includes minting, burning, allowances, and ownership control.
 */
contract MyToken {

    // ─────────────────────────────────────────────
    //  State Variables
    // ─────────────────────────────────────────────

    string  public name;
    string  public symbol;
    uint8   public decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256)                     private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // ─────────────────────────────────────────────
    //  Events  (ERC-20 standard)
    // ─────────────────────────────────────────────

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Extra events for ownership / mint / burn
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    // ─────────────────────────────────────────────
    //  Modifiers
    // ─────────────────────────────────────────────

    modifier onlyOwner() {
        require(msg.sender == owner, "MyToken: caller is not the owner");
        _;
    }

    // ─────────────────────────────────────────────
    //  Constructor
    // ─────────────────────────────────────────────

    /**
     * @param _name        Human-readable name  (e.g. "My Token")
     * @param _symbol      Ticker symbol        (e.g. "MTK")
     * @param _decimals    Decimal places       (18 is the standard)
     * @param _initialSupply  Tokens minted to deployer (in whole tokens, NOT wei)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8  _decimals,
        uint256 _initialSupply
    ) {
        name     = _name;
        symbol   = _symbol;
        decimals = _decimals;
        owner    = msg.sender;

        // Mint initial supply to deployer
        uint256 amount = _initialSupply * (10 ** uint256(_decimals));
        _mint(msg.sender, amount);

        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ─────────────────────────────────────────────
    //  ERC-20 Core Read Functions
    // ─────────────────────────────────────────────

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }

    // ─────────────────────────────────────────────
    //  ERC-20 Core Write Functions
    // ─────────────────────────────────────────────

    /**
     * @dev Transfer tokens to `to`.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve `spender` to spend up to `value` tokens on your behalf.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer `value` tokens from `from` to `to` using the allowance mechanism.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= value, "MyToken: transfer amount exceeds allowance");

        _transfer(from, to, value);

        // Decrease allowance (underflow safe — checked above)
        unchecked {
            _approve(from, msg.sender, currentAllowance - value);
        }

        return true;
    }

    /**
     * @dev Atomically increase the allowance granted to `spender`.
     *      Avoids the double-spend race condition.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decrease the allowance granted to `spender`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 current = _allowances[msg.sender][spender];
        require(current >= subtractedValue, "MyToken: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, current - subtractedValue);
        }
        return true;
    }

    // ─────────────────────────────────────────────
    //  Mint / Burn (owner-controlled)
    // ─────────────────────────────────────────────

    /**
     * @dev Mint `amount` new tokens and send them to `to`. Only callable by owner.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burn `amount` tokens from caller's balance.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Burn `amount` tokens from `from` using the allowance mechanism.
     */
    function burnFrom(address from, uint256 amount) external {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "MyToken: burn amount exceeds allowance");
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        _burn(from, amount);
    }

    // ─────────────────────────────────────────────
    //  Ownership
    // ─────────────────────────────────────────────

    /**
     * @dev Transfer contract ownership to `newOwner`.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "MyToken: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Renounce ownership — leaves the contract without an owner.
     *      WARNING: minting will be permanently disabled after this.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    // ─────────────────────────────────────────────
    //  Internal Helpers
    // ─────────────────────────────────────────────

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "MyToken: transfer from the zero address");
        require(to   != address(0), "MyToken: transfer to the zero address");
        require(_balances[from] >= value, "MyToken: transfer amount exceeds balance");

        unchecked {
            _balances[from] -= value;
            _balances[to]   += value;
        }

        emit Transfer(from, to, value);
    }

    function _approve(address _owner, address spender, uint256 value) internal {
        require(_owner   != address(0), "MyToken: approve from the zero address");
        require(spender  != address(0), "MyToken: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "MyToken: mint to the zero address");

        totalSupply     += amount;
        _balances[to]   += amount;

        emit Transfer(address(0), to, amount);
        emit Mint(to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "MyToken: burn from the zero address");
        require(_balances[from] >= amount, "MyToken: burn amount exceeds balance");

        unchecked {
            _balances[from] -= amount;
            totalSupply     -= amount;
        }

        emit Transfer(from, address(0), amount);
        emit Burn(from, amount);
    }
}