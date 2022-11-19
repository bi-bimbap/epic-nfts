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

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // create three arrays, each with their own theme of random words.
    string[] firstWords = ["Fantastic", "Epic", "Terrible", "Crazy", "Wild", "Terrifying", "Spooky"];
    string[] secondWords = ["Cupcake", "Pizza", "Milkshake", "Curry", "Chicken", "Sandwich", "Salad"];
    string[] thirdWords = ["Naruto", "Sasuke", "Sakura", "Goku", "Gaara", "Minato", "Kakshi", "Madara"];
    
    // ERC721 constructor requires passing name of NFT & symbol
    constructor() ERC721 ("SquareNFT", "Square") {
        console.log("This is my NFT contract");
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // randomly pick a word from each array
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // I seed the random generator. More on this in the lesson. 
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
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
        // We go and randomly grab one word from each of the three arrays.
        string memory first  = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third  = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // concatenate 3 words together, close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

        // get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
        
        // console.log("\n--------------------");
        // console.log(finalSvg);
        // console.log("--------------------\n");

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
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