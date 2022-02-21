import { ethers } from "hardhat"
import { useEffect,useState } from "react"
import axios from 'axios'
import Web3Modal from "web3modal"

import NFT from '../artifacts/contracts/NFT.sol/NFT.json'
import Market from '../artifacts/contracts/Market.sol/NFTMarket.json'
import {
  nftaddress, nftmarketaddress
} from '../config'

export default function Home() {

  const [nfts, setNfts] = useState([])
  const [loadingState, setLoadingState] = useState('not-loaded')

  useEffect(() => {
    
    loadNFTs()
  }, [])


   /* create a generic provider and query for unsold market items */
  const loadNFTs = async _=>{
    // connect wallet
    const provider = new ethers.provider.JsonRpcProvider()

    // references to the smart contract
    const tokenContract = new ethers.Contract(nftaddress,NFT.abi,provider)
    const marketContact = new ethers.Contract(nftmarketaddress,Market.abi,provider)

    // fetch all market items
    const data = await marketContact.fetchMarketItems()

     /*
    *  map over items returned from smart contract and format 
    *  them as well as fetch their token metadata
    */
    const items = await Promise.all(data.map(async i => {
      const tokenUri = await tokenContract.tokenURI(i.tokenId)
      const meta = await axios.get(tokenUri)
      let price = ethers.utils.formatUnits(i.price.toString(), 'ether')
      let item = {
        price,
        tokenId: i.tokenId.toNumber(),
        seller: i.seller,
        owner: i.owner,
        image: meta.data.image,
        name: meta.data.name,
        description: meta.data.description,
      }
      return item
    }))
    setNfts(items)
    setLoadingState('loaded') 
  }


  
  

  return (
    <div>

    </div>
  )
}
