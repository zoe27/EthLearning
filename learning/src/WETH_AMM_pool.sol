pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WETH_AMM_pool is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public weth;     // WETH token
    IERC20 public token;    // Another ERC20 token

    uint256 public wethReserve;   // WETH reserve
    uint256 public tokenReserve;  // Token reserve

    // Event to track swaps
    event Swap(address indexed user, uint256 wethAmount, uint256 tokenAmount);
    // Event to track liquidity additions
    event LiquidityAdded(address indexed provider, uint256 wethAmount, uint256 tokenAmount);

    constructor(IERC20 _weth, IERC20 _token) Ownable(msg.sender) {
        weth = _weth;
        token = _token;
    }

    // Function to add liquidity to the pool
    function addLiquidity(uint256 _wethAmount, uint256 _tokenAmount) external onlyOwner {
        require(_wethAmount > 0 && _tokenAmount > 0, "Invalid amount");

        // Transfer WETH and tokens from the provider to the contract
        weth.safeTransferFrom(msg.sender, address(this), _wethAmount);
        token.safeTransferFrom(msg.sender, address(this), _tokenAmount);

        // Update reserves
        wethReserve += _wethAmount;
        tokenReserve += _tokenAmount;

        emit LiquidityAdded(msg.sender, _wethAmount, _tokenAmount);
    }

    // Function to perform a swap (WETH for Token or Token for WETH)
    function swap(uint256 _wethAmount) external {
        require(_wethAmount > 0, "Invalid WETH amount");

        // Calculate the amount of tokens to give the user based on constant product formula
        uint256 wethAfter = wethReserve + _wethAmount;
        uint256 tokenAfter = (wethReserve * tokenReserve) / wethAfter;
        uint256 tokenAmount = tokenReserve - tokenAfter;

        require(tokenAmount > 0, "Insufficient liquidity");

        // Transfer WETH from user to contract and tokens from contract to user
        weth.safeTransferFrom(msg.sender, address(this), _wethAmount);
        token.safeTransfer(msg.sender, tokenAmount);

        // Update reserves
        wethReserve += _wethAmount;
        tokenReserve -= tokenAmount;

        emit Swap(msg.sender, _wethAmount, tokenAmount);
    }

    // Helper function to get reserves
    function getReserves() external view returns (uint256, uint256) {
        return (wethReserve, tokenReserve);
    }

}