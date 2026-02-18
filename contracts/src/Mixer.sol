// SDPX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";

contract Mixer is IncrementalMerkleTree {
    IVerifier public immutable verifier;

    mapping(bytes32 => bool) public commitments;
    uint256 public constant DENOMINATION = 0.001 ether;

    error commitmentAlreadyUsed(bytes32 commitment);
    error depositAmountNotCorrect(uint256 amountSent, uint256 expected);

    event deposit(bytes32 insertedCommitment, uint32 insertedIndex, uint256 insertTimeStamp);

    constructor(address _verifier, uint32 _merkleTreeDepth, Poseidon2 _hasher)
        IncrementalMerkleTree(_merkleTreeDepth, _hasher)
    {
        verifier = IVerifier(_verifier);
    }

    /// @notice Deposit funds into the mixer
    function deposit(bytes32 _commitment) external payable {
        if (commitments[_commitment]) {
            revert commitmentAlreadyUsed(_commitment);
        }
        if (msg.value != DENOMINATION) {
            revert depositAmountNotCorrect(msg.value, DENOMINATION);
        }
        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;
        emit deposit(_commitment, insertedIndex, block.timestamp);
    }

    /// @notice Withdraw funds from mixer
    function withdraw(bytes _proof) external {}
}
