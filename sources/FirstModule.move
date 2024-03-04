module Addr::WiktorCoin {
    use std::signer;

    const MODULE_OWNER: address = @Addr;

    const ENOT_MODULE_OWNER: u64 = 1;
    const EINSUFFICIENT_BALANCE: u64 = 2;

    struct Coin has store {
        value: u64,
    }

    /// Struct representing the balance of each address.
    struct Balance has key {
        coin: Coin // same Coin from Step 1
    }

    /// Publish an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public fun publish_balance(account: &signer) {
        let empty = Coin { value: 0 };
        move_to(account, Balance { coin: empty });
    }

    /// Mint `amount` tokens to `mint_addr`. Mint must be approved by the module owner.
    public fun mint(module_owner: &signer, mint_addr: address, amount: u64): () acquires Balance {
        assert!(signer::address_of(module_owner) == MODULE_OWNER, ENOT_MODULE_OWNER);
        deposit(mint_addr, Coin { value: amount });
    }

    /// Returns the balance of `owner`.
    public fun balance_of(owner: address): u64 acquires Balance {
        borrow_global<Balance>(owner).coin.value
    }

    /// Transfers `amount` of tokens from `from` to `to`.
    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        let coin = withdraw(signer::address_of(from), amount);
        deposit(to, coin);
    }

    fun withdraw(addr: address, amount: u64): Coin acquires Balance {
        let balance = balance_of(addr);
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin { value: amount }
    }

    fun deposit(addr: address, coin: Coin): () acquires Balance {
        let Coin { value: amount } = coin;
        let balance = balance_of(addr);
        //assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        *balance_ref = balance + amount;
    }
}
