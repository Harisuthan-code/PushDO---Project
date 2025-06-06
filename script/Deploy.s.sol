// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Script.sol";
import "../src/Ability.sol";
import "../src/PushDAO.sol";
import "../src/Token contract/DAOtoken.sol";



contract DeployAll is Script{


    function run() external {

        uint256 deployerkey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerkey);

        MyToken token = new MyToken(1000000 * 10 ** 18);

        CheckDOAmember checkdoamember = CheckDOAmember(address(token));

        PushDo pushDO = new PushDo(address(checkdoamember));

        vm.stopBroadcast();
        
    }





}