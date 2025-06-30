// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VenusMinterContract.sol";

contract DeployVenusMinter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // BSC Mainnet addresses
        address USDT = 0x55d398326f99059fF775485246999027B3197955; // BSC USDT
        address VUSDT = 0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8; // BSC vUSDT
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the VenusMinterContract
        VenusMinterContract minter = new VenusMinterContract();
        
        // Initialize the contract
        minter.initialize(USDT, VUSDT);
        
        vm.stopBroadcast();
        
        console.log("VenusMinterContract deployed at:", address(minter));
        console.log("USDT:", USDT);
        console.log("VUSDT:", VUSDT);
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        
        // Save deployment info
        string memory deploymentInfo = string.concat(
            "VenusMinterContract deployed at: ",
            vm.toString(address(minter)),
            "\nUSDT: ",
            vm.toString(USDT),
            "\nVUSDT: ",
            vm.toString(VUSDT),
            "\nDeployer: ",
            vm.toString(vm.addr(deployerPrivateKey))
        );
        
        vm.writeFile("venus_deployment.txt", deploymentInfo);
    }
} 