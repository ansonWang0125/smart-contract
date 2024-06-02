// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address receiver, uint256 numTokens)
        external
        returns (bool);
    function allowance(address owner, address delegate)
        external
        view
        returns (uint256);
    function approve(address delegate, uint256 numTokens) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
}
