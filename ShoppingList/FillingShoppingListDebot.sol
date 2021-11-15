pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

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
        support = address.makeAddrStd(0, 0x0cb9e72391abb5dc3c826cdca8df6571cc66e28cddf683592e2731c341b9cde3);
        hello = "Hi, i'm a Filling Shopping List DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
    }

    function _menu() override public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (to purchase/done purchase/total price) purchases",
                    m_summary.quantityOfPendingPurchases,
                    m_summary.quantityOfCompletedPurchases,
                    m_summary.amountOfPaidPurchases
            ),
            sep,
            [
                MenuItem("Add new purchase","",tvm.functionId(addingProduct)),
                MenuItem("Show purchases list","",tvm.functionId(displayingShoppinglist)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }

    function addingProduct(uint32 index) public {
        addPurchases(index);
    }

    function displayingShoppinglist(uint32 index) public {
        showPurchases(index);
    }

    function deletingPurchase(uint32 index) public {
        deletePurchase(index);
    }
}