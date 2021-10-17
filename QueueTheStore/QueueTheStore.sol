

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract QueueTheStore {
    
    string[] public queue;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

    function addBuyer(string calldata s) public checkOwnerAndAccept{
    queue.push(s);
    }

    function deleteBuyer() public checkOwnerAndAccept returns(string[] memory){
    
    for (uint i = 0; i<queue.length-1; i++){
            queue[i] = queue[i+1];
        }
    queue.pop();
    return queue;
    }
}
