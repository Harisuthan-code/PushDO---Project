// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {CheckDOAmember} from "./Ability.sol"; 
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";



contract PushDo{

    CheckDOAmember checkdoamember;
    using ECDSA for bytes32;


    struct CampaignData {
        address creator;
        string title;
        string description;
        uint256 sendTime;
        uint256 Votecount;
    }


    struct statusofcampign{

        uint256 yesvote;
        uint256 Novote;
    }



    address public owner;
    uint256 public  Max_Number_DAO_Members = 10;
    uint256 public Percent_Vote = 30;
    mapping (uint256 => CampaignData) public Campaigns_Data;
    mapping (uint256 => uint256) public yesvotecount;
    mapping(address => mapping(uint256 => bool)) public isalderyvoted;
    mapping (uint256 => bool) public approvedCampaigns;
    mapping(address => uint256) public userNonces;
    mapping (address => mapping (uint256 => bool)) public uservotedetails;
    mapping (uint256 => statusofcampign) public uservotestatus;
    uint256 public Id;



    event Campaigncreated (address creator , uint256 time);
    event messagesended(address sender , uint256 id ,  string title, string description , uint256 sendTime, uint256 nonce, uint256 expiry);

    modifier onlyowner(){

        require(msg.sender == owner , "you are not owner");
        _;
    }




    constructor(address _checkdoamember){

        owner = msg.sender;
        checkdoamember = CheckDOAmember(_checkdoamember);
    }
    

    //note - Creates a new reminder campaign. Anyone can create a campaign by sending exactly 0.5 ETH

    //Title - Message Title
    //Description - Message description
    //sendtime - This is the time after which the reminder should be sent to the user.
    

    function createCampaign(string memory Title , string memory Description , uint256 sendtime) payable external returns(uint256)  {


     require(msg.value == 0.5 ether, "You must send exactly 0.5 ETH to create a campaign");
     require(sendtime > block.timestamp , "you set Send time less");

     Id += 1;

     Campaigns_Data[Id].creator = msg.sender;
     Campaigns_Data[Id].title = Title;
     Campaigns_Data[Id].description = Description;
     Campaigns_Data[Id].sendTime = sendtime;
     Campaigns_Data[Id].Votecount = 0;


     emit Campaigncreated(msg.sender , block.timestamp);

    (bool success , ) = address(this).call{value : msg.value}("");
     require(success , "Transaction failed");

     return Id;


    }


   //Note - Allows eligible DAO members to vote on whether a reminder campaign should proceed. Only DAO members (who hold more than 10 tokens) can vote, and only once per campaign
   // id - id of the campaign
   // vote - bool value - if it true it's a yesvote otherwise it's No vote


    function vote_to_campaign(uint256 id , bool vote) external returns (bool)  {

    require(id <= Id , "not valid id");
    require(Campaigns_Data[id].creator != msg.sender  , "you're the creator you can't vote the campaign");
    require(Campaigns_Data[id].Votecount < Max_Number_DAO_Members , "Exceed the Max number of vote");
    require(Campaigns_Data[id].sendTime > block.timestamp , "expired");
    require(checkdoamember.checkbalance(msg.sender) > 1 , "for eligable DOA member you should hold more than 10 token");
    require(!isalderyvoted[msg.sender][id] , "you already voted");


    Campaigns_Data[id].Votecount += 1;

    if(vote){

        yesvotecount[id] += 1;

    }

    isalderyvoted[msg.sender][id] = true;
    return true;    


    }



    // This function is called to send the reminder (off-chain) to the user after the scheduled time has passed, and only if the campaign has enough “yes” votes to be approved.

    // How it works:

    // First checks if the campaign is eligible and approved using the internal campaignacceptornot function.

    // Validates that the campaign has actually been approved (approvedCampaigns[id] == true).

    // Uses the verifySignature function to ensure that the off-chain message is valid, secure, and signed by the correct sender.

    // Increments the user's nonce to prevent replay attacks.

    // Emits a messagesended event with full details of the reminder


    function sendnugetouser(uint256 id , uint256 expiry , bytes memory signature) external  {
    
    campaignacceptornot(id);
    require(approvedCampaigns[id] == true , "No approved");


    bool valid = verifySignature(msg.sender, Campaigns_Data[id].title, Campaigns_Data[id].description, Campaigns_Data[id].sendTime, userNonces[msg.sender], expiry, signature);
    require(valid, "Invalid signature");

    userNonces[msg.sender] += 1;

    emit messagesended(msg.sender , id ,  Campaigns_Data[id].title, Campaigns_Data[id].description , Campaigns_Data[id].sendTime, userNonces[msg.sender], expiry);


    }



    function campaignacceptornot(uint256 id) internal   {
    
    require(id <= Id , "not valid id");
    require(Campaigns_Data[id].Votecount > 0 , "vote should be greter than 0");
    require(Campaigns_Data[id].sendTime < block.timestamp , "not expired");
    
    uint256 votecouncampaignt =  yesvotecount[id];
    uint256 getvotepercent = (votecouncampaignt * 100) / 10;

    if(getvotepercent < Percent_Vote){

     approvedCampaigns[id] = false;        
        
    }

    else{

    approvedCampaigns[id] = true;

    }


    }



    function verifySignature(address user, string memory title, string memory description, uint256 sendTime,uint256 nonce,uint256 expiry,
    bytes memory signature
    ) internal view returns (bool) {

    require(block.timestamp <= expiry, "Signature expired");

    bytes32 messageHash = keccak256(abi.encodePacked(user, title, description, sendTime, nonce, expiry));
    bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));    
    return ethSignedMessageHash.recover(signature) == msg.sender;
    }



    //Allows users to vote on a reminder campaign after receiving it. 
    //Each user can vote only once per campaign to express approval (true) or disapproval (false)

    function votecampaign(uint256 id , bool vote) external returns (bool) {

    require(id <= Id , "not valid id");
    require(uservotedetails[msg.sender][id] == false , "you already voted");
    require(Campaigns_Data[id].sendTime < block.timestamp , "not expired");

    if(vote){

          uservotestatus[id].yesvote += 1;

    }


    else{

        uservotestatus[id].Novote += 1;
    }


    return true;

    }


    //Retrieves the current voting percentages for a given campaign, showing what portion of votes are “yes” and “no”


    function getvotestatus(uint256 id) external view  returns (uint256 yesPercent , uint256 noPercent ){

    uint256 totalVotes = uservotestatus[id].yesvote + uservotestatus[id].Novote;

    if(totalVotes == 0){

        return (0, 0);
    }

    else{

    yesPercent = (uservotestatus[id].yesvote * 100) / totalVotes;
    noPercent = (uservotestatus[id].Novote * 100) / totalVotes;

    }

        
    }

    function checkvotedornot(uint256 id) external view returns (bool){

        return isalderyvoted[msg.sender][id];
    }



    function getcampaigndetails(uint256 id) external view returns(CampaignData memory){

    return Campaigns_Data[id];

    }


   //change the Max number DAO members 

   function changemaxnumberofDAO(uint256 newMax) public onlyowner {
   

   require(newMax > Max_Number_DAO_Members , "can't be less then number of Max dao");
   Max_Number_DAO_Members = newMax;

   }



    //owner only can withdraw the Eth

    function withdraw() external onlyowner{

    uint256 balance = address(this).balance;

    require(balance > 0 , "don't have any eth to withdraw");

    (bool success , ) = owner.call{value : balance}("");

    require (success , "failed to withdraw");

    }

    //get the contract owner address
    function getowner() external view returns(address){

        return  owner;

    }


     receive() external payable {
    }




}