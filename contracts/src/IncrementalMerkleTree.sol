// SDPX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Poseidon2, Field} from "@poseidon/src/bn254/solidity/Poseidon2.sol";

contract IncrementalMerkleTree {
    uint32 public immutable depth;
    bytes32 public rootHash;
    uint32 public nextLeafIndex;
    mapping(uint32 => bytes32) public cachedSubTree;
    Poseidon2 public immutable hasher;

    error DepthShouldBeGreaterThanZero();
    error DepthShouldBeLessThan32();
    error IndexOutOfBounds(uint32 i);
    error MerkleTreeFull(uint32 nextLeafIndex);

    constructor(uint32 _depth, address _hasher) {
        if (_depth == 0) {
            revert DepthShouldBeGreaterThanZero();
        }

        if (_depth >= 32) {
            revert DepthShouldBeLessThan32();
        }

        depth = _depth;

        rootHash = zeros(_depth - 1);

        hasher = Poseidon2(_hasher);
    }

    function _insert(bytes32 _leaf) internal returns (uint32) {
        uint32 _nextLeafIndex = nextLeafIndex;

        if (_nextLeafIndex == uint32(2) ** depth) {
            revert MerkleTreeFull(_nextLeafIndex);
        }

        uint32 currentIndex = nextLeafIndex;
        bytes32 currentHash = _leaf;
        bytes32 left;
        bytes32 right;
        for (uint32 i = 0; i < depth; i++) {
            if (currentIndex % 2 == 0) {
                left = currentHash;
                right = zeros(i);
                cachedSubTree[i] = currentHash;
            } else {
                left = cachedSubTree[i];
                right = currentHash;
            }
            currentHash = Field.toBytes32(hasher.hash_2(Field.toField(left), Field.toField(right)));
            currentIndex = currentIndex / 2;
        }
        rootHash = currentHash;
        nextLeafIndex += 1;
        return _nextLeafIndex;
    }

    function zeros(uint32 i) public pure returns (bytes32) {
        if (i == 0) return 0x0e43bc9a182ae87faf07c94cc4994ab763200a3fbca2f273564576a9fb99d2e5; // seed
        else if (i == 1) return 0x1640cbfc19ce0ed336544904db95445d732d9a613d5edcb90b6c2e57ec626d09;
        else if (i == 2) return 0x28d6d320efadaa1f4c2686a50063211ec3a2baffe102e4ce72dc8912a2ea9ac3;
        else if (i == 3) return 0x264f522705fe03d86a0b04c6401b5765917ddd796aa2d81c01573e0c850596a8;
        else if (i == 4) return 0x0bf6d1403d58ed0f41aaf45bd2807af92efb9cc1417ceb21a4b12cb0ff137c4b;
        else if (i == 5) return 0x1e0cd44abcd3770e2406df859a997ca65643140c8a9ef5c365e057e49c64609e;
        else if (i == 6) return 0x113c648291361688cbdc2d7bdd51db30293e87c18539f476b577d26d44b0ce08;
        else if (i == 7) return 0x18ba14d9ecfa0d4f9aa7f44fe5f83eed3e09d2071a8e3f0640b9b8a78add9fd4;
        else if (i == 8) return 0x1d3f36aeceedc279649df3ec9040da4218078795b0dc1ea4004a72e97b1b8794;
        else if (i == 9) return 0x24d44a7515c14204292de11dbfb339f90e6abeba16cff4abf804045f955c62f1;
        else if (i == 10) return 0x0c452ff87a6cf9a51697498981a1f472a2b853b6ad91f53c65e4398f29aeb87a;
        else if (i == 11) return 0x01c6625007e317160c651fb736ee050cc4460a88bd74f67900300ae81a8b4f1f;
        else if (i == 12) return 0x0e9e7697da28a823f586d6b5a3f385cd93a0d3c7e84d73ce89109ffbfab67de2;
        else if (i == 13) return 0x0a1659aef9c191bc4c8f23b552962dfcf8d8775b15a3cdcaeea3e67dbc459be4;
        else if (i == 14) return 0x2f0fe665eb77567f57aa350437400c604bbc97947f65ceec35398833ac252355;
        else if (i == 15) return 0x0eac02dbf9e99d100bda21851667ca15d791e8fb5921e794d5d9e28370984873;
        else if (i == 16) return 0x1763f0a81ef8933537041a608c0b08165f57bcabfadde838971ac778640c9965;
        else if (i == 17) return 0x0cf1ecaf681a1eea747e8f851a6199bba9ba538f25167871a3f458eb17e52328;
        else if (i == 18) return 0x25807b77387aaefacaa7cb2a4c5a28dd463d3505242bb50644e6102d10ab5d31;
        else if (i == 19) return 0x15572b60168c9b82437c3f6ff4f2baec4cd2b4e58fd44219daa31790c010f36a;
        else if (i == 20) return 0x1e043fd18085f8e0b006898a8a524df7af7fed0183e1acce2d4cf6b028c6a297;
        else if (i == 21) return 0x12fe9e5a088b9cca7842e831111ab8b94dc769fd9354af76b75191185f735d83;
        else if (i == 22) return 0x1041a90d5dbb68672e8865ac90ba6de631d9c70f0c5881ce6c8c97255ce43327;
        else if (i == 23) return 0x100fdbfedbe51e1bbe918bb8f2f32a2a3904e1706d39d183defd892e599eb205;
        else if (i == 24) return 0x243f952a3a6d54c28c74590be94d7f91761a4d72e39238a7c84afbb0ec67f863;
        else if (i == 25) return 0x089cdb0d5b428ebbf7f46debe7b5af176270e2681de58e526689cef9e329be68;
        else if (i == 26) return 0x2777bb5926abdeb8ccb4c6282158218cf02cb6deac6f6fc2efbf0b4b5bb51cdd;
        else if (i == 27) return 0x13963549ad0d4d525dd9c2070fae2156fe6c71fd780622adfc54efc0f9a3be7b;
        else if (i == 28) return 0x25bc667447c4e97b545b111e50d8049cff3e66082cb27184c17e551357819761;
        else if (i == 29) return 0x2a7fc6a0edc0441e547bd47436a97a4b26b27a611035f6870f455de3640677f8;
        else if (i == 30) return 0x28124bbc984f4c33c62b151338f5511cd7f879d29d4ff774e21b76566d5a3308;
        else if (i == 31) return 0x27b8895e1b7ea0f575aaf38c2f88b1a326fe13fd4aa7415a76e1278ace1f4dc0;
        else revert IndexOutOfBounds(i);
    }
}
