//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract NFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public contractAddress;

    // reference to the marketplace contract
    constructor(address marketplaceAddress) ERC721 ("NevNFT Tokens","NEVNFT"){
        contractAddress = marketplaceAddress;
    }

    function createTokens(string memory tokenURI) public returns (uint){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender,newItemId); // the creator
        _setTokenURI(newItemId,tokenURI); // attach the token URI
        setApprovalForAll(contractAddress,true); // give the marketplace the approval to transact this tokens between users
        return newItemId;
    }

}