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
        uint[] storage y = x; // works, assigns a pointer, data location of y is storage
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
    constructor() payable {
        owner = msg.sender;
    }

    // 函式修飾子: 只有合約擁有者可以呼叫被修飾的函式本體
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 收錢
    receive() payable external{}

    // 領錢: 只有合約擁有者可以領
    function withdraw() onlyOwner external {
        address payable Receiver = payable(msg.sender);
        Receiver.transfer(address(this).balance);
    }
}