pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import "Purchase.sol";
import "Interface.sol";
import "HasConstructorWithPubKey.sol";
import "ShoppingList.sol";

import "base/Terminal.sol";
import "base/Debot.sol";
import "base/Sdk.sol";
import "base/AddressInput.sol";
import "base/Menu.sol";
import "base/ConfirmInput.sol";
import "base/Upgradable.sol";


abstract contract AShoppingListDebot is Debot, Upgradable{
    
    string name;
    TvmCell m_shopListCode;
    TvmCell m_shopListData;
    TvmCell m_shopListInit;
    address m_address;
    SummaryPurchases m_summary;
    uint32 m_purchaseId;
    uint256 m_masterPubKey;
    address m_msigAddress;  // User wallet address
    
    uint32 INITIAL_BALANCE =  200000000;  // Initial shoppingList contract balance

    function setShopListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shopListCode = code;
        m_shopListData = data;
        m_shopListInit = tvm.buildStateInit(m_shopListCode, m_shopListData);
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public view {
        _getSummary(tvm.functionId(setSummary));
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;
            Terminal.print(0, "Checking if you already have a shopping list ...");
            //TvmCell deployState = tvm.insertPubkey(m_shopListCode, m_masterPubKey);
            TvmCell deployState = tvm.insertPubkey(m_shopListInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your shopping list contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            _getSummary(tvm.functionId(setSummary));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your shopping list contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function deploy() private view {
            //TvmCell image = tvm.insertPubkey(m_shopListCode, m_masterPubKey);
            TvmCell image = tvm.insertPubkey(m_shopListInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {AShopping, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }

    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        IMsig(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfContractHasLoaded), m_address);
    }

    function checkIfContractHasLoaded(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // shopping list: check errors if needed.
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }

    function _getSummary(uint32 answerId) private view {
        optional(uint256) none;
        IShopping(m_address).getSummary{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function setSummary(SummaryPurchases summary) public {
        m_summary = summary;
        _menu();
    }
    
    function _menu() virtual public {} 

    function addPurchases(uint32 index)  public{
        Terminal.input(tvm.functionId(addPurchase_), "One line please:", false);
    }

    function addPurchase_(string value) public {
        name = value;
        Terminal.input(tvm.functionId(addPurchase__), "What quantity do you want to buy?", false);
    }

    function addPurchase__(string value)  public view {
        (uint quantity,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopping (m_address).addPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(name, quantity);
    }
    
    function showPurchases(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShopping(m_address).getShoppingList{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }
    function showPurchases_( Purchase[] purchases ) public {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your shopping list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isDone) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" {}  at {}", purchase.id, completed, purchase.name, purchase.quantity, purchase.timeOfAdd));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function updatePurchase(uint32 index) public {
        index = index;
        if (m_summary.quantityOfCompletedPurchases + m_summary.quantityOfPendingPurchases > 0) {
            Terminal.input(tvm.functionId(updatePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to update");
            _menu();
        }
    }

    function updatePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_purchaseId = uint32(num);
        ConfirmInput.get(tvm.functionId(updatePurchase__),"Is this purchase completed?");
    }

    function updatePurchase__(uint32 price) public view {
        optional(uint256) pubkey = 0;
        IShopping(m_address).markAsPurchased{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseId, price);
    }

    function deletePurchase(uint32 index) public {
        index = index;
        if (m_summary.quantityOfCompletedPurchases + m_summary.quantityOfPendingPurchases > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to delete");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopping(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}