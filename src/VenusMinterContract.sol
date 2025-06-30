// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title VenusMinterContract
 * @dev Venus Protocol minting and redeeming contract with access control
 */
contract VenusMinterContract is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    
    // ============ Constants ============
    
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    
    // ============ State Variables ============
    
    address public USDT;
    VBep20Delegator public VUSDT;
    uint256 public tokenId;
    address[] public holders;
    
    // ============ Events ============
    
    event Minted(address indexed holder, uint256 amount, uint256 poolId);
    event Redeemed(address indexed holder, uint256 amount);
    event RedeemedUnderlying(address indexed holder, uint256 amount);
    event HoldersSet(address[] holders);
    event TokenIdSet(uint256 tokenId);
    
    // ============ Errors ============
    
    error T();
    
    // ============ Modifiers ============
    
    modifier onlyMinter() {
        if (!hasRole(MINT_ROLE, msg.sender)) {
            revert AccessControlUnauthorizedAccount(msg.sender, MINT_ROLE);
        }
        _;
    }
    
    modifier onlyOperator() {
        if (!hasRole(OPERATOR_ROLE, msg.sender)) {
            revert AccessControlUnauthorizedAccount(msg.sender, OPERATOR_ROLE);
        }
        _;
    }
    
    // ============ Initialization ============
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    /**
     * @dev Initializes the contract
     * @param _usdt USDT token address
     * @param _vusdt vUSDT token address
     */
    function initialize(address _usdt, address _vusdt) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        
        USDT = _usdt;
        VUSDT = VBep20Delegator(_vusdt);
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINT_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }
    
    // ============ Minting Functions ============
    
    /**
     * @dev Mint vUSDT tokens for a specific pool
     * @param poolId Pool identifier
     * @param mintAmount Amount to mint
     */
    function mint(uint256 poolId, uint256 mintAmount) external onlyMinter {
        // Transfer USDT from caller to this contract
        IERC20(USDT).transferFrom(msg.sender, address(this), mintAmount);
        
        // Approve VUSDT to spend USDT
        IERC20(USDT).approve(address(VUSDT), mintAmount);
        
        // Mint vUSDT
        VUSDT.mint(mintAmount);
        
        emit Minted(msg.sender, mintAmount, poolId);
    }
    
    /**
     * @dev Mint vUSDT tokens for a specific holder
     * @param holder Address to mint for
     * @param mintAmount Amount to mint
     */
    function mint(address holder, uint256 mintAmount) external onlyMinter {
        // Transfer USDT from caller to this contract
        IERC20(USDT).transferFrom(msg.sender, address(this), mintAmount);
        
        // Approve VUSDT to spend USDT
        IERC20(USDT).approve(address(VUSDT), mintAmount);
        
        // Mint vUSDT
        VUSDT.mint(mintAmount);
        
        emit Minted(holder, mintAmount, 0);
    }
    
    /**
     * @dev Mint vUSDT tokens for a specific holder from a specific address
     * @param poolId Pool identifier
     * @param mintAmount Amount to mint
     * @param from Address to transfer USDT from
     */
    function mint(uint256 poolId, uint256 mintAmount, address from) external onlyMinter {
        // Transfer USDT from specified address to this contract
        IERC20(USDT).transferFrom(from, address(this), mintAmount);
        
        // Approve VUSDT to spend USDT
        IERC20(USDT).approve(address(VUSDT), mintAmount);
        
        // Mint vUSDT
        VUSDT.mint(mintAmount);
        
        emit Minted(from, mintAmount, poolId);
    }
    
    // ============ Redeeming Functions ============
    
    /**
     * @dev Redeem vUSDT tokens
     * @param redeemAmount Amount to redeem
     */
    function redeem(uint256 redeemAmount) external onlyOperator {
        // Redeem vUSDT
        VUSDT.redeem(redeemAmount);
        
        emit Redeemed(msg.sender, redeemAmount);
    }
    
    /**
     * @dev Redeem underlying USDT tokens
     * @param redeemAmount Amount of underlying to redeem
     */
    function redeemUnderlying(uint256 redeemAmount) external onlyOperator {
        // Redeem underlying USDT
        VUSDT.redeemUnderlying(redeemAmount);
        
        emit RedeemedUnderlying(msg.sender, redeemAmount);
    }
    
    // ============ Batch Operations ============
    
    /**
     * @dev Add multiple holders in batch
     * @param size Number of holders to add
     */
    function batchAddHolder(uint256 size) external onlyOperator {
        // Implementation for batch adding holders
        // This would typically involve adding addresses to the holders array
        for (uint256 i = 0; i < size; i++) {
            // Add holder logic here
        }
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Set holders array
     * @param _holders Array of holder addresses
     */
    function setHolders(address[] memory _holders) external onlyRole(DEFAULT_ADMIN_ROLE) {
        holders = _holders;
        emit HoldersSet(_holders);
    }
    
    /**
     * @dev Set token ID
     * @param _tokenId Token ID to set
     */
    function setTokenId(uint256 _tokenId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenId = _tokenId;
        emit TokenIdSet(_tokenId);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get all holders
     * @return Array of holder addresses
     */
    function getHolders() external view returns (address[] memory) {
        return holders;
    }
    
    /**
     * @dev Get holder at specific index
     * @param index Index of holder
     * @return Holder address
     */
    function getHolder(uint256 index) external view returns (address) {
        require(index < holders.length, "Index out of bounds");
        return holders[index];
    }
    
    /**
     * @dev Get number of holders
     * @return Number of holders
     */
    function getHoldersCount() external view returns (uint256) {
        return holders.length;
    }
    
    // ============ Override Functions ============
    
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
    
    function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

// ============ Interfaces ============

/**
 * @title VBep20Delegator
 * @dev Interface for Venus vUSDT token
 */
interface VBep20Delegator {
    function mint(uint256 mintAmount) external returns (uint256);
    function redeem(uint256 redeemTokens) external returns (uint256);
    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function exchangeRateStored() external view returns (uint256);
} 