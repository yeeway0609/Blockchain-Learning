// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is IERC20 {
    uint256 _totalSupply;
    mapping(address => uint256) _balance;
    mapping(address => mapping(address => uint256)) _allowance;
    string _name;
    string _symbol;
    address _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Error: only owner can access this function");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;

        _balance[msg.sender] = 10000;
        _totalSupply = 10000;
    }
     
    // mint
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address (0), "ERROR: mint to address 0");
        _totalSupply += amount;
        _balance[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // burn
    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address (0), "ERROR: burn to address 0");
        _totalSupply -= amount;
        require( _balance[account] >= amount, "ERROR: no more token to burn");
        _balance[account] -= amount;
        emit Transfer(account, address(0), amount);
    }

    // metadata
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }

    // 查詢總發行量
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // 查詢帳戶餘額
    function balanceOf(address account) public  view returns (uint256) {
        return _balance[account];
    }

    // 轉帳的子函式
    function _transfer(address from, address to, uint256 amount) internal {
        require(_balance[from] >= amount, "Not enough money to transfer.");
        require(to != address(0), "Transfer to address 0.");

        _balance[from] -= amount;
        _balance[to] += amount;
        emit Transfer(from, to, amount);
    }
    // 轉帳
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // 授權「amount」數量的代幣給第三方帳戶「spender」使用
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 回傅代幣擁有者「owner」授權給第三方帳戶「spender」的代幣數量
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }
    
    // 呼叫者(msg.sender）從代幣持有者(from）轉帳給接收者 (to）「amount」數量的代幣
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 myAllowance = _allowance[from][msg.sender];
        require(myAllowance >= amount, "Error: myAllowance < amount");
        _allowance[from][msg.sender] = myAllowance - amount;
        emit Approval(from, msg.sender, myAllowance - amount);

        _transfer(from, to, amount);
        return true;
    }
}