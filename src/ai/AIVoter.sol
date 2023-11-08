// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { ISpace } from "../interfaces/ISpace.sol";
import { IndexedStrategy, Choice } from "../types.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract AIVoter is Ownable {
    ISpace public space;
    address public voter;
    string public prompt = "Vote on the subsequent proposal. Please return the result in the format 'Y/N/A:reason' where Y is for FOR, N is for AGAINST and A is for ABSTAIN and reason is the reason you made this decision based on the proposal. The proposal: ";

    constructor(ISpace _space) {
        space = _space;
    }

    function setPrompt(string memory _prompt) public onlyOwner {
        prompt = _prompt;
    }

    function decide(string memory proposal) public pure returns (Choice, string memory) {
        string memory result = llmInference(string.concat(prompt, proposal));

        string memory v = substring(result, 0, 1);
        string memory reason = substring(result, 2, bytes(result).length);

        if (keccak256(abi.encodePacked((v))) == keccak256(abi.encodePacked(("Y")))) {
            return (Choice.For, reason);
        } else if (keccak256(abi.encodePacked((v))) == keccak256(abi.encodePacked(("N")))) {
            return (Choice.Against, reason);
        } else if (keccak256(abi.encodePacked((v))) == keccak256(abi.encodePacked(("A")))) {
            return (Choice.Abstain, reason);
        }

        revert(string.concat("Unknown vote: ", v, " with reason: ", reason));
    }

    function vote(uint256 proposalId, string calldata proposal, IndexedStrategy[] calldata userVotingStrategies) public onlyOwner {
        (Choice choice, string memory reason) = decide(proposal);
        space.vote(address(this), proposalId, choice, userVotingStrategies, reason);
    }

    // Returns the substring from start index to end index (exclusive)
    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(startIndex < endIndex, "Start index must be less than end index.");
        require(endIndex <= strBytes.length, "End index out of bounds.");

        bytes memory result = new bytes(endIndex - startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function llmInference(string memory prompt) public pure returns (string memory) {
        return "A: I am neutral on this proposal.";
    }

}
