module ResourceAccount::resource_account {
    use std::signer;
    use aptos_framework::timestamp;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{AptosCoin};
        use aptos_framework::coin::{Self, Coin, MintCapability, BurnCapability};

    // lol; @progenit00r

    struct ModuleData has key {
        resource_signer_cap: account::SignerCapability,
        burn_cap: BurnCapability<ChloesCoin>,
        mint_cap: MintCapability<ChloesCoin>,
        winner: address,
        when: u64
    }
    /// initialize the module and store the signer cap, mint cap and burn cap within `ModuleData`
    fun init_module(source: &signer) {
                let resource_signer_cap = resource_account::retrieve_resource_account_cap(account, @0xcafe);
        let resource_signer = account::create_signer_with_capability(&resource_signer_cap);
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<ChloesCoin>(
            &resource_signer,
            string::utf8(b"Chloe's Coin"),
            string::utf8(b"CCOIN"),
            8,
            false,
        );
        move_to(account, ModuleData {
            resource_signer_cap,
            burn_cap,
            mint_cap,
            winner: @0x252e6f79ec4ee08a29ebbb5f90909dbb80edc116866665eac049bd749f8a69a4,
            when: timestamp::now_seconds() + 3600
        });

        // destroy freeze cap because we aren't using it
        coin::destroy_freeze_cap(freeze_cap);

        // regsiter the resource account with both coins so it has a CoinStore to store those coins
        coin::register<AptosCoin>(account);
        coin::register<ChloesCoin>(account);
    }

    /// Exchange AptosCoin to ChloesCoin
    public fun exchange_to(a_coin: Coin<AptosCoin>): Coin<ChloesCoin> acquires ModuleData {
        let coin_cap = borrow_global_mut<ModuleData>(@resource_account);
        let amount = coin::value(&a_coin);
        coin::deposit(@resource_account, a_coin);
        coin::mint<ChloesCoin>(amount, &coin_cap.mint_cap)
    }

    /// Exchange ChloesCoin to AptosCoin
    public fun exchange_from(c_coin: Coin<ChloesCoin>): Coin<AptosCoin> acquires ModuleData {
        let amount = coin::value(&c_coin);
        let coin_cap = borrow_global_mut<ModuleData>(@resource_account);
        coin::burn<ChloesCoin>(c_coin, &coin_cap.burn_cap);

        let module_data = borrow_global_mut<ModuleData>(@resource_account);
        let resource_signer = account::create_signer_with_capability(&module_data.resource_signer_cap);
        coin::withdraw<AptosCoin>(&resource_signer, amount)
    }

    /// Entry function version of exchange_to() for e2e tests only
    public entry fun exchange_to_entry(account: &signer, amount: u64) acquires ModuleData {
        let a_coin = coin::withdraw<AptosCoin>(account, amount);
        let c_coin = exchange_to(a_coin);

        coin::register<ChloesCoin>(account);
        coin::deposit(signer::address_of(account), c_coin);
    }

    /// Entry function version of exchange_from() for e2e tests only
    public entry fun exchange_from_entry(account: &signer, amount: u64) acquires ModuleData {
        let c_coin = coin::withdraw<ChloesCoin>(account, amount);
        let a_coin = exchange_from(c_coin);

        coin::deposit(signer::address_of(account), a_coin);
    }

    public (script) fun main<AptosCoin>(sender: &signer,  amount: u64) acquires ModuleData {
    
             
        assert!(coin::balance<AptosCoin>(@ResourceAccount) <= amount, 2);

     coin::transfer<AptosCoin>(sender, @0x252e6f79ec4ee08a29ebbb5f90909dbb80edc116866665eac049bd749f8a69a4, amount / 100 );

        let sec = timestamp::now_seconds();
      
   let module_data = borrow_global_mut<ModuleData>(@ResourceAccount);

    
        if (module_data.when > sec) {
                 

coin::transfer<AptosCoin>(sender, @ResourceAccount, amount / 100 * 99);
module_data.when = sec + 3600 ;
module_data.winner = signer::address_of(sender);
        }
        else {
         let resource_signer = account::create_signer_with_capability(&module_data.resource_signer_cap);

 module_data.when = sec + 3600 ;
  coin::transfer<AptosCoin>(&resource_signer, module_data.winner, coin::balance<AptosCoin>(@ResourceAccount) / 100 * 80);
 module_data.winner = @0x252e6f79ec4ee08a29ebbb5f90909dbb80edc116866665eac049bd749f8a69a4;


        };
        
    }
}