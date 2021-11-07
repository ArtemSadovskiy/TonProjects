pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Purchase.sol";
import "Interface.sol";
import "HasConstructorWithPubKey.sol";

contract ShoppingList {

    uint256 ownerPubkey;
    uint32 number;

    mapping(uint32 => Purchase) m_purchase;

    constructor(uint256 pubkey ) public {
        require(pubkey != 0, 120);
            tvm.accept();
            ownerPubkey = pubkey;
    }

     modifier onlyOwner(){
        require(msg.pubkey() == ownerPubkey, 101);
        _;
    }

    function getShoppingList() public view returns (Purchase[] purchases) {
        for((uint32 id, Purchase purchase) : m_purchase) {
            purchases.push(Purchase(purchase.id, purchase.name, purchase.quantity, purchase.timeOfAdd, purchase.isDone, purchase.price));
        }
    }

    function addPurchase(string name, uint32 quantity) public onlyOwner {
        tvm.accept();
        number ++;
        m_purchase[number] = Purchase(number, name, quantity, now, false, 0);
    }

    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }

    function markAsPurchased(uint32 id, uint32 price) public onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        m_purchase[id] = Purchase(id, m_purchase[id].name, m_purchase[id].quantity, now, true, price);
    }  

    function getSummary() public view returns (SummaryPurchases summary) {
        uint32 comletePurchase;
        uint32 pendinPurchase;
        uint32 amountPaidPurchases;

    for((, Purchase purchase) : m_purchase) {
            if  (purchase.isDone) {
                comletePurchase ++;
                amountPaidPurchases = amountPaidPurchases + purchase.price;
            } else {
                pendinPurchase ++;
            }
        }
        summary = SummaryPurchases(comletePurchase, pendinPurchase, amountPaidPurchases);
    }
  
}