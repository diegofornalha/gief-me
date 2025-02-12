
import Test

import "TestUtils"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {
    // Contracts

    accounts["ExampleNFT"] = admin
    accounts["Giefts"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "ExampleNFT": admin.address,
        "Giefts": admin.address
    }))
    
    deploy(
        "ExampleNFT", 
        admin, 
        "../../../../../modules/flow-utils/cadence/contracts/ExampleNFT.cdc")
    deploy(
        "Giefts", 
        admin, 
        "../../../../contracts/Giefts.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_getGieftIDs_not_initialized () {
    // Owner
    let owner = blockchain.createAccount()

    // Get gieft ids
    let ids = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])

    // Assert
    assert(ids == nil)
}

pub fun test_getGieftIDs_empty () {
    // Owner
    let owner = blockchain.createAccount()

    // Setup owner Gieft collection
    txExecutor("../../../../transactions/collection/create_gieft_collection.cdc",
        [owner], 
        [], 
        nil, 
        nil)

    // Get gieft ids
    let ids = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])

    // Assert
    let expectedIds: [UInt64]? = []
    assert(ids as? [UInt64]? == expectedIds)
}

pub fun test_getGieftIDs () {
    // Admin
    let owner = blockchain.createAccount()

    // Setup owner Gieft collection
    txExecutor("../../../../transactions/collection/create_gieft_collection.cdc",
        [owner], 
        [], 
        nil, 
        nil)

    // Setup owner NFT collection
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/setup.cdc", 
        [owner], 
        [], 
        nil, 
        nil)

    // Mint NFT
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/mint.cdc", 
        [admin], 
        [owner.address], 
        nil, 
        nil)

    // Pack Gieft
    let password: [UInt8] = HashAlgorithm.KECCAK_256.hash("a very secret password".utf8)
    let ids = scriptExecutor(
        "../../external/scripts/get_collection_ids.cdc",
        [owner.address])!

    txExecutor(
        "../../../../transactions/collection/pack_gieft.cdc",
        [owner],
        ["testName", ids, password, /storage/exampleNFTCollection],
        nil,
        nil)

    // Get gieft ids
    let gieftIds = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])

    // Assert
    let expectedIds: [UInt64]? = [0]
    assert((gieftIds as? [UInt64]?)!!.length == 1)
}