This is a website where users can mint a random three-word combination NFT.
NFTs are created as an SVG. The NFTs & its metadata are Base64 encoded and stored on-chain.
Smart contracts are published using Hardhat plugin for integration with Etherscan's contract verification service.

The development of this website involves:
- Solidity (utilized OpenZeppelin libraries)
- Hardhat
- JavaScript
- React.js
- Ethers.js
- QuickNode

Taking the project further, consider:
- Hosting the NFTs on IPFS instead of storing on-chain (storage is expensive on blockchain)
- Adding functionality for selling NFTs (users just pay tx fees to mint NFTs currently)
- Adding royalties for future NFT sales as per EIP-2981

Website URL: https://nft-epic.bi-bimbap.repl.co/
Smart contracts published on Etherscan: https://goerli.etherscan.io/address/0xf1ea0f00e6f9178246f1fb9d6a3c0697b435ee25#code