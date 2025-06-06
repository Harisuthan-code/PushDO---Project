// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {PushDo} from "../src/PushDAO.sol";
import {MyToken} from "../test/Mocktokencontract.t.sol";
import {CheckDOAmember} from "../test/Mocktoken.t.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";



contract MainTest is Test {
    using ECDSA for bytes32;
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;

    PushDo public pushDo;
    MyToken public token;
    CheckDOAmember public checkDOAmember;

    function setUp() public {
        owner = address(0x123);
        user1 = address(0x456);
        user2 = address(0x789);
        user3 = address(0xabc);
        user4 = address(0xdef);
        user5 = makeAddr("user5");
        vm.label(owner, "Owner");
        vm.label(user1, "User1");
        vm.label(user2, "User2");
        
        vm.startPrank(owner);
        token = new MyToken(1000000 * 10 ** 18);
        checkDOAmember = new CheckDOAmember(address(token));
        pushDo = new PushDo(address(checkDOAmember));
        token.mint(user2, 100000);
        token.mint(user3, 100000);
        token.mint(user4, 100000);
        token.mint(user5, 100000);
        vm.stopPrank();

    }

    function testtokebalance() external{
       vm.prank(owner);
       assert(checkDOAmember.checkbalance(owner) == 1000000 * 10 ** 18);
    }


    // function testgivetokens() external{

    //     token.mint(user2 , 1000000);
        
    //     vm.prank(user2);
    //     assert(checkDOAmember.checkbalance() == 1000000);


    // }



   function testcreatecampaign() external{

    vm.deal(user1, 1 ether);
    vm.prank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);
    // console2.log("Campaign created successfully with ID:", pushDo.Campaigns_Data(1));

   }


   function testerrorcreatecampaign() external {
    vm.deal(user1, 0.1 ether);
    vm.prank(user1);
    vm.expectRevert("You must send exactly 0.5 ETH to create a campaign");
    pushDo.createCampaign{value: 0.1 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    }


    function testvotecampaigncheck() external{

    vm.deal(user1, 1 ether);
    vm.prank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);
    vm.warp(block.timestamp + 1 days);

    vm.prank(user2);
    pushDo.vote_to_campaign(1, true);
    (, , , ,uint256 voteCount) = pushDo.Campaigns_Data(1);
    assert(voteCount == 1);
    assert(pushDo.yesvotecount(1) == 1);
    assert(pushDo.isalderyvoted(user2, 1) == true);

    }


    function testvotecampaignerror1() external {
    token.mint(user1, 1000);
    vm.deal(user1, 1 ether);
    vm.startPrank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);
    vm.expectRevert("you're the creator you can't vote the campaign");
    pushDo.vote_to_campaign(1, true);
    vm.stopPrank();

    }



    function testvotecampaignerror3() external {

    
    vm.deal(user1, 1 ether);
    vm.prank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);


    vm.startPrank(user2);
    pushDo.vote_to_campaign(1, true);
    vm.expectRevert("you already voted");
    pushDo.vote_to_campaign(1, true);
    vm.stopPrank();

    }








    function testsendnudge() external {

    vm.deal(user1, 1 ether);
    vm.prank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);



    vm.prank(user2);
    pushDo.vote_to_campaign(1, true);
    (, , , ,uint256 voteCount) = pushDo.Campaigns_Data(1);
    assert(voteCount == 1);
    assert(pushDo.yesvotecount(1) == 1);
    assert(pushDo.isalderyvoted(user2, 1) == true);


    vm.prank(user3);
    pushDo.vote_to_campaign(1, true);
    (, , , ,uint256 voteCount2) = pushDo.Campaigns_Data(1);
    assert(voteCount2 == 2);
    assert(pushDo.yesvotecount(1) == 2);
    assert(pushDo.isalderyvoted(user3, 1) == true);


    
    vm.prank(user4);
    pushDo.vote_to_campaign(1, true);
    (, , , ,uint256 voteCount3) = pushDo.Campaigns_Data(1);
    assert(voteCount3 == 3);
    assert(pushDo.yesvotecount(1) == 3);
    assert(pushDo.isalderyvoted(user4, 1) == true);


     
    vm.prank(user5);
    pushDo.vote_to_campaign(1, true);
    (, , , ,uint256 voteCount4) = pushDo.Campaigns_Data(1);
    assert(voteCount4 == 4);
    assert(pushDo.yesvotecount(1) == 4);
    console.log("yes vote count" , pushDo.yesvotecount(1));
    assert(pushDo.isalderyvoted(user5, 1) == true);



    (, string memory titlecampi5, string memory descriptioncampi5, uint256 sendtimecampi5 , ) = pushDo.Campaigns_Data(1);


    string memory message = titlecampi5;
    string memory description = descriptioncampi5;
    uint256 sendTime = sendtimecampi5;
    uint256 Noonce = 0;
    uint256 expiration = block.timestamp + 15 days;


    uint256 Privatekey = 0xA11CE;
    address nudgeSender = vm.addr(Privatekey);


    bytes32 messageHash = keccak256(abi.encodePacked(nudgeSender, message, description, sendTime, Noonce, expiration));    
    bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(Privatekey, ethSignedMessageHash);
    bytes memory signature = abi.encodePacked(r, s, v);

    vm.warp(block.timestamp + 10 days);
    vm.startPrank(nudgeSender);
    pushDo.sendnugetouser(1, expiration , signature);
    vm.stopPrank();


    assert(pushDo.userNonces(nudgeSender) == 1);
    assert(pushDo.approvedCampaigns(1) == true);


    }   



    function testwithdraw() external{

    vm.deal(user1, 1 ether);
    vm.prank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);

    vm.prank(owner);
    pushDo.withdraw();
    assert(address(pushDo).balance == 0);
    }



    function testwithdrawerror() external {
        vm.prank(user1);
        vm.expectRevert("you are not owner");
        pushDo.withdraw();
    }



    function testchangeDOAmember() external{

        vm.prank(owner);
        pushDo.changemaxnumberofDAO(15);
        assert(pushDo.Max_Number_DAO_Members() == 15);

    }

    function testvotecampaign() external{

        
    vm.deal(user1, 1 ether);
    vm.prank(user1);
    pushDo.createCampaign{value : 0.5 ether}("Test Campaign", "This is a test campaign", block.timestamp + 4 days);
    assert(pushDo.Id() == 1);


    vm.prank(user2);
    vm.warp(block.timestamp + 10 days);
    pushDo.votecampaign(1, true);
    (uint256 yesvote , uint256 Novote) = pushDo.uservotestatus(1);
    assert(yesvote == 1);
    assert(Novote == 0);

    }




}
