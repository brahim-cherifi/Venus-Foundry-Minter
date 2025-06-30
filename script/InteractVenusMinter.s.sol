// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VenusMinterContract.sol";

contract InteractVenusMinter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Load deployment info
        string memory deploymentInfo = vm.readFile("venus_deployment.txt");
        console.log("Deployment Info:");
        console.log(deploymentInfo);
        
        // Replace with actual contract address after deployment
        address contractAddress = 0x0000000000000000000000000000000000000000;
        
        vm.startBroadcast(deployerPrivateKey);
        
        VenusMinterContract minter = VenusMinterContract(contractAddress);
        
        console.log("\n=== Venus Minter Interactions ===");
        
        // 1. Check roles
        console.log("\n1. Checking roles:");
        bool hasMintRole = minter.hasRole(minter.MINT_ROLE(), vm.addr(deployerPrivateKey));
        bool hasOperatorRole = minter.hasRole(minter.OPERATOR_ROLE(), vm.addr(deployerPrivateKey));
        bool hasAdminRole = minter.hasRole(minter.DEFAULT_ADMIN_ROLE(), vm.addr(deployerPrivateKey));
        
        console.log("Has MINT_ROLE:", hasMintRole);
        console.log("Has OPERATOR_ROLE:", hasOperatorRole);
        console.log("Has DEFAULT_ADMIN_ROLE:", hasAdminRole);
        
        // 2. Set holders
        console.log("\n2. Setting holders:");
        address[] memory holders = new address[](3);
        holders[0] = 0x1234567890123456789012345678901234567890;
        holders[1] = 0x2345678901234567890123456789012345678901;
        holders[2] = 0x3456789012345678901234567890123456789012;
        
        minter.setHolders(holders);
        console.log("Holders set successfully");
        
        // 3. Set token ID
        console.log("\n3. Setting token ID:");
        minter.setTokenId(12345);
        console.log("Token ID set to 12345");
        
        // 4. Check holders
        console.log("\n4. Checking holders:");
        address[] memory currentHolders = minter.getHolders();
        console.log("Number of holders:", currentHolders.length);
        for (uint256 i = 0; i < currentHolders.length; i++) {
            console.log("Holder", i, ":", currentHolders[i]);
        }
        
        // 5. Grant roles to another address
        console.log("\n5. Granting roles:");
        address newMinter = 0x4567890123456789012345678901234567890123;
        minter.grantRole(minter.MINT_ROLE(), newMinter);
        minter.grantRole(minter.OPERATOR_ROLE(), newMinter);
        console.log("Granted roles to:", newMinter);
        
        vm.stopBroadcast();
        
        console.log("\n=== Interaction Complete ===");
        console.log("\nNote: Minting and redeeming functions require USDT approval");
        console.log("and sufficient USDT balance in the caller's wallet.");
    }
} 