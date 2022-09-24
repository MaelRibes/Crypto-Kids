 // SPDX-License-Identifier: Unlicensed

 pragma solidity ^0.8.7;

 contract CryptoKids {


    // owner (dad)

    address owner;

    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);

    constructor(){
        owner = msg.sender; //msg.sender get the address which deploy de contract
    }


    // define Kid object

    struct Kid{
        address payable walletAddress;
        string firstName;
        string lastname;
        uint releaseTime;
        uint amount; 
        bool canWithdrow;
    }    


    // add kid to contract

    Kid[] public kids; // array containing all the kids of the contract

    modifier onlyOwner() {
        require(msg.sender == owner, "You must be the owner of the contract to add a kid");
        _;
    }

    function isAlreadyKid(address walletAddress) private view returns(bool){
        for(uint i = 0 ; i < kids.length ; i++){
            if(kids[i].walletAddress == walletAddress){
                return true;
            }
        }
        return false;

    }

    function addKid(address payable walletAddress, string memory firstName, string memory lastname, uint releaseTime, uint amount, bool canWithdrow) public onlyOwner {
        require(!isAlreadyKid(walletAddress),"You already add a kid with this address");
        kids.push(Kid(
            walletAddress,
            firstName,
            lastname,
            releaseTime,
            amount,
            canWithdrow
        ));
    }

    function balanceOfContract() public view returns(uint){
        return address(this).balance;
    }


    // deposit funds to contract, specifically to a kid's account

    function deposit(address walletAddress) payable public onlyOwner{
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance (address walletAddress) private {
        for(uint i = 0 ; i < kids.length ; i++){
            if(kids[i].walletAddress == walletAddress) {
            kids[i].amount += msg.value; 
            emit LogKidFundingReceived(walletAddress, msg.value, balanceOfContract());
            }
        }
    }


    // kid check if able to withdraw

    function getIndex(address walletAddress) view private returns(uint){
        for(uint i = 0 ; i < kids.length ; i++){
            if(kids[i].walletAddress == walletAddress){
                return i;
            }
        }
        return 999;
    }

    function availableToWithdrow(address walletAddress) public returns(bool){
        uint index = getIndex(walletAddress);
        require(block.timestamp > kids[index].releaseTime, "You cannot withdraw yet");
        if (block.timestamp > kids[index].releaseTime){
            kids[index].canWithdrow = true;
            return true;
        }
        else {return false;}
    }


    // withdraw money

    function withdraw(address payable walletAddress, uint amountToWithdraw) payable public{
        uint index = getIndex(walletAddress);
        availableToWithdrow(walletAddress);
        require(msg.sender == kids[index].walletAddress, "You must be the kid to withdraw");
        require(kids[index].canWithdrow == true, "You can not withdraw for the moment");
        require(kids[index].amount >= amountToWithdraw*(10**18), "You can not withdraw more than you have");
        kids[index].walletAddress.transfer(amountToWithdraw*(10**18));
        kids[index].amount -= amountToWithdraw*(10**18);
    }
 }

 