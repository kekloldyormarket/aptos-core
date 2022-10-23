// Copyright (c) Aptos
// SPDX-License-Identifier: Apache-2.0

use aptos_types::account_address::{create_resource_address, AccountAddress};
use aptos_types::on_chain_config::FeatureFlag;
use framework::natives::code::{PackageRegistry, UpgradePolicy};
use move_deps::move_core_types::parser::parse_struct_tag;
use move_deps::move_core_types::vm_status::StatusCode;
use package_builder::PackageBuilder;
use rstest::rstest;
use serde::{Deserialize, Serialize};
use e2e_move_tests::harness::MoveHarness;

// Note: this module uses parameterized tests via the
// [`rstest` crate](https://crates.io/crates/rstest)
// to test for multiple feature combinations.

/// Mimics `0xe37ac64cfbb930c24c821a36d35405832c2f881519d133f5243b315b5aef9345::test::State`
#[derive(Serialize, Deserialize)]
struct State {
    value: u64,
}

fn main() {
    let mut h = MoveHarness::new();
    let acc = h.new_account_at(AccountAddress::from_hex_literal("0xe37ac64cfbb930c24c821a36d35405832c2f881519d133f5243b315b5aef9345").unwrap());

    let mut pack = PackageBuilder::new("Package1").with_policy(UpgradePolicy::compat());
    let module_address = create_resource_address(*acc.address(), &[]);
    pack.add_source(
        "m",
        &format!("module 0x{}::m {{ public fun f() {{}} }}", module_address),
    );
    let pack_dir = pack.write_to_temp().unwrap();
    let package = framework::BuiltPackage::build(
        pack_dir.path().to_owned(),
        framework::BuildOptions::default(),
    )
    .expect("building package must succeed");

    let code = package.extract_code();
    let metadata = package
        .extract_metadata()
        .expect("extracting package metadata must succeed");
    let bcs_metadata = bcs::to_bytes(&metadata).expect("PackageMetadata has BCS");

    let result = h.run_transaction_payload(
        &acc,
        cached_packages::aptos_stdlib::resource_account_create_resource_account_and_publish_package(
            vec![],

            bcs_metadata,
            code,
        ),
    );
}
