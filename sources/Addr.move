module Addr::WiktorCoin {
    use std::signer;

    const MODULE_OWNER: address = @Addr;

    const ENOT_MODULE_OWNER: u64 = 1;
    const EINSUFFICIENT_BALANCE: u64 = 2;
    const EALREADY_HAS_BALANCE: u64 = 3;

    struct Coin<phantom CoinType> has store {
        value: u64,
    }

    /// Struct representing the balance of each address.
    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    /// Publish an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public fun publish_balance<CoinType>(account: &signer) {
        let empty = Coin<CoinType> { value: 0 };
        assert!(!exists<Balance<CoinType>>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        move_to(account, Balance<CoinType> { coin: empty });
    }

    /// Mint `amount` tokens to `mint_addr`. Mint must be approved by the module owner.
    public fun mint<CoinType>(module_owner: &signer, mint_addr: address, amount: u64): () acquires Balance {
        assert!(signer::address_of(module_owner) == MODULE_OWNER, ENOT_MODULE_OWNER);
        deposit(mint_addr, Coin<CoinType> { value: amount });
    }

    /// Returns the balance of `owner`.
    public fun balance_of<CoinType>(owner: address): u64 acquires Balance {
        borrow_global<Balance<CoinType>>(owner).coin.value
    }

    /// Transfers `amount` of tokens from `from` to `to`.
    public fun transfer<CoinType>(from: &signer, to: address, amount: u64) acquires Balance {
        let coin = withdraw<CoinType>(signer::address_of(from), amount);
        deposit(to, coin);
    }

    fun withdraw<CoinType>(addr: address, amount: u64): Coin<CoinType> acquires Balance {
        let balance = balance_of<CoinType>(addr);
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin<CoinType> { value: amount }
    }

    fun deposit<CoinType>(addr: address, coin: Coin<CoinType>): () acquires Balance {
        let Coin<CoinType> { value: amount } = coin;
        let balance = balance_of<CoinType>(addr);
        //assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance + amount;
    }

    #[test_only]
    struct TestCoin {}

    #[test(account = @0x1)]
    #[expected_failure(abort_code = ENOT_MODULE_OWNER)]
    fun mint_no_owner(account: signer) acquires Balance {
        publish_balance<TestCoin>(&account);
        assert!(signer::address_of(&account) != MODULE_OWNER, 0);
        mint<TestCoin>(&account, @0x1, 10);
    }

    #[test(account = @0x1)]
    fun public_balance_has_zero(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<TestCoin>(&account);
        assert!(balance_of<TestCoin>(addr) == 0, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure(abort_code = EALREADY_HAS_BALANCE)]
    fun publish_balance_already_exists(account: signer) {
        publish_balance<TestCoin>(&account);
        publish_balance<TestCoin>(&account);
    }

    #[test(account = @0x1)]
    fun balance_of_empty(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<TestCoin>(&account);
        let balance = balance_of<TestCoin>(addr);
        assert!(balance == 0, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure]
    fun balance_of_dne(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        balance_of<TestCoin>(addr);
    }

    #[test(account = @0x1)]
    #[expected_failure] // how to check for MISSING_DATA here? (abort_code = 4008)
    fun withdraw_dne(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        Coin { value: _ } = withdraw<TestCoin>(addr, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure(abort_code = EINSUFFICIENT_BALANCE)]
    fun withdraw_too_much(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<TestCoin>(&account);
        Coin { value: _ } = withdraw<TestCoin>(addr, 1);
    }

    #[test(account = @Addr)]
    fun can_withdraw_amount(account: signer) acquires Balance {
        publish_balance<TestCoin>(&account);
        let amount = 1000;
        let addr = signer::address_of(&account);
        mint<TestCoin>(&account, addr, amount);
        let Coin { value } = withdraw<TestCoin>(addr, amount);
        assert!(value == amount, 0);
    }
}
