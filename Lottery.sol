//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
        players.push(payable(manager));
    }

    // Allow for contract to recieve ETH
    receive() external payable {
        require(msg.sender != manager);
        require(msg.value == 0.1 ether); // Requires that the user sends 0.1 ETH
        players.push(payable(msg.sender)); // Address who sends ETH will be pushed into players array
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager, "Not the manager");
        return address(this).balance; // Returns current balance of contract in WEI
    }

    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
        // Block difficulty is the difficulty level of the current block
        // Block timestamp is  the date and time the block was mined
        // Players.length is the length of the players dymanic array
        // Function is converted and returned as a uint value
        // Vulnerable because a miner has control over blocks mined, can control publishing of block
    }

    function pickWinner() public {
        require(msg.sender == manager, "Only Manager");
        require(players.length >= 3, "Not enough players to pick winner");

        uint r = random(); // Calls random function
        address payable winner; // Creates winner variable

        uint index = r % players.length; // Will take the random number and derive a specific spot in dynamic array
        winner = players[index]; // sets the spot in the array as the winner of the lottery

        uint managerFee = (getBalance() * 10) / 100; // Manager takes 10% of lottery pot
        uint payout = (getBalance() * 90) / 100; // Winner gets 90% of the lottery pot

        winner.transfer(payout); // Use .transfer to send the value of getBalance() function to winning address
        payable(manager).transfer(managerFee); // Use .transfer to send manager the fee. Manager must be converted to payable

        players = new address payable[](0); // Initializes new dynamic array to reset the lottery
    }

}