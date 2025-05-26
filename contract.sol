// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Ini adalah versi Context sederhana yang kita buat manual
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Kontrak PoPP dengan semua fitur ditulis manual
contract PoPP is Context {
    // --- STATE VARIABLES (Variabel Inti) ---
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply; 

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // --- Ownable State ---
    address private _owner;

    // --- Pausable State ---
    bool private _paused;

    // --- EVENTS ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Ownable Event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Pausable Events
    event Paused(address account);
    event Unpaused(address account);

    // --- MODIFIERS ---
    modifier onlyOwner() {
        require(owner() == _msgSender(), "PoPP: Caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused(), "PoPP: Token activity is paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "PoPP: Token activity is not paused");
        _;
    }

    // --- CONSTRUCTOR ---
    constructor() {
        name = "PoPP";
        symbol = "POPP"; 
        decimals = 18;

        // Set initial owner
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);

        // Pausable defaultnya false (tidak paused)
        _paused = false;

        // Initial total supply (1 Miliar) & assign to deployer
        uint256 initialSupply = 1000000000 * (10**uint256(decimals)); 
        _mint(_msgSender(), initialSupply);
    }

    // --- ERC20 STANDARD VIEW FUNCTIONS ---
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address ownerAccount, address spender) public view returns (uint256) {
        return _allowances[ownerAccount][spender];
    }

    // --- ERC20 STANDARD WRITE FUNCTIONS ---
    function transfer(address recipient, uint256 amount) public virtual whenNotPaused returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual whenNotPaused returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "PoPP: Transfer amount exceeds allowance");
        
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    // --- SAFER ALLOWANCE FUNCTIONS ---
    function increaseAllowance(address spender, uint256 addedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual whenNotPaused returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "PoPP: Decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    // --- BURNABLE FUNCTIONS ---
    function burn(uint256 amount) public virtual whenNotPaused {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual whenNotPaused {
        uint256 currentAllowance = _allowances[account][_msgSender()];
        require(currentAllowance >= amount, "PoPP: Burn amount exceeds allowance");

        _approve(account, _msgSender(), currentAllowance - amount); 
        _burn(account, amount);
    }

    // --- PAUSABLE FUNCTIONS (accessible by owner) ---
    function pause() public virtual onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public virtual onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    
    // --- PAUSABLE VIEW FUNCTION ---
    function paused() public view returns (bool) {
        return _paused;
    }

    // --- OWNABLE FUNCTIONS ---
    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "PoPP: New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    

    // --- INTERNAL FUNCTIONS (Helper functions, diawali _) ---
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "PoPP: Transfer from the zero address");
        require(recipient != address(0), "PoPP: Transfer to the zero address");
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "PoPP: Transfer amount exceeds balance");
        
        _balances[sender] = senderBalance - amount;
        // Tambah saldo penerima, aman dari overflow karena Solidity >=0.8.0
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "PoPP: Mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount); 
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "PoPP: Burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "PoPP: Burn amount exceeds balance");

        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount); 
    }

    function _approve(address ownerAccount, address spender, uint256 amount) internal virtual {
        require(ownerAccount != address(0), "PoPP: Approve from the zero address");
        require(spender != address(0), "PoPP: Approve to the zero address");

        _allowances[ownerAccount][spender] = amount;
        emit Approval(ownerAccount, spender, amount);
    }
}
