// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , , uint256 deployerkey) = helperConfig
            .activeNetworkConfig();
        return createSubscription(vrfCoordinator, deployerkey);
    }

    function createSubscription(
        address vrfCoordinator,
        uint256 deployerkey
    ) public returns (uint64) {
        console.log("Creating subscription on chainID ", block.chainid);
        vm.startBroadcast(deployerkey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("your sub Id is :", subId);
        console.log("Please update subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns (uint256) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subId,
            ,
            address link,
            uint256 deployerkey
        ) = helperConfig.activeNetworkConfig();

        fundSubscription(vrfCoordinator, subId, link, deployerkey);
    }

    function fundSubscription(
        address vrfCoodinator,
        uint64 subId,
        address link,
        uint256 deployerkey
    ) public {
        console.log("Funding", subId);
        console.log("Using vrfCoordinator", vrfCoodinator);
        console.log("On chainID", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerkey);
            VRFCoordinatorV2Mock(vrfCoodinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            //
            vm.startBroadcast(deployerkey);
            LinkToken(link).transferAndCall(
                vrfCoodinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address raffle,
        address vrfCoordinator,
        uint64 subId,
        uint256 deployerkey
    ) public {
        console.log("Adding consumer contract: ", raffle);
        console.log("Using vrfCoordinator:", vrfCoordinator);
        console.log(" On ChainID:", block.chainid);
        vm.startBroadcast(deployerkey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subId,
            ,
            ,
            uint256 deployerkey
        ) = helperConfig.activeNetworkConfig();
        addConsumer(raffle, vrfCoordinator, subId, deployerkey);
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffle);
    }
}
