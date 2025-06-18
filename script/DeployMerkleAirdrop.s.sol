// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {FuryToken} from "../src/FuryToken.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18; // 100 tokens to the airdrop contract

    function run() external returns (MerkleAirdrop, FuryToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, FuryToken) {
        vm.startBroadcast();
        FuryToken token = new FuryToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer); // Mint 100 tokens to the airdrop contract
        token.transfer(address(airdrop), s_amountToTransfer); // Transfer 100 tokens to the airdrop contract
        console.log("MerkleAirdrop deployed at:", address(airdrop));
        vm.stopBroadcast();

        return (airdrop, token);
    }
}
