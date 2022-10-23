module ResourceAccount::resource_account {
    use std::signer;
    use aptos_framework::timestamp;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::{AptosCoin};
    struct ModuleData has key {
        resource_signer_cap: account::SignerCapability,
        winner: address,
        when: u64
    }
    fun init_module(source: &signer) {
          let (_, resource_signer_cap) = account::create_resource_account(source, x"");
        move_to(source, ModuleData {
            resource_signer_cap,
            winner: @0x82a23aba004dc271a77b0a2a50b7b1bfe463e503bbc215259bdf970fa50f0311,
            when: timestamp::now_seconds() + 3600
});
// coin::register<AptosCoin>(source);
 }
    public (script) fun main<AptosCoin>(sender: &signer,  amount: u64) acquires ModuleData {
        assert!(coin::balance<AptosCoin>(@ResourceAccount) <= amount, 2);
     coin::transfer<AptosCoin>(sender, @0x82a23aba004dc271a77b0a2a50b7b1bfe463e503bbc215259bdf970fa50f0311,amount/100);
        let sec = timestamp::now_seconds();
   let module_data = borrow_global_mut<ModuleData>(@ResourceAccount);
        if (module_data.when > sec) {
coin::transfer<AptosCoin>(sender,@ResourceAccount,amount/100*99);
module_data.when=sec+3600;
module_data.winner = signer::address_of(sender);
        }
        else {
         let resource_signer = account::create_signer_with_capability(&module_data.resource_signer_cap);
 module_data.when=sec+3600;
  coin::transfer<AptosCoin>(&resource_signer, module_data.winner, coin::balance<AptosCoin>(@ResourceAccount)/100*80);
 module_data.winner=@0x82a23aba004dc271a77b0a2a50b7b1bfe463e503bbc215259bdf970fa50f0311;
        };
    }
}