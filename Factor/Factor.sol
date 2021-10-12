pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Factor {

	uint public product = 1;

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	// Modifier that allows to accept some external messages
	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	// 
	function multiply(uint value) public checkOwnerAndAccept {
        require(value >= 1 && value <= 10 , 100, "the value is not in the range from 1 to 10");
		product = product * value;
	}
}