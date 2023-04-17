script {
    use std::signer;
    use 0x1::BasicCoin;

    fun main(account: signer, amount: u64) {
        let addr = signer::address_of(&account);
        BasicCoin::mint(addr, amount)
    }
}
