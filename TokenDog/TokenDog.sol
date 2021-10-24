pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TokenDog {

struct Dog {
    string name;   
    uint barkingPower;
    string color;
    uint weight; 
    uint cost;
}

Dog[] dogList;
mapping (uint=>uint) tokenToOwner;

function createToken(string name, uint barkingPower, string color, uint weight) public{
    tvm.accept();
    for (uint i = 0; i < dogList.length; i++){
        require(!(sha256(name)==sha256(dogList[i].name)));
    }
    dogList.push(Dog(name, barkingPower, color, weight, 0));
    uint keyAsLastNum = dogList.length - 1;
    tokenToOwner[keyAsLastNum] = msg.pubkey();
}

function getTokenOwner(uint tokenId) public view returns (uint){
    return tokenToOwner[tokenId];
}

function getTokenInfo(uint tokenId) public view returns (string nameDog, uint barkingPower, string color, uint weight, uint cost){
    nameDog = dogList[tokenId].name;
    barkingPower = dogList[tokenId].barkingPower;
    color = dogList[tokenId].color;
    weight = dogList[tokenId].weight;
    cost = dogList[tokenId].cost;
}


function putTokenSale(uint tokenId, uint cost) public {
require(msg.pubkey() == tokenToOwner[tokenId], 101);
tvm.accept();
dogList[tokenId].cost = cost;
}
    
constructor() public {
        
    require(tvm.pubkey() != 0, 101);
 
    require(msg.pubkey() == tvm.pubkey(), 102);
     
    tvm.accept();
}

}
