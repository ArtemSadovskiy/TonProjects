pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "Purchase.sol";

interface IMsig {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

interface IShopping {
   function getShoppingList() external returns (Purchase[] purchases);
   function addPurchase(string name, uint32 quantity) external;
   function deletePurchase(uint32 id) external;
   function markAsPurchased(uint32 id, uint32 price) external;
   function getSummary() external returns (SummaryPurchases);
}