// SDPX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Mixer {
    mapping(bytes32 => bool) private commitments;

    /// @notice Deposit funds into the mixer
    function deposit(bytes32 _commitment) external payable {
        require(commitments[_commitment],);


    }

    /// @notice Withdraw funds from mixer
    function withdraw(bytes32 _commitment) external {}
}
