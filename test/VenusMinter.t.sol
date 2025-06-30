// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VenusMinterContract.sol";

// Mock USDT token
contract MockUSDT {
    string public name = "USDT";
    string public symbol = "USDT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}

// Mock Venus vUSDT token
contract MockVUSDT {
    string public name = "vUSDT";
    string public symbol = "vUSDT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    uint256 public exchangeRate = 1e18; // 1:1 initially

    event Transfer(address indexed from, address indexed to, uint256 value);

    function mint(uint256 mintAmount) external returns (uint256) {
        uint256 vTokens = (mintAmount * 1e18) / exchangeRate;
        balanceOf[msg.sender] += vTokens;
        totalSupply += vTokens;
        emit Transfer(address(0), msg.sender, vTokens);
        return 0; // Success code
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(balanceOf[msg.sender] >= redeemTokens, "Insufficient balance");
        balanceOf[msg.sender] -= redeemTokens;
        totalSupply -= redeemTokens;
        emit Transfer(msg.sender, address(0), redeemTokens);
        return 0; // Success code
    }

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {
        uint256 vTokens = (redeemAmount * 1e18) / exchangeRate;
        require(balanceOf[msg.sender] >= vTokens, "Insufficient balance");
        balanceOf[msg.sender] -= vTokens;
        totalSupply -= vTokens;
        emit Transfer(msg.sender, address(0), vTokens);
        return 0; // Success code
    }

    function exchangeRateStored() external view returns (uint256) {
        return exchangeRate;
    }
}

contract VenusMinterTest is Test {
    VenusMinterContract public minter;
    MockUSDT public usdt;
    MockVUSDT public vusdt;
    
    address public admin = address(this);
    address public user = address(0x123);
    address public operator = address(0x456);

    function setUp() public {
        // Deploy mock tokens
        usdt = new MockUSDT();
        vusdt = new MockVUSDT();
        
        // Deploy minter contract
        minter = new VenusMinterContract();
        
        // Initialize contract
        minter.initialize(address(usdt), address(vusdt));
        
        // Mint some USDT to admin and user
        usdt.mint(admin, 10000 * 10**18);
        usdt.mint(user, 1000 * 10**18);
    }

    function testInitialization() public {
        assertEq(minter.USDT(), address(usdt));
        assertEq(address(minter.VUSDT()), address(vusdt));
        assertTrue(minter.hasRole(minter.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(minter.hasRole(minter.MINT_ROLE(), admin));
        assertTrue(minter.hasRole(minter.OPERATOR_ROLE(), admin));
    }

    function testMintWithPoolId() public {
        uint256 mintAmount = 100 * 10**18;
        
        // Approve USDT spending
        usdt.approve(address(minter), mintAmount);
        
        // Mint vUSDT
        minter.mint(1, mintAmount);
        
        // Check vUSDT balance
        assertGt(vusdt.balanceOf(address(minter)), 0);
    }

    function testMintForHolder() public {
        uint256 mintAmount = 100 * 10**18;
        
        // Approve USDT spending
        usdt.approve(address(minter), mintAmount);
        
        // Mint vUSDT for specific holder
        minter.mint(user, mintAmount);
        
        // Check vUSDT balance
        assertGt(vusdt.balanceOf(address(minter)), 0);
    }

    function testMintFromAddress() public {
        uint256 mintAmount = 100 * 10**18;
        
        // User approves USDT spending
        vm.prank(user);
        usdt.approve(address(minter), mintAmount);
        
        // Mint vUSDT from user's address
        minter.mint(1, mintAmount, user);
        
        // Check vUSDT balance
        assertGt(vusdt.balanceOf(address(minter)), 0);
    }

    function testRedeem() public {
        uint256 redeemAmount = 100 * 10**18;
        
        // Mint some vUSDT first
        usdt.approve(address(minter), redeemAmount);
        minter.mint(1, redeemAmount);
        
        // Redeem vUSDT
        minter.redeem(redeemAmount);
    }

    function testRedeemUnderlying() public {
        uint256 redeemAmount = 100 * 10**18;
        
        // Mint some vUSDT first
        usdt.approve(address(minter), redeemAmount);
        minter.mint(1, redeemAmount);
        
        // Redeem underlying USDT
        minter.redeemUnderlying(redeemAmount);
    }

    function testSetHolders() public {
        address[] memory holders = new address[](2);
        holders[0] = address(0x111);
        holders[1] = address(0x222);
        
        minter.setHolders(holders);
        
        address[] memory currentHolders = minter.getHolders();
        assertEq(currentHolders.length, 2);
        assertEq(currentHolders[0], address(0x111));
        assertEq(currentHolders[1], address(0x222));
    }

    function testSetTokenId() public {
        uint256 tokenId = 12345;
        minter.setTokenId(tokenId);
        assertEq(minter.tokenId(), tokenId);
    }

    function testRoleManagement() public {
        // Grant role to operator
        minter.grantRole(minter.MINT_ROLE(), operator);
        assertTrue(minter.hasRole(minter.MINT_ROLE(), operator));
        
        // Revoke role
        minter.revokeRole(minter.MINT_ROLE(), operator);
        assertFalse(minter.hasRole(minter.MINT_ROLE(), operator));
    }

    function testUnauthorizedMint() public {
        vm.prank(user);
        vm.expectRevert();
        minter.mint(1, 100 * 10**18);
    }

    function testUnauthorizedRedeem() public {
        vm.prank(user);
        vm.expectRevert();
        minter.redeem(100 * 10**18);
    }

    function testUnauthorizedSetHolders() public {
        address[] memory holders = new address[](1);
        holders[0] = address(0x111);
        
        vm.prank(user);
        vm.expectRevert();
        minter.setHolders(holders);
    }

    function testBatchAddHolder() public {
        uint256 size = 5;
        minter.batchAddHolder(size);
        // Note: This function is a placeholder in the current implementation
    }

    function testSupportsInterface() public {
        // Test ERC165 interface support
        assertTrue(minter.supportsInterface(0x01ffc9a7)); // ERC165
        assertTrue(minter.supportsInterface(0x7965db0b)); // AccessControl
    }

    function testUpgradeFunctionality() public {
        // Test that upgrade is restricted to admin
        address newImplementation = address(0x999);
        
        vm.prank(user);
        vm.expectRevert();
        minter.upgradeToAndCall(newImplementation, "");
        
        // Admin should be able to upgrade
        minter.upgradeToAndCall(newImplementation, "");
    }
} 