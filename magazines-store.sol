// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/**
 * @title MagazinesStore
 * @dev Track magazines' issues purchases
 */
contract MagazinesStore {

    uint issuePriceInUsd = 2;
    address payable publisherAddress = payable(0xFF7eA940111d8b6FAbfE341d2356054631883946);
    
    mapping(address => uint8[]) public purchases;  
    
    AggregatorV3Interface internal priceFeed;
    
    constructor() public {
        //priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e); 
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331); 
    
    }
    
    
    /**
     * @dev Store value in variable
     * @param issueUniqueId the id of the issue we are going to buy
     */
    function buy_issue(uint8 issueUniqueId) public payable {
    
        uint8 decimals = priceFeed.decimals();
        uint ethPriceInUsd = uint(getEthPrice()) / uint(10 ** decimals);
        uint buyableIssuesPerEth = ethPriceInUsd / issuePriceInUsd;
        uint issuePriceInWei = (10 ** 18) / buyableIssuesPerEth;
        require (msg.value >= issuePriceInWei);
        
        purchases[msg.sender].push(issueUniqueId);
        publisherAddress.transfer(issuePriceInWei);
        address payable sender = payable(msg.sender);
        sender.transfer(msg.value - issuePriceInWei);
    }
    
    
    function getEthPrice() public view returns (int) {
        (
            uint80 roundID, 
            int ethPrice,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        return ethPrice;
    }
    
    function getPurchases() public view returns (uint8[] memory)
    {
        return purchases[msg.sender];
    }

}
