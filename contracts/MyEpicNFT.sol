// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    // attach every function from library Counters to type Counters.Conter
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // SVG code - make a baseSvg var here that can be reused 
    // only the words will change, everything else is the same
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // three arrays, each with their own theme of random words.
    string[] firstWords  = ["Fantastic", "Epic", "Terrible", "Crazy", "Wild", "Terrifying", "Spooky"];
    string[] secondWords = ["Cupcake", "Pizza", "Milkshake", "Curry", "Chicken", "Sandwich", "Salad"];
    string[] thirdWords  = ["Naruto", "Sasuke", "Sakura", "Goku", "Gaara", "Minato", "Kakshi", "Madara"];
    
    // ERC721 constructor requires passing name of NFT & symbol
    constructor() ERC721 ("SquareNFT", "Square") {
        console.log("This is my NFT contract");
    }

    function random(string memory input) internal pure returns (uint256) {
        // input for kecchak236 needs to be encoded into bytes
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // randomly pick a word from each array
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // create source of randomness by concat 2 strings
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // squash the # between 0 & length of array to avoid going out of bounds
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    // users will hit this func to get their NFT
    function makeAnEpicNFT() public {
        // get current tokenId, starts at 0
        uint256 newItemId = _tokenIds.current();
        // randomly get 1 word from each arrays
        string memory first  = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third  = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // concatenate all 3 words, close <text> & <svg> tags
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

        // get JSON metadata in place & base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // set title of NFT as the generated word
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // add "data:image/svg+xml;base64", then append base64 encoded svg
                        // "data:image/svg+xml;base64" = process this base64 encoded data as a SVG
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
        
        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");

        // prepend "data:application/json;base64" to our data
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        // preview image & JSON content
        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        // mint NFT to sender 
        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment(); // increment counter for next NFT

        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    }

    // set NFT's metadata
    // OpenSea will call the func automatically to fetch the data and display it automatically
    // no need to call it explicitly
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // _exists is a built in function to to verify if the tokenId exists in a contract
        require(_exists(_tokenId));
        console.log("An NFT w/ ID %s has been minted to %s", _tokenId, msg.sender);
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                "ewogICAgIm5hbWUiOiAiRXBpY0xvcmRIYW1idXJnZXIiLAogICAgImRlc2NyaXB0aW9uIjogIkFuIE5GVCBmcm9tIHRoZSBoaWdobHkgYWNjbGFpbWVkIHNxdWFyZSBjb2xsZWN0aW9uIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0S0lDQWdJRHh6ZEhsc1pUNHVZbUZ6WlNCN0lHWnBiR3c2SUhkb2FYUmxPeUJtYjI1MExXWmhiV2xzZVRvZ2MyVnlhV1k3SUdadmJuUXRjMmw2WlRvZ01UUndlRHNnZlR3dmMzUjViR1UrQ2lBZ0lDQThjbVZqZENCM2FXUjBhRDBpTVRBd0pTSWdhR1ZwWjJoMFBTSXhNREFsSWlCbWFXeHNQU0ppYkdGamF5SWdMejRLSUNBZ0lEeDBaWGgwSUhnOUlqVXdKU0lnZVQwaU5UQWxJaUJqYkdGemN6MGlZbUZ6WlNJZ1pHOXRhVzVoYm5RdFltRnpaV3hwYm1VOUltMXBaR1JzWlNJZ2RHVjRkQzFoYm1Ob2IzSTlJbTFwWkdSc1pTSStSWEJwWTB4dmNtUklZVzFpZFhKblpYSThMM1JsZUhRK0Nqd3ZjM1puUGc9PSIKfQ=="
            )
        );
    }
}