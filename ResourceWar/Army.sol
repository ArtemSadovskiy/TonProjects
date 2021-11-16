pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Army {

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    
    uint[] public loot;

    function looting(uint[] warehouse, uint capacityArmy) public returns (uint[] loot_){
        tvm.accept();
        uint warehouseVolume = sumArray(warehouse);

        for (uint i = 0; i < warehouse.length; i++){
            if(capacityArmy >= warehouseVolume){
                loot.push(warehouse[i]);
            }
            else{
                loot.push(capacityArmy*warehouse[i]/warehouseVolume);
            }
            
        }

        uint[] lostLoot;
        uint[] lostLootSort;
        uint count;
        mapping (uint=>uint) numberLostLoot;
        
        if((capacityArmy - sumArray(loot)) == 0){
            return loot;
        }
        else {
            for (uint i = 0; i < warehouse.length; i++){
                lostLoot.push(((capacityArmy * warehouse[i] * 10)/warehouseVolume) - (capacityArmy*warehouse[i]/warehouseVolume) * 10);
                lostLootSort.push(((capacityArmy * warehouse[i] * 10)/warehouseVolume) - (capacityArmy*warehouse[i]/warehouseVolume) * 10);
            }

            for (uint i = 0; i < lostLootSort.length-1; i++){
                for(uint j = i + 1; j < lostLootSort.length; j++){
                    uint temp = lostLootSort[i];
                    if (temp < lostLootSort[j]){
                        uint x = lostLootSort[j];
                        lostLootSort[i] = x;
                        lostLootSort[j] = temp;
                    }
                }
            }

            for (uint i = 0; i < (capacityArmy - sumArray(loot)); i++){
                for(uint j = 0; j < lostLoot.length; j++){
                    if (lostLootSort[i] == lostLoot[j]){
                        numberLostLoot[i] = j;
                    }
                }
            }

            for ((uint id, uint number) : numberLostLoot){
                loot[number] = loot[number] + 1;
            }
            return loot;
            
        }
    }

    function sumArray(uint[] list) public returns(uint sum){
        uint sum_;
        for (uint i = 0; i < list.length; i++){
            sum_ = sum_ + list[i];
        }

        return sum_;
    }
}