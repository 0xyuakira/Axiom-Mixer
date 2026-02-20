// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IncrementalMerkleTree} from "./IncrementalMerkleTree.sol";
import {IVerifier} from "./Verifier.sol";
import {ReentrancyGuardTransient} from "openzeppelin-contracts/contracts/utils/ReentrancyGuardTransient.sol";

contract Mixer is IncrementalMerkleTree, ReentrancyGuardTransient {
    uint256 public constant DENOMINATION = 0.001 ether;

    IVerifier public immutable VERIFIER;

    mapping(bytes32 => bool) public commitments;

    mapping(bytes32 => bool) public nullifierHashs;

    error CommitmentAlreadyUsed(bytes32 commitment);
    error DepositAmountNotCorrect(uint256 amountSent, uint256 expected);
    error UnknownRootHash(bytes32 unknownRootHash);
    error NullifierHashAlreadyUsed(bytes32 alreadyUsedNullifierHash);
    error InvalidProof();
    error PaymentFailed(address recipient, uint256 amount);
    event Deposit(bytes32 indexed insertedCommitment, uint32 insertedIndex, uint256 insertTimeStamp);
    event Withdraw(address indexed recipient, bytes32 nullifierHash);

    constructor(address _verifier, uint32 _merkleTreeDepth, address _hasher)
        IncrementalMerkleTree(_merkleTreeDepth, _hasher)
    {
        VERIFIER = IVerifier(_verifier);
    }

    /// @notice Deposit funds into the mixer
    function deposit(bytes32 _commitment) external payable {
        if (commitments[_commitment]) {
            revert CommitmentAlreadyUsed(_commitment);
        }
        if (msg.value != DENOMINATION) {
            revert DepositAmountNotCorrect(msg.value, DENOMINATION);
        }
        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;
        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    /// @notice Withdraw funds from mixer
    function withdraw(bytes memory _proof, bytes32 _rootHash, bytes32 _nullifierHash, address _recipient)
        external
        nonReentrant
    {
        if (!isKnownRoot(_rootHash)) {
            revert UnknownRootHash(_rootHash);
        }
        if (nullifierHashs[_nullifierHash]) {
            revert NullifierHashAlreadyUsed(_nullifierHash);
        }
        bytes32[] memory publicInputs = new bytes32[](3);
        publicInputs[0] = _rootHash;
        publicInputs[1] = _nullifierHash;
        publicInputs[2] = bytes32(uint256(uint160(_recipient)));
        if (!VERIFIER.verify(_proof, publicInputs)) {
            revert InvalidProof();
        }
        nullifierHashs[_nullifierHash] = true;
        (bool success,) = _recipient.call{value: DENOMINATION}("");
        if (!success) {
            revert PaymentFailed(_recipient, DENOMINATION);
        }
        emit Withdraw(_recipient, _nullifierHash);
    }
}
