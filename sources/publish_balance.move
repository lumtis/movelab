script {
use 0x1::BasicCoin;
    fun main(account: signer) {
        BasicCoin::publish_balance(&account)
    }
}
