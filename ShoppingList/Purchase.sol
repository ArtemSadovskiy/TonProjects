pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase {
    uint32 id;
    string name;
    uint32 quantity;
    uint64 timeOfAdd;
    bool isDone;
    uint32 price;
}

struct SummaryPurchases {
    uint32 quantityOfCompletedPurchases;
    uint32 quantityOfPendingPurchases;
    uint32 amountOfPaidPurchases;
}
