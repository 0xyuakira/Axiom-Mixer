use poseidon::poseidon2;
mod merkle_tree;
fn main(
    rootHash: pub Field,
    nullifier_hash: pub Field,
    recipient: pub Field,
    nullifier: pub Field,
    secret: Field,
    merkle_proof: [Field; 20],
    is_even: [bool; 20],
) {
    let commitment: Field = poseidon2::Poseidon2::hash([nullifier, secret], 2);
    let computed_nullifier_hash: Field = poseidon2::Poseidon2::hash([nullifier], 1);
    assert(nullifier_hash == computed_nullifier_hash);
    let computed_root_hash: Field =
        merkle_tree::computed_merkle_root(commitment, merkle_proof, is_even);
    assert(computed_root_hash == rootHash);
    let recipient_binding = recipient * recipient;
    assert(recipient_binding == recipient * recipient);
}
