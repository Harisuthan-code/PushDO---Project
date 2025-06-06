

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract CheckDOAmember{

    using SafeERC20 for IERC20;

    IERC20 public token;


    
    constructor(address _token) {
        token = IERC20(_token);
    }


    function checkbalance(address user) external view returns(uint256){

       uint256 tokenbalance =  token.balanceOf(user);

       return tokenbalance;

    }

    function tranfer(address _recipient,uint256 amount) external {

        token.safeTransfer(_recipient , amount);
    }

    function transferfrom(address spender ,uint256 amount) external {
        
        token.safeTransferFrom(msg.sender , spender , amount);
    }



   }

    

