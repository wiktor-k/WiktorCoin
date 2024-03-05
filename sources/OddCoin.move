module Wiktor::OddCoin {
    use std::signer;
    use Wiktor::Coin;

    struct OddCoin has drop {}

    const MODULE_OWNER: address = @Wiktor;

    const ENOT_ODD: u64 = 1;

    public fun setup_and_mint(module_owner: &signer, account: &signer, amount: u64) {
        Coin::publish_balance<OddCoin>(account);
        Coin::mint<OddCoin>(module_owner, signer::address_of(account), amount);
    }

    public fun transfer(from: &signer, to: address, amount: u64) {
        assert!(amount % 2 == 1, ENOT_ODD);
        Coin::transfer<OddCoin>(from, to, amount);
    }

    #[test(owner = @Wiktor, from = @0x42, to = @0x17)]
    fun transfer_success(owner: signer, from: signer, to: signer) {
        setup_and_mint(&owner, &from, 42);
        setup_and_mint(&owner, &to, 17);

        transfer(&from, signer::address_of(&to), 13);

        assert!(Coin::balance_of<OddCoin>(signer::address_of(&from)) == 29, 0);
        assert!(Coin::balance_of<OddCoin>(signer::address_of(&to)) == 30, 0);
    }

    #[test(owner = @Wiktor, from = @0x42, to = @0x17)]
    #[expected_failure(abort_code = ENOT_ODD)]
    fun transfer_not_odd_failure(owner: signer, from: signer, to: signer) {
        setup_and_mint(&owner, &from, 42);
        setup_and_mint(&owner, &to, 17);

        transfer(&from, signer::address_of(&to), 12);
    }
}
