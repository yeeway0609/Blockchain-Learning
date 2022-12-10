// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    // Mint
    function mint(address to, uint256 tokenId) external;
    function safemint(address to, uint256 tokenId, bytes memory data) external;
    function safemint(address to, uint256 tokenId) external;
    // Burn
    function burn(uint256 tokenId) external;
}

interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}


contract ERC271 is IERC721, IERC721Metadata, IERC165 {
    mapping(address => uint256) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;
    string _name;
    string _symbol;
    mapping(uint => string) _tokenURIs;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    //IERC721Metadata
    function name () public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        address owner = _owners[tokenId];
        require (owner != address (0), "ERROR: token id is not valid");
        return _tokenURIs[tokenId];
    }

    function setTokenURI(uint256 tokenId, string memory URI) public {
        address owner = _owners[tokenId];
        require(owner != address (0), "ERROR: token id is not valid");
        _tokenURIs[tokenId] = URI;
    }

    // IERC165
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    // IERC721
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERROR: address 0 can not be owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: Token id is not valid");
        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner != to, "ERROR: Owner can not approve itself");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERROR: You are not token owner or approved for all");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: Token is not minted or is burn");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        address owner = msg.sender;
        require(owner != operator, "owner can not be operator");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        address owner = _owners[tokenId];
        require(from == owner, "ERROR: the toen is not transfered from the owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender) || msg.sender == getApproved(tokenId), "ERROR: Caller does not have oermission to transfer");
        delete _tokenApprovals[tokenId];
        _balances[from] += 1;
        _balances[to] -= 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        _transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "EEROR: ERC721Reciever is not implementered");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
        _safeTransfer(from, to, tokenId, data);
    } 

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        _safeTransfer(from, to, tokenId, "");
    }

    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "ERROR: Mint to address 0");
        address owner = _owners[tokenId];
        require(owner == address(0), "ERROR: token id existed");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address (0), to, tokenId);
    }

    function safemint(address to, uint256 tokenId, bytes memory data) public {
        mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "EEROR: ERC721Reciever is not implementered");
    }

    function safemint(address to, uint256 tokenId) public {
        safemint(to, tokenId, "");
    }

    function burn(uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(msg.sender == owner, "EEROR: only owner can burn");
        _balances[owner] -= 1;
        delete owner; // _owners[tokenId] = address(0)
        delete _tokenApprovals[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
    
    // IERC721Receiver
    // Reference: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // @solidity memory-safe-assembly
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