// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { SpaceV2 } from "./mocks/SpaceV2.sol";
import { TRUE, FALSE, SpaceTest } from "./utils/Space.t.sol";
import { Choice, IndexedStrategy, Strategy, UpdateSettingsCalldata } from "../src/types.sol";
import { VanillaExecutionStrategy } from "../src/execution-strategies/VanillaExecutionStrategy.sol";
import { AIVoter } from "../src/ai/AIVoter.sol";
import { BitPacker } from "../src/utils/BitPacker.sol";

contract AIVoterTest is SpaceTest {
    using BitPacker for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function testAIVote() public {
        uint256 proposalId = _createProposal(author, proposalMetadataURI, executionStrategy, new bytes(0));
        AIVoter aiVoter = new AIVoter(space);

        // Add ai voter authenticator
        address[] memory newAuths = new address[](1);
        newAuths[0] = address(aiVoter);

        space.updateSettings(
            UpdateSettingsCalldata(
                NO_UPDATE_UINT32,
                NO_UPDATE_UINT32,
                NO_UPDATE_UINT32,
                NO_UPDATE_STRING,
                NO_UPDATE_STRING,
                NO_UPDATE_STRATEGY,
                "",
                newAuths,
                NO_UPDATE_ADDRESSES,
                NO_UPDATE_STRATEGIES,
                NO_UPDATE_STRINGS,
                NO_UPDATE_UINT8S
            )
        );

        aiVoter.vote(proposalId, "This is an example proposal", userVotingStrategies);
    }

}