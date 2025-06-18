// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {FuryToken} from "../src/FuryToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    FuryToken public token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4; // 100 tokens to the airdrop contract
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address USER;
    uint256 userPrivateKey;

    function setUp() public {
        if(!isZkSyncChain()) {
            // deploy with the script
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            // Deploy the token
            token = new FuryToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND); // Mint 100 tokens to the airdrop contract
            token.transfer(address(airdrop), AMOUNT_TO_SEND); // Transfer 100 tokens to the airdrop contract
        }

        (USER, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUserCanClaim() public {
        uint256 startingBalnce = token.balanceOf(USER);

        vm.prank(USER);
        airdrop.claim(USER, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = token.balanceOf(USER);
        console.log("User balance after claim: %s", endingBalance);
        assertEq(endingBalance - startingBalnce, AMOUNT_TO_CLAIM);
    }
}
