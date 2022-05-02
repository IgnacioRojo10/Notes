// SOLIDITY NOTES

//-------------------------Variables----------------------
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0; //Version of solidity, tell the compiler which version to use


contract NachoToken {

    uint256 public myUint = 0; //Default value is 0 (no values are non existent)

    function setMyUint(uint _myUint) public { //Underscore is just to diferentiate the variables
        myUint = _myUint; 
    }

    bool public myBool;

    function setMyBool(bool _myBool) public { //Bool can be false or true. If it contains something, then it will be true, if not, false.
        myBool = _myBool;
    }

    address public myAddress; // if you dont put public, once you deploy it, you wont be able to see it 
    
    function setAddress(address _address) public {
        myAddress = _address;
    }

    function getBalanceOfAddress() public view returns(uint){ //view functions are meant to be seen only, not to be written something
         return myAddress.balance; //balance is a method      //will return an integer in WEI (WEI is the smallest unit in the blockchain)
    } 

    string public myString;

    function setMyString(string memory _myString) public { //memory is to tell solidity that the value is stored in memory and not in a variable
        myString = _myString; //its harder to work with strings in solidity, many things dont work here (quite expensive to work with gas with strings)
    }
}

//-----------------------SEND AND TRANSFER------------------------------




// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

contract mySHIT {

    uint public balanceReceived;
    uint public lockedUntil; // Variable that will tell you until when it is locked the action

    function receiveMoney() public payable { //The smart contract can contain ether too, (payable only when we send money in, not out)
        balanceReceived += msg.value;       //in this function I send the ether to the contract, not to other account
        lockedUntil = block.timestamp + 1 minutes; //this will save the time that the function was called and then add 1 minut
    }                                        //msg.value access to the value itself of the amount received 

    function getBalance() public view returns(uint) { //the difference of this fucntion with the other balance one,
    //is that this one return the balance of the contract and the one above is of the account.
        return address(this).balance;
    }

    function withdrawMoney() public { //in this case, msg.sender is the one that calls the withdrawMoney function (msg.sender), so his address is the one stored
        if(lockedUntil < block.timestamp) { //if the locked until is less than the timestamp when this function is called, then 
        address to = msg.sender; //sending ether, a total of the balance in the contract
        payable(to).transfer(this.getBalance()); //a bit different from version .8.X you have to define payable not in the variable itself
        }
    }

    function withdrawMoneyTo(address payable _to) public { // you can send money and specifcy the address. The address that 
        if(lockedUntil < block.timestamp) {
        _to.transfer(this.getBalance()); // you put, will receive the whole amount, because the one that initiate the transactions pay the gas fee
        }
    }
    
}

// --------------------START STOP AND UPDATE-------------------------------

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

contract startStopUpdateExample {

    address owner;
    bool public paused; //initially its false

    constructor() public { //its called once and only once during contract deployment
        owner = msg.sender;
    }

    function sendMoney() public payable {

    }

    function setPaused(bool _paused) public {
        require(msg.sender == owner, "you are not the owner"); // you can only change the value of paused if you are the owner
        paused = _paused;
    }


    function withdrawAllMoney(address payable _to) public {
        require(msg.sender == owner, "you are not the owner"); //this is kinda an if statement, if the sender is the owner, the code will run, if not the exception will be triggerd and "you are not the owner" will appear.
        require(!paused, "contract is paused"); //if the contractes is not paused then the !paused will be (true) and the code will run
        _to.transfer(address(this).balance);
    }

    function destroySmartContract(address payable _to) public { //self destruct is build in solidity. The funds of the contract will go to the address that you put in the variable.
        require(msg.sender == owner, "you are not the owner");
        selfdestruct(_to);
    }


}
 


// ------------MAPPING--------------------
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

contract SimpleMappingExample {
    mapping(uint => bool) public myMapping; //the left of the arrow goes key type and in the left the value type.
                                            //mapping works like an array.

    mapping(address => bool) public myAddresMap;  

    mapping(uint => mapping(uint => bool)) uintUintBoolMapping; //not public, therefore we have to write the getter function, otherwise Solidity do it for us
 
    function setValue(uint _index) public {
        myMapping[_index] = true; //now if I put _index = 1, then when I input 1, the value will be true, but all the other ones will be 0.
    }

    function setMyAddressMapToTrue() public { //you can also put an address as the key value, and therefore control things only for that address
        myAddresMap[msg.sender] = true;
    }

    function setUintUintBoolMapping(uint _index1, uint _index2, bool _value) public {
        uintUintBoolMapping[_index1][_index2] = _value;
    }

    function getUintUintBoolMapping(uint _index1, uint _index2) public view returns (bool) {
        return uintUintBoolMapping[_index1][_index2]; //Had to write get function given that the mapping is not public
    }

}


//--------------------Mapping and Structs----------------------------------------


// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

contract MappingsStructExample{

    struct Payment {
        uint amount;
        uint timestamps;
    }

    struct Balance {
        uint totalBalance;
        uint numPayments; //this is because mappings have no length, and this will help us to store the length of the payments
        mapping(uint => Payment) payments;
    }

    mapping(address => Balance) public balanceReceived; //now, we are mapping one address with their total balance, number of payments and
                                                        // another mapping of the payments done, with the amount and the time.
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function sendMoney() public payable {
        balanceReceived[msg.sender].totalBalance += msg.value; //this increase the amount of money in the msg.sender address
        Payment memory payment = Payment(msg.value, block.timestamp); //with this I am creating the Payment structure with the info of the transaction
        balanceReceived[msg.sender].payments[balanceReceived[msg.sender].numPayments] = payment; //This line is to set the mapping of the Balance struct 
        balanceReceived[msg.sender].numPayments ++; //Because its 0 based, we have to increase it in one
    }

    function withdrawAllMoney(address payable _to) public {
        uint balanceToSend = balanceReceived[msg.sender].totalBalance; //We are storing the balance of the person equal to this variable
        balanceReceived[msg.sender].totalBalance = 0; //Because he is sending the money, then we settle it to 0 (assuming we are sending everything)
        _to.transfer(balanceToSend); //transfering the money to (_to address) with a total of the balance of the person sending it.
    } //interactions with thirds needs to be the last one thing to do, before update everything in the contract.

    function withdrawMoney(address payable _to, uint _amount) public { //This is a more real example, as you probably send some money
        require(balanceReceived[msg.sender].totalBalance >= _amount,"not enough funds"); //This tell us if the amount of money is enough
        balanceReceived[msg.sender].totalBalance -= _amount; //we discount the money from the person
        _to.transfer(_amount); // and we send it to the other person
    }
}

// ------Exceptions (overflow is not necessary for versions >0.8-----------------

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

contract ExceptionExample{

    mapping(address => uint64) public balanceReceived;

    function receiveMoney() public payable {
        assert(balanceReceived[msg.sender] + uint64(msg.value)>= balanceReceived[msg.sender]); //this assert line is for overflow, however from solidity 0.8 this is not a problem anymore
        balanceReceived[msg.sender] += uint64(msg.value); //the uint64() just turn it to uint64 instead of uint
    }

    function withdrawMoney(address payable _to, uint _amount) public {
        require(balanceReceived[msg.sender] >= uint64(_amount), "not enough funds");
        assert(balanceReceived[msg.sender]>= balanceReceived[msg.sender] -_amount);
        balanceReceived[msg.sender] -= uint64(_amount);
        _to.transfer(_amount);
    }
    
}

// -----------Constructor, Receive(or Fallback), view and pure.--------------------------------------

/ SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

contract FunctionsExample{

    mapping(address => uint) public balanceReceived;

    address owner; //in video, the set "address payable owner, however in v.8 msg.sender is a non payable by default, and when I try to overwrite it with msg.sender it has a conflict with a payable variable

    constructor() public { //In all the notes, the constructor do have visibility, however is not needed anymore (public keyword)
        owner = msg.sender;
    }

    function getOwner() public view returns(address) { //view functions only to VIEW information. View functions dont need to be mined.
        return owner;
    }

    function convertWeiToEther(uint _amountInWei) public pure returns(uint) { //Pure function are the ones that do not interact with any state variable(we usually write them on top
        return _amountInWei / 1 ether; //ether is just 10 to the power of 18
    }
    
    function destroySmartContract() public {
        require(msg.sender == owner, "You are not the owner");
        selfdestruct(payable(owner));//we have to put payable here otherwise it doesnt work
    }

    function receiveMoney() public payable {
        assert(balanceReceived[msg.sender] + uint64(msg.value)>= balanceReceived[msg.sender]); //this assert line is for overflow, however from solidity 0.8 this is not a problem anymore
        balanceReceived[msg.sender] += uint64(msg.value); //the uint64() just turn it to uint64 instead of uint
    }

    function withdrawMoney(address payable _to, uint _amount) public {
        require(balanceReceived[msg.sender] >= uint64(_amount), "not enough funds");
        assert(balanceReceived[msg.sender]>= balanceReceived[msg.sender] -_amount);
        balanceReceived[msg.sender] -= uint64(_amount);
        _to.transfer(_amount);
    }


    receive () external payable { //In some versions it could be a function instead of fallback, but both work the same
        receiveMoney();             //will run if no function behind is called
    }                               //In the video they use fallback, but because I use v.8 I use receive (to receive money) and fallback to interact with the contract without receiving money
    




}

//----------INHERITANCE and a token a bit more developed-------------
    
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;


contract Owned { //I could also have this in another file, and import it: import "./Owned.sol";
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() { //is to not write the same code over and over
        require(msg.sender == owner, "You are not allowed");
        _;
    }
}

contract InheritanceModifierExample is Owned { //the functionality from the Owned contract is inherited to this new contract

    mapping (address => uint) public tokenBalance;

    uint tokenPrice = 1 ether;

    constructor() public {
        tokenBalance[owner] = 100;
    }


    function createNewToken() public onlyOwner {
        tokenBalance[owner]++;
    }

    function burnToken() public onlyOwner {
        tokenBalance[owner]--;
    }

    function purchaseToken() public payable {
        require((tokenBalance[owner] * tokenPrice) / msg.value > 0, "Not enough tokens");
        tokenBalance[owner] -= msg.value / tokenPrice;
        tokenBalance[msg.sender] += msg.value / tokenPrice;
    }

    function sendToken(address _to, uint _amount) public {
        require(tokenBalance[msg.sender] >= _amount, "Not enough tokens");
        assert(tokenBalance[_to] + _amount >= tokenBalance[_to]);
        assert(tokenBalance[msg.sender] - _amount <= tokenBalance[msg.sender]);
    }


}

//----------EVENTS---------------------------------------- 

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;


contract EventExample {

    mapping (address => uint) public tokenBalance;

    event TokensSent(address _from, address _to, uint _amount);

    constructor() public {
        tokenBalance[msg.sender] = 100; 
    }

    function sendToken(address _to, uint _amount) public returns(bool) {
        require(tokenBalance[msg.sender] >= _amount, "Not enough tokens");
        assert(tokenBalance[_to] + _amount >= tokenBalance[_to]);
        assert(tokenBalance[msg.sender] - _amount <= tokenBalance[msg.sender]);
        tokenBalance[msg.sender] -= _amount;
        tokenBalance[_to] += _amount;

        emit TokensSent(msg.sender, _to, _amount); //this will "emit" the event we wrote at the beginning 

        return true; //in JS VM you can get returns, but in real BC you can't, therefore we use EVENTS
    }



}
    

//--------------------DEBUGGER, (GAS PRICE, CHECK ETH DOCS)---------------------

//All these can be found in remix, compilation details.
//ABI stands for application binary interface, and it contains the functions, parameters and return values (JSON FILE)
//FunctionHashes is how the solidity compiler read the function
//This functionhash is useful for debugger

// -------------------LIBRARIES---------------------------------------------------


// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.13;

//In github there is no math contract anymore given that it was solved, you can import it like this
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/(then copypaste the path that you can find in the library)

contract LibrariesExample { //This example explains how to solve overflow with a library (safemath) (in v.8+ is not necessary anymore)

    using SafeMath for uint; //this use the safemath library that we imported for ALL our uint variables

    mapping (address => uint) public tokenBalance;

    constructor() public {
        tokenBalance[msg.sender] = 1;
    }
    
    function sendToken(address _to, uint _amount) public returns(bool) {
        tokenBalance[msg.sender] = tokenBalance[msg.sender].sub(_amount); //sub is just substracting the amount, is the new way of doing it with the safemath library
        tokenBalance[_to] = tokenBalance[_to].add(_amount);
        return true;
    }

    

}


//-----------------------------