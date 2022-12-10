// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestContract { 
    // Boolean 
    bool public isMerge = true;

    // Integer 
    int public I = -123;
    uint public U = 9999;
    int8 public  I8 = -4;
    int256 public I256 = 2345353; 

    // Address
    address public YeewayAddr = 0x702DD70bDF7c85D61aA77801b81F555E8115eF55;
    address payable public PayYeewayAddr = payable(YeewayAddr);

    // Enum 
    enum Color {red, yellow, green}
    Color public a = Color.red;
    Color public c = Color.green;

    // The data location of x is storage. This is the only place where the data location can be omitted.
    uint [] x;
    // The data location of memoryArray is memory.
    function f(uint [] memory memoryArray) public {
        x = memoryArray; // works, copies the whole array to storage
        // uint[] storage y = x; // works, assigns a pointer, data location of y is storage
        g(x); // calls g, handing over a reference to x
        h(x); // calls h and creates an independent, temporary copy in memory
    }
    function g(uint [] storage) internal pure {}
    function h(uint [] memory) public pure {}
}


contract Hello { 
    // 建構子
    int public I;
    uint public U;
    string public S;
    constructor(int _I, uint _U, string memory _S) {
        I = _I;
        U = _U;
        S = _S;
    }

    // 函式
    function hi() public pure returns (string memory) {
        return "Hello Ethereum!";
    }
}


contract PiggyBank {
    address public owner; 
    event Create(address owner, uint256 value); // 建立事件
    event Receive(address indexed sender, uint256 value);
    event Withdraw(address indexed owner, uint256 indexed value); // 重要資訊可以標記索引，但最多標記三個參數
 
    constructor() payable {
        owner = msg.sender;
        emit Create(owner, msg.value); // 觸發事件
    }

    // 函式修飾子: 只有合約擁有者可以呼叫被修飾的函式本體
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 收錢
    receive() payable external{
        emit Receive(msg.sender, msg.value);
    }

    // 領錢: 只有合約擁有者可以領
    function withdraw() onlyOwner external {
        address payable receiver = payable(msg.sender);
        uint256 value = address(this).balance;
        receiver.transfer(value);
        emit Withdraw(receiver, value);
    }
}


// Mapping Types 映射型態
contract Class {
    mapping(uint => uint) Students; // 學號對應到成績

    function Update(uint id, uint score) public {
        Students[id] = score;
    }

    function GetScore(uint id) public view returns (uint) {
        return Students[id];
    }
}


// control statement
contract A {
    uint[] Scores = [90, 91, 92, 93, 94];
    
    function X() public view returns (uint) {
        uint Sum = 0;
        for (uint index = 0; index < 5; index++) {
            Sum = Sum + Scores [index];
        }
        // uint index = 0;
        // while (index < 5) {
        //     Sum = Sum + Scores [index];
        //     index++;
        // }
        return Sum;
    }
}


// 實況主捐款合約
contract Donation {
    address public owner;
    mapping (address => uint256) donationList;

    event Donate(address indexed sender, uint256 value);
    event Withdraw(address indexed owner, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can access this function!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // 收受捐款
    function donate() public payable { 
        donationList[msg.sender] += msg.value;
        emit Donate(msg.sender, msg.value);
    }

    // 查詢捐款總金額
    function getHistory() public view returns (uint256) {
        return donationList[msg.sender];
    }

    // 查詢VIP等級
    function getRank() public view returns (string memory) {
        if (donationList[msg.sender] > 10 ether) {
            return "UR";
        } else if (donationList[msg.sender] > 5 ether) {
            return "SR";
        } else if (donationList[msg.sender] > 1 ether) {
            return "R"; 
        } else if (donationList[msg.sender] > 0 ether) {
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

// How to import
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 10000);
    }
}
contract MyNFT is ERC721 {
    constructor() ERC721("MyNFT", "MNFT") {
        for (uint256 id = 0; id <= 10; id++) {
            _safeMint (msg. sender, id);
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://nft.example.com/";  
    }
}