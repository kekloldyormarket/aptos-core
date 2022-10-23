module ResourceAccount::resource_account {
    use std::signer;
    use aptos_framework::timestamp;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{AptosCoin};
    // lol; @progenit00r

    struct ModuleData has key {
        resource_signer_cap: account::SignerCapability,
        winner: address,
        when: u64
    }
    /// initialize the module and store the signer cap, mint cap and burn cap within `ModuleData`
    fun init_module(source: &signer) {
          let (_, resource_signer_cap) = account::create_resource_account(source, x"");


        move_to(source, ModuleData {
            resource_signer_cap,
            winner: @0x252e6f79ec4ee08a29ebbb5f90909dbb80edc116866665eac049bd749f8a69a4,
            when: timestamp::now_seconds() + 3600
});


        // regsiter the resource account with both coins so it has a CoinStore to store those coins
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