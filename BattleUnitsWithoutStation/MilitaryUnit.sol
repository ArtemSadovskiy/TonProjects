
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "InterfaceGameObject.sol";

contract MilitaryUnit is InterfaceGameObject {

    uint public quantityLife;
    uint public powerProtection;
    uint public attackPower;
    address public attackAddress;

    
   function attack(InterfaceGameObject add) public checkOwnerAndAccept {
       add.acceptAttack(attackPower);
   }

   function getAttackPower(uint attackPow) virtual public checkOwnerAndAccept{
       attackPower = attackPow;
   }

   function getPowerProtection(uint powerProt) virtual public checkOwnerAndAccept{
        powerProtection = powerProt;
    }

    function getCurrentHealth(uint health) public checkOwnerAndAccept{
        quantityLife = health;
    }

   function acceptAttack(uint attackPow) virtual external override{
        tvm.accept();
        quantityLife = quantityLife - (attackPow - powerProtection);
        attackAddress = msg.sender;
        checkIfObjectKilled();
    }

    function checkIfObjectKilled() private{
        if(quantityLife <= 0){
            destruction();
        }
    }

    function destruction() private {
        sendingAllMoneyAddressAndDestroy(attackAddress);
    }

    function sendingAllMoneyAddressAndDestroy(address add) internal{
        add.transfer(1, true, 160);
    }

    function getHelth() public checkOwnerAndAccept returns(uint){
        return quantityLife;
    }

    modifier checkOwnerAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}
}
