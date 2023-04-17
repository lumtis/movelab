address 0x1 {
module BasicCoin {
    use std::signer;
    use std::error;

    const EALREADY_HAS_BALANCE: u64 = 1;
    const EEQUAL_ADDR: u64 = 2;
    const EINSUFFICIENT_BALANCE: u64 = 3;

    struct Coin has store {
        value: u64
    }

    struct Balance has key {
        coin: Coin
    }

    public fun publish_balance(account: &signer) {
        let empty_coin = Coin { value: 0 };
        assert!(!exists<Balance>(signer::address_of(account)), error::already_exists(EALREADY_HAS_BALANCE));
        move_to(account, Balance { coin: empty_coin });
    }

    public fun mint(mint_addr: address, amount: u64) acquires Balance {
        deposit(mint_addr, Coin { value: amount });
    }

    public fun balance_of(owner: address): u64 acquires Balance {
        borrow_global<Balance>(owner).coin.value
    }

    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        let from_addr = signer::address_of(from);
        assert!(from_addr != to, EEQUAL_ADDR);
        let check = withdraw(from_addr, amount);
        deposit(to, check);
    }

    fun withdraw(addr: address, amount: u64) : Coin acquires Balance {
        let balance = balance_of(addr);
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin { value: amount }
    }

    fun deposit(addr: address, check: Coin) acquires Balance{
        let balance = balance_of(addr);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }

    #[test(account = @0xa)]
    fun test_mint(account: signer) acquires Balance {
        publish_balance(&account);
        let addr = signer::address_of(&account);
        mint(addr, 10);
        assert!(borrow_global<Balance>(addr).coin.value == 10, 0);
        mint(addr, 15);
        assert!(borrow_global<Balance>(addr).coin.value == 25, 0);
    }

    #[test(account = @0xa)]
    fun test_balance_of(account: signer) acquires Balance {
        publish_balance(&account);
        let addr = signer::address_of(&account);
        mint(addr, 10);
        assert!(balance_of(addr) == 10, 0);
    }

    #[test(account = @0xa, other = @0xb)]
    fun test_transfer(account: signer, other: signer) acquires Balance {
        publish_balance(&account);
        publish_balance(&other);
        let addr = signer::address_of(&account);
        mint(addr, 10);
        let other_addr = signer::address_of(&other);
        transfer(&account, other_addr, 4);
        assert!(balance_of(addr) == 6, 0);
        assert!(balance_of(other_addr) == 4, 0);
    }
}
}