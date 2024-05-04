// SPDX-License-identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

error Ruffle__NotEnoughETHEntered();
error Raffle__TrasnferFailed();

contract Ruffle is VRFConsumerBaseV2{
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionID;
    uint32 private immutable i_callbackGasLimite;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint16 private constant NUM_WORDS = 1;

    //Raffle vars
    address private s_recentWinner;

    // Events 
    event RaffelEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor (address vrfCoordinatorV2,uint256 entranceFee, bytes32 gasLane, uint64 subscriptionID, uint32 callackGasLimit) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionID = subscriptionID;
        i_callbackGasLimite = callackGasLimit;
    }

    function enterRaffle() public payable {
        if(msg.value < i_entranceFee){
            revert Ruffle__NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        emit RaffelEnter(msg.sender);
    }

    function requestRandomWinner() external {  
        //req random num
        // once we get it do something with it 
        // we will do 2 transaction process coze if we did it with in 1 tracsaction then some one can try to do the same and can manipulate the raffle and win...
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionID,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimite,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256 /* requestId */,  uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value : address(this).balance}("");
        if(!success) {
            revert Raffle__TrasnferFailed();
        }
        emit WinnerPicked(recentWinner);
    }
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
    function getRecentWinner() public view returns(address) {
        return s_recentWinner;
    }
}

//contract 

//state variables

//declar a private and immutable var entranceFee which will be immutable var so use i_
//make address type payable[] private variable which will be storage variable

//constractor which will take entranceFee as argument and initealize the main entranceFee var

//declare ruffle function which will be public and payable where 
// 1st check enough entrance fee is entered or not if not then throw revert Raffle__NotEnoughETHEntered() and declare it out side the contract

//declare function getentrancefee public view returns entrancefee