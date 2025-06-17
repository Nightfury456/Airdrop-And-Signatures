// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    // some list of addresses
    // Allow Someone in the list to claim ERC-20 tokens

    ////////////
    // ERRORS //
    ////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    ////////////
    // EVENTS //
    ////////////
    event Claim(address indexed account, uint256 amount);

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping (address => bool) private s_hasClaimed;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    ///////////////
    // FUNCTIONS //
    ///////////////

    /**
     * @notice Claim the airdrop tokens
     * @param account The address of the account claiming the tokens
     * @param amount The amount of tokens to claim
     * @param merkleProof The Merkle proof to verify the claim
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if(s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // calculate using hte account and the amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // verify the proof
        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        // transfer the tokens to the account
        i_airdropToken.safeTransfer(account, amount);
    }

    //////////////////////
    // GETTER FUNCTIONS //
    //////////////////////

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

}