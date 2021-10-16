

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract QueueTheStore {
    
    uint32 public timestamp;

    string[] public queue;

    function addBuyer(string calldata s) public{
    queue.push(s);
    }

    function deleteBuyer() public returns(string[] memory){
    
    for (uint i = 0; i<queue.length-1; i++){
            queue[i] = queue[i+1];
        }
    queue.pop();
    return queue;
    }
   
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        timestamp = now;
    }

    function touch() external {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        timestamp = now;
    }

    function sendValue(address dest, uint128 amount, bool bounce) public view {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        dest.transfer(amount, bounce, 0);
    }
}
