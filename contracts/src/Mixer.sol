// SDPX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";
import {IVerifier} from "./Verifier.sol";

contract Mixer is IncrementalMerkleTree {
    IVerifier public immutable verifier;

    mapping(bytes32 => bool) public commitments;
    mapping(bytes32 => bool) public nullifierHashs;
    uint256 public constant DENOMINATION = 0.001 ether;

    error commitmentAlreadyUsed(bytes32 commitment);
    error depositAmountNotCorrect(uint256 amountSent, uint256 expected);
    error unknownRootHash(bytes32 unknownRootHash);
    error nullifierHashAlreadyUsed(bytes32 alreadyUsedNullifierHash);
    error invalidProof();
    error paymentFailed(address recipient, uint256 amount);
    event deposit(bytes32 indexed insertedCommitment, uint32 insertedIndex, uint256 insertTimeStamp);
    event withdraw(address indexed recipient, bytes32 nullifierHash);

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
    function withdraw(bytes _proof, bytes32 _rootHash, bytes32 _nullifierHash, address _recipient) external {
        if (_rootHash != rootHash) {
            revert unknownRootHash(_rootHash);
        }
        if (nullifierHashs[_nullifierHash]) {
            revert nullifierHashAlreadyUsed(_nullifierHash);
        }
        bytes32[] memory publicInputs = new bytes32[](3);
        publicInputs[0] = _rootHash;
        publicInputs[1] = _nullifierHash;
        publicInputs[2] = bytes32(uint256(uint160(_recipient)));
        if (verifier.verify(_proof, publicInputs)) {
            revert invalidProof();
        }
        nullifierHashs[_nullifierHash] = true;
        (bool success,) = _recipient.call{value: DENOMINATION}();
        if (!success) {
            revert paymentFailed(_recipient, DENOMINATION);
        }
        emit withdraw(_recipient, _nullifierHash);
    }
}
