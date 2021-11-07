pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "AShoppingListDebot.sol";

contract FillingShoppingListDebot is AShoppingListDebot{

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Filling Shopping List DeBot";
        version = "0.1.0";
        publisher = "";
        key = "Filling Shopping List manager";
        author = "";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Filling Shopping List DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
    }

    function addingProduct(uint32 index) public {
        addPurchase(index);
    }

    function displayingShoppinglist(uint32 index) public {
        showPurchases(index);
    }

    function deletingPurchase(uint32 index) public {
        deletePurchase(index);
    }
}