// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

//contract
contract Day3 {}

//Value Types
contract Day5 {
    // Boolean
    bool public isMerge = true;

    // Integer
    int public I = -123;
    uint public U = 999999;
    int8 public I8 = -4;
    uint256 public U256 = 3;

    // Address
    address public HydaiAddr = 0x9A76D78F203Ec6f7289bB0178cb6C25f18A9911E;
    address payable public PayHydaiAddr = payable(HydaiAddr);

    // Enum
    enum Color { Blue, Green }
    Color public C = Color.Blue;
}

//Reference Types
contract Day6 {
    //Dynamic Array
    uint[] public x; //storage

    function f(uint[] memory memoryArray) public {
        x = memoryArray; //memory -> storage 傳copy
        uint[] storage y = x; //storage -> local storage 傳reference
        g(y); //local storage -> local storage; pass by reference
        h(x); //storage -> memory; pass by value
        console.log("%d %d %d", x[0], x[1], x[2]);
    }
    
    // storage 可以push
    function g(uint[] storage y) internal {
        y.push(1);
    }
    // memory 可以push
    function h(uint[] memory z) public pure {
        //z.push(6); TypeError: Member "push" is not available in uint256[] memory outside of storage. 嘿對不能改memory array大小
        z[1] = 3;
    }
    //bytes
    bytes public b;
    //string
    string public s;
    //Static array
    uint[2] public a;
    //struct
}

//Function、Visibility、State Mutability
contract Day7 {
    function hi() public pure returns (string memory) {
        return "Hello, Ethereum!";
    }
}
// 什麼是state? 會需要改變狀態的東西，例如balance
// State Mutability只有動到state的時候
// Etherscan可以看state

//Constructor
contract Day8A {
    int public I = 1234;
    uint public U;
    string public S = "Hello, Ethereum";
}

contract Day8B {
    int public I;
    uint public U;
    string public S;
    constructor(int _I, uint _U, string memory _S) {
        I = _I;
        U = _U;
        S = _S;
    }
}

//Receive Ether Function
contract Day9 {
    constructor() payable {}
    receive() payable external {}
}

//Send, Transfer
contract Day10 {
    //address function: balance, code, codehash, low-level call
    //address payable function: transfer, send
    constructor() payable {}
    receive() payable external {}

    function f() payable external {}

    function withdraw1() external {
        address payable Receiver = payable(msg.sender);
        Receiver.send(address(this).balance + 1); //successful transaction, transfer failure
    }

    function withdraw2() external {
        address payable Receiver = payable(msg.sender);
        Receiver.transfer(address(this).balance + 1); //transaction revert, transfer failure
    }
    // send 跟 transfer的差別，send就算失敗了也只會回傳false，不會revert。但transfer如果失敗了會revert
}

//Function Modifier
contract Day11 {
    address public owner;
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }
    constructor() payable {
        owner = msg.sender;
    }
    receive() payable external {}
    function withdraw() onlyOwner external {
        address payable Receiver = payable(msg.sender);
        Receiver.transfer(address(this).balance);
    }
}

//Mapping Types
contract Day12 {
    mapping(uint => uint) Students;
    function update(uint id, uint score) public {
        Students[id] = score;
    }
    function get(uint id) public view returns (uint) {
        return Students[id];
    }
}

//Control Structure
contract Day13 {
    uint[] Scores = [90, 91, 92, 93, 94];
    function X() public view returns (uint) {
        uint Sum = 0;
        for (uint index = 0; index < 5; index++) {
            //if (index == 3) continue;
            //if (index == 4) break;
            Sum = Sum + Scores[index];
        }
        return Sum;
    }

    function Y() public view returns (uint) {
        uint Sum = 0;
        uint index = 0;
        while (index < 5) {
            Sum = Sum + Scores[index];
            index++;
        }
        return Sum;
    }
}

//Event
contract Day14 {
    address public owner;
    event Create(address owner, uint256 value);
    event Receive(address indexed sender, uint256 value);
    event Withdraw(address indexed owner, uint256 indexed value);
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }
    constructor() payable {
        owner = msg.sender;
        emit Create(owner, msg.value);
    }
    receive() payable external {
        emit Receive(msg.sender, msg.value);
    }
    function withdraw() onlyOwner external {
        address payable Receiver = payable(msg.sender);
        uint256 value = address(this).balance;
        Receiver.transfer(value);
        emit Withdraw(Receiver, value);
    }
}

//Operator

//Summary
contract Day16 {
    address public owner;
    mapping(address => uint256) donationList;

    event Donate(address indexed sender, uint256 value);
    event Withdraw(address indexed owner, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can access this function");
        _;
    }

    constructor() {
        // 將合約的擁有者設定成建立合約的人
        owner = msg.sender;
    }

    // 收受捐款的函式
    function donate() public payable {
        donationList[msg.sender] += msg.value;
        emit Donate(msg.sender, msg.value);
    }

    // 查詢捐款總金額
    function getHistory() public view returns (uint256) {
        return donationList[msg.sender];
    }

    // 查詢 VIP 等級
    function getRank() public view returns (string memory) {
        if (donationList[msg.sender] > 10 ether) {
            return "UR";
        } else if (donationList[msg.sender] > 5 ether) {
            return "SR";
        } else if (donationList[msg.sender] > 1 ether) {
            return "R";
        } else if (donationList[msg.sender] > 0) {
            return "N";
        } else {
            return "None";
        }
    }

    // 提領餘額
    function withdraw() onlyOwner public {
        address payable receiver = payable(owner);
        uint256 value = address(this).balance;
        receiver.transfer(value);
        emit Withdraw(receiver, value);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// 跟比特幣的不同是比特幣是由共識機制產生的原始產物，而ERC20是由智能合約發行的

contract ERC20 is IERC20 {
    uint256 _totalSupply;
    mapping(address => uint256) _balance;
    mapping(address => mapping(address => uint256)) _allowance;
    string _name;
    string _symbol;
    address _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "ERROR: only owner can access this function");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;

        _balance[msg.sender] = 10000;
        _totalSupply = 10000;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERROR: mint to address 0");
        _totalSupply += amount;
        _balance[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERROR: burn from address 0");
        uint256 accountBalance = _balance[account];
        require(accountBalance >= amount, "ERROR: no more token to burn");
        _balance[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balance[account];
    }

    function _transfer(address from, address to, uint256 amount) internal {
        uint256 myBalance = _balance[from];
        require(myBalance >= amount, "No money to transfer");
        require(to != address(0), "Transfer to address 0");

        _balance[from] = myBalance - amount;
        _balance[to] = _balance[to] + amount;
        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 myAllowance = _allowance[from][msg.sender];
        require(myAllowance >= amount, "ERROR: myAllowance < amount");

        _approve(from, msg.sender, myAllowance - amount);
        _transfer(from, to, amount);
        return true;
    }
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721 {
    // Event
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    // Query
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    // Transfer
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    // Approve
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract ERC721 is IERC721, IERC721Metadata, IERC165 {
    mapping(address => uint256) _balances;
    mapping(uint256 => address) _owners;
    mapping(uint256 => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;
    string _name;
    string _symbol;
    mapping(uint256 => string) _tokenURIs;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: token id is not valid");
        return _tokenURIs[tokenId];
    }
    // URI是一個json檔

    function setTokenURI(uint256 tokenId, string memory URI) public {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: token id is not valid");
        _tokenURIs[tokenId] = URI;
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERROR: address 0 cannot be owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: tokenId is not valid Id");
        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner != to, "ERROR: owner == to");
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "ERROR: Caller is not token owner / approved for all");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: Token is not minted or is burn");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) public {
        require(msg.sender != operator, "ERROR: owner == operator");
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        address owner = _owners[tokenId];
        require(owner == from, "ERROR: Owner is not the from address");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender) || getApproved(tokenId) == msg.sender, "ERROR: Caller doesn't have permission to transfer");
        delete _tokenApprovals[tokenId];
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
        _safeTransfer(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        _safeTransfer(from, to, tokenId, "");
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERROR: ERC721Receiver is not implmeneted");
    }

    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "ERROR: Mint to address 0");
        address owner = _owners[tokenId];
        require(owner == address(0), "ERROR: tokenId existed");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function safemint(address to, uint256 tokenId, bytes memory data) public {
        mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERROR: ERC721Receiver is not implmeneted");
    }

    function safemint(address to, uint256 tokenId) public {
        safemint(to, tokenId, "");
    }

    function burn(uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(msg.sender == owner, "ERROR: only owner can burn");
        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    // Reference Link: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol#L429-L451
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0 /* to is a contract*/) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
