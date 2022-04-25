// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

// Import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// Import helper functions from Base64 encoder
import { Base64 } from "./libraries/Base64.sol";

contract BlackandGoldNFT is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: gold; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["GO", "BOILER", "GOLD", "BLACK", "PURDUE", "HAIL", "OLD", "AllAboard"];
    string[] secondWords = ["BOILERS", "PURDUE", "GoldAndBlack", "PETE", "BOILERMAKERS", "UP", "SPECIAL", "GOLD", "BLACK", "BlackandGold"];
    event NewBlackandGoldNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721 ("BlackandGold-NFT", "BAG") {
        console.log("Constructed BlackandGoldNFT, a project by Matthew Orris");
    }

    // Function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // Seed the random generator.
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

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeBlackandGoldNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // Randomly grab one word from each of the string arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second));

        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // Set the title of the NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of random Purdue phrases.", "image": "data:image/svg+xml;base64,',
                        // Add data:/svg+xml;base 64 and then append base64 encode.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

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

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewBlackandGoldNFTMinted(msg.sender, newItemId);
    }
}