# Reminder Campaign DApp

# Overview
This project is inspired by Nudge, a decentralized reminder system designed to help users keep track of their important tasks through community-approved reminder campaigns.

The core idea is to allow users to create reminder campaigns by staking a small amount of ETH. These campaigns are then voted on by DAO members, ensuring only meaningful reminders get approved and sent out. After a campaign’s scheduled time passes and it gains enough community approval, the reminder message is securely sent to the user off-chain.

This decentralized approach ensures reminders are trustworthy, spam-free, and governed by community consensus.

#Key Features

Create Reminder Campaigns: Anyone can create a campaign by sending 0.5 ETH, providing a title, description, and future send time.

Community Voting: DAO members with sufficient token holdings vote on whether the reminder should proceed.

Approval Threshold: Campaigns are approved only if the percentage of “yes” votes crosses a defined threshold.

Secure Off-Chain Messaging: After approval and expiry, reminders are sent off-chain with cryptographic signature verification to ensure authenticity.

User Feedback: After receiving reminders, users can vote to approve or disapprove the campaign once, providing continuous feedback.

# Technologies Used

Solidity — Smart contract development

Foundry — Smart contract testing framework

# Functionality Breakdown

`createCampaign(string Title, string Description, uint256 sendtime)`
Creates a new reminder campaign by accepting exactly 0.5 ETH. Validates that the reminder’s send time is in the future and stores the campaign data. Returns a unique campaign ID.

`votecampaign(uint256 id, bool vote)`
Allows users to vote once per campaign after receiving the reminder. Users can approve or disapprove the campaign. Prevents double voting.

`sendnugetouser(uint256 id, uint256 expiry, bytes signature)`
Sends the reminder message off-chain after the scheduled time, but only if the campaign has been approved by DAO voting. Uses cryptographic signature verification for security.

`campaignacceptornot(uint256 id)`
Internal function to check if a campaign has met the approval criteria based on votes and expiry.

`verifySignature(...)`
Validates that an off-chain message is signed by the correct user and has not expired, preventing replay attacks.

`getvotestatus(uint256 id)`
Returns the current voting percentages for “yes” and “no” votes on a campaign.





# Getting Started


# Clone the repository
git clone <https://github.com/Harisuthan-code/PushDO---Project>
cd PushDO---Project

# Install OpenZeppelin Contracts
forge install OpenZeppelin/openzeppelin-contracts


# Compile contracts

forge build


# Run tests

forge test

# Deploy contracts

forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> src/PushDAO.sol:PushDAO









