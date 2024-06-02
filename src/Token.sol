// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

contract Token is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );

    uint256 totalSupply_;// total amount of token
    mapping(address => uint256) public balances; // account address mapping to token balances
    mapping(address => mapping(address => uint256)) public allowed; // all of the accounts approved to withdraw from a given account
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _mint(msg.sender, 100 * 10 ** uint256(decimals));
    }

    function totalSupply() external override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver,
                        uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    

    function approve(address delegate,
                        uint numTokens) public returns (bool) {
        allowed[tx.origin][delegate] = numTokens;
        emit Approval(tx.origin, delegate, numTokens);
        return true;
    }

    function toBytes(uint256 x) internal pure returns (bytes1) {
        bytes1 b;
        assembly { mstore(add(b, 32), x) }
        return b;
    }

    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i <= 0) {
            return "0";
        }
        uint j = _i;
        uint len = 0;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        j = _i;
        while (k > 0 && j != 0) {
            bstr[k--] = toBytes(uint8(48 + j % 10)); // Convert uint8 directly to byte
            j /= 10;
        }
        return string(bstr);
    }


    function transferFrom(address owner, address buyer,
                            uint numTokens) public returns (bool) {
    require(
        numTokens <= balances[owner],
        string(abi.encodePacked("balance not enough ", uintToString(numTokens), " > ", uintToString(balances[owner])))
    );
    require(
        numTokens <= allowed[owner][msg.sender], // msg.sender
        string(abi.encodePacked("allowed not enough ", uintToString(numTokens), " > ", uintToString(allowed[owner][msg.sender])))
    );
        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] =
                allowed[owner][msg.sender] - numTokens; // // msg.sender
        balances[buyer] = balances[buyer] + numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function _mint(address to, uint256 amount) internal {
        balances[to] += amount;
        totalSupply_ += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balances[from] -= amount;
        totalSupply_ -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
