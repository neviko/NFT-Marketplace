//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract NFTMarket is ReentrancyGuard {

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold;

    address payable public owner; 
    uint public listingPrice = 0.025 ether;
    constructor(){
        owner = payable(msg.sender); // the sender gets ownership over the contract
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool sold
    );

    mapping(uint256 => MarketItem) private idToMarketItem;

/* Returns the listing price of the contract */
    function getListingPrice() public view returns(uint256){
        return listingPrice;
    }

    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        
        uint itemId =  _itemIds.current();

        // insert into map
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender), // seller 
            payable(address(0)), // owner - nobody
            price,
            false
        );
        // transfer the NFT between addresses
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        _itemIds.increment();
    }    


    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */

    function createMarketSale(address nftContract, uint itemId) public payable nonReentrant {

        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;  
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        
        idToMarketItem[itemId].seller.transfer(price);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); // new NFT ownership
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemSold.increment();
        payable(owner).transfer(listingPrice); // gas fee? 
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory){
        uint unsoldItemCount = _itemIds.current() - _itemSold.current();
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        uint itemsIndex;

        for(uint i=0 ; i< unsoldItemCount; i++){
            if(idToMarketItem[i].owner != address(0)){
                continue;
            }
            MarketItem storage currItem = idToMarketItem[i];
            items[itemsIndex] = currItem;
            itemsIndex +=1;

        }

        return items;
    }


    /* Returns only items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory){
        // get all nfts that owner is equal to the sender
        uint myNftCounter = 0;
        uint totalItemCount = _itemIds.current();

        for(uint i=0; i< _itemIds.current() ;i++ ){
            if(idToMarketItem[i].owner == msg.sender){
                myNftCounter +=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](totalItemCount);
        uint returnArrayIndex = 0;
        for(uint i=0; i< _itemIds.current() ;i++ ){
            if(idToMarketItem[i].owner == msg.sender){
                MarketItem storage tempItem = idToMarketItem[i];
                items[returnArrayIndex] = tempItem;
                returnArrayIndex+=1;
            }
        }
        return items;
    }


    /**
        fetch item created by the user
     */
     function fetchCreatedByMyself() public view returns (MarketItem[] memory){
        // get all nfts that owner is equal to the sender
        uint myNftCounter = 0;
        uint totalItemCount = _itemIds.current();

        for(uint i=0; i< _itemIds.current() ;i++ ){
            if(idToMarketItem[i].seller == msg.sender){
                myNftCounter +=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](totalItemCount);
        uint returnArrayIndex = 0;
        for(uint i=0; i< _itemIds.current() ;i++ ){
            if(idToMarketItem[i].seller == msg.sender){
                MarketItem storage tempItem = idToMarketItem[i];
                items[returnArrayIndex] = tempItem;
                returnArrayIndex+=1;
            }
        }
        return items;
    }

    

    
}