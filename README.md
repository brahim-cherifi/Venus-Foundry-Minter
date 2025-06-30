# Venus Protocol Minter Contract

A complete implementation of a Venus Protocol minting and redeeming contract based on the provided ABI.

## 🏗️ Contract Overview

This contract provides a secure interface for minting and redeeming Venus Protocol vUSDT tokens with role-based access control and upgradeable functionality.

### Key Features

- **Role-Based Access Control**: Different roles for minting, operating, and administration
- **Upgradeable Contract**: UUPS upgrade pattern for future improvements
- **Venus Integration**: Direct integration with Venus Protocol vUSDT
- **Batch Operations**: Support for batch holder management
- **Event Logging**: Comprehensive event tracking for all operations

## 📁 File Structure

```
├── foundry.toml                    # Foundry configuration
├── README.md                       # This file
├── src/
│   └── VenusMinterContract.sol     # Main contract implementation
├── script/
│   ├── DeployVenusMinter.s.sol     # Deployment script
│   └── InteractVenusMinter.s.sol   # Interaction script
└── test/
    └── VenusMinter.t.sol           # Comprehensive test suite
```

## 🚀 Quick Start

### Prerequisites

1. **Install Foundry**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Setup Project**
   ```bash
   cd venus-contract-setup
   git init
   forge install foundry-rs/forge-std
   forge install OpenZeppelin/openzeppelin-contracts-upgradeable
   ```

3. **Set Environment Variables**
   ```bash
   export PRIVATE_KEY="your-private-key"
   export BSCSCAN_API_KEY="your-bscscan-api-key"
   ```

### Basic Commands

```bash
# Compile contracts
forge build

# Run tests
forge test -vv

# Deploy to BSC testnet
forge script script/DeployVenusMinter.s.sol --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 --broadcast --verify -vvvv

# Interact with contract
forge script script/InteractVenusMinter.s.sol --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 --broadcast -vvvv
```

## 🔧 Contract Functions

### Core Functions

#### **Minting Functions**
```solidity
// Mint vUSDT for a specific pool
function mint(uint256 poolId, uint256 mintAmount) external

// Mint vUSDT for a specific holder
function mint(address holder, uint256 mintAmount) external

// Mint vUSDT from a specific address
function mint(uint256 poolId, uint256 mintAmount, address from) external
```

#### **Redeeming Functions**
```solidity
// Redeem vUSDT tokens
function redeem(uint256 redeemAmount) external

// Redeem underlying USDT
function redeemUnderlying(uint256 redeemAmount) external
```

#### **Admin Functions**
```solidity
// Set holders array
function setHolders(address[] memory _holders) external

// Set token ID
function setTokenId(uint256 _tokenId) external

// Grant role to address
function grantRole(bytes32 role, address account) external

// Revoke role from address
function revokeRole(bytes32 role, address account) external
```

## 🛡️ Access Control

### Roles

- **DEFAULT_ADMIN_ROLE**: Can manage all roles and upgrade contract
- **MINT_ROLE**: Can mint vUSDT tokens
- **OPERATOR_ROLE**: Can redeem tokens and perform operations

### Role Management

```solidity
// Grant role
minter.grantRole(minter.MINT_ROLE(), newMinter);

// Revoke role
minter.revokeRole(minter.MINT_ROLE(), oldMinter);

// Check role
bool hasRole = minter.hasRole(minter.MINT_ROLE(), address);
```

## 🚀 Deployment

### Deploy to BSC Mainnet

```bash
forge script script/DeployVenusMinter.s.sol --rpc-url https://bsc-dataseed.binance.org --broadcast --verify -vvvv
```

### Deploy to BSC Testnet

```bash
forge script script/DeployVenusMinter.s.sol --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 --broadcast --verify -vvvv
```

## 🧪 Testing

### Run All Tests
```bash
forge test -vv
```

### Run Specific Test

```bash
forge test --match-test testMintWithPoolId -vv
```

### Generate Gas Report

```bash
forge test --gas-report
```

## 📊 Usage Examples

### 1. Initialize Contract

```solidity
VenusMinterContract minter = new VenusMinterContract();
minter.initialize(USDT_ADDRESS, VUSDT_ADDRESS);
```

### 2. Mint vUSDT

```solidity
// Approve USDT spending
IERC20(USDT).approve(address(minter), amount);

// Mint vUSDT
minter.mint(1, amount); // Pool ID 1
```

### 3. Redeem vUSDT

```solidity
// Redeem vUSDT tokens
minter.redeem(amount);

// Or redeem underlying USDT
minter.redeemUnderlying(amount);
```

### 4. Manage Holders

```solidity
// Set holders array
address[] memory holders = new address[](2);
holders[0] = address1;
holders[1] = address2;
minter.setHolders(holders);

// Get holders
address[] memory currentHolders = minter.getHolders();
```

### 5. Role Management

```solidity
// Grant minting role
minter.grantRole(minter.MINT_ROLE(), newMinter);

// Check role
bool canMint = minter.hasRole(minter.MINT_ROLE(), newMinter);
```

## 🔍 Contract Addresses

### BSC Mainnet

- **USDT**: `0x55d398326f99059fF775485246999027B3197955`
- **VUSDT**: `0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8`

### BSC Testnet

- **USDT**: `0x337610d27c682E347C9cD60BD4b3b107C9d34dDd`
- **VUSDT**: `0x16227D60f7a0e586C66B005219dfc887D13C9531`

## 📈 Events

### Core Events

```solidity
event Minted(address indexed holder, uint256 amount, uint256 poolId);
event Redeemed(address indexed holder, uint256 amount);
event RedeemedUnderlying(address indexed holder, uint256 amount);
event HoldersSet(address[] holders);
event TokenIdSet(uint256 tokenId);
```

### Access Control Events

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
```

## ⚠️ Security Considerations

### Access Control

- Only authorized addresses can mint and redeem
- Role-based permissions prevent unauthorized access
- Admin can grant/revoke roles as needed

### Upgrade Safety

- Only admin can upgrade the contract
- UUPS pattern ensures upgrade safety
- Implementation can be upgraded without changing proxy

### Token Safety

- Proper approval checks before transfers
- Sufficient balance validation
- Event emission for all state changes

## 🔧 Configuration

### Contract Parameters

- **USDT Address**: BSC USDT token contract
- **VUSDT Address**: Venus vUSDT token contract
- **Token ID**: Configurable token identifier
- **Holders**: Array of authorized holder addresses

### Gas Optimization

- Efficient role checking
- Minimal storage operations
- Optimized function calls

## 📞 Support

For questions or issues:

1. Check the test files for usage examples
2. Review the contract comments
3. Run tests to verify functionality
4. Check Venus Protocol documentation

## 📚 Additional Resources

- [Venus Protocol Documentation](https://docs.venus.io/)
- [OpenZeppelin Upgradeable Contracts](https://docs.openzeppelin.com/upgrades-plugins/1.x/)
- [BSC Documentation](https://docs.binance.org/)
- [Foundry Book](https://book.getfoundry.sh/)

---

*Last Updated: December 2024*
*Version: 1.0.0* 