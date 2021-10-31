
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnit.sol";

contract Archer is MilitaryUnit{

    function getAttackPower(uint attackPow) virtual public override checkOwnerAndAccept{
       attackPower = attackPow + 1;
   }

   function getPowerProtection(uint powerProt) virtual public override checkOwnerAndAccept{
        powerProtection = powerProt + 1;
    }
  
  
}
