# HARDHAT SETUP GUIDE
## For Blockchain Development Team

**Document Type:** Technical Setup Guide
**Audience:** Blockchain Developers, DevOps Engineers
**Last Updated:** February 2026

---

## OVERVIEW

This guide walks through setting up Hardhat for smart contract development in a bank environment.

**What is Hardhat?**
- Development environment for Ethereum smart contracts
- Comparable to: Maven (Java), Gradle (Android), npm (Node.js)
- Used for: Compiling, testing, deploying smart contracts

**NOT for:**
- Production transaction processing (that's Ethereum's job)
- Customer-facing operations
- Runtime blockchain interactions (use ethers.js/web3.js instead)

---

## PREREQUISITES

### Required Software

| Software | Version | Purpose | Install Command |
|----------|---------|---------|-----------------|
| **Node.js** | 18.x LTS | JavaScript runtime | `brew install node@18` (Mac) |
| **npm** | 9.x | Package manager | Comes with Node.js |
| **Git** | 2.x | Version control | `brew install git` |
| **VS Code** | Latest | IDE (recommended) | Download from code.visualstudio.com |

### Required Skills

- JavaScript/TypeScript proficiency
- Basic blockchain concepts (wallets, transactions, gas)
- Command line comfort
- Git version control

---

## INSTALLATION

### Step 1: Create Project Directory

```bash
# Navigate to your workspace
cd ~/projects

# Create new project
mkdir stablecoin-contracts
cd stablecoin-contracts

# Initialize npm project
npm init -y
```

**Output:**
```json
{
  "name": "stablecoin-contracts",
  "version": "1.0.0",
  "description": "Smart contracts for bank stablecoin platform",
  "main": "index.js",
  "scripts": {},
  "keywords": [],
  "author": "Bank Blockchain Team",
  "license": "UNLICENSED"
}
```

---

### Step 2: Install Hardhat

```bash
npm install --save-dev hardhat
```

**Expected Output:**
```
added 300 packages, and audited 301 packages in 45s
```

**Verify Installation:**
```bash
npx hardhat --version
```

**Output:**
```
2.19.4
```

---

### Step 3: Initialize Hardhat Project

```bash
npx hardhat
```

**Interactive Prompts:**
```
? What do you want to do? ›
❯ Create a JavaScript project
  Create a TypeScript project
  Create an empty hardhat.config.js

√ What do you want to do? · Create a TypeScript project
√ Hardhat project root: · /Users/you/projects/stablecoin-contracts
√ Do you want to add a .gitignore? (Y/n) · y
√ Do you want to install this sample project's dependencies with npm? (Y/n) · y
```

**Generated Project Structure:**
```
stablecoin-contracts/
├── contracts/           # Solidity smart contracts
│   └── Lock.sol         # Sample contract (delete later)
├── scripts/             # Deployment scripts
│   └── deploy.ts
├── test/                # Test files
│   └── Lock.ts
├── hardhat.config.ts    # Hardhat configuration
├── package.json
├── tsconfig.json
└── .gitignore
```

---

### Step 4: Install Additional Dependencies

```bash
# OpenZeppelin (secure smart contract library)
npm install --save-dev @openzeppelin/contracts

# Ethers.js (blockchain interaction library)
npm install --save-dev ethers

# Hardhat plugins
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install --save-dev @nomicfoundation/hardhat-verify
npm install --save-dev hardhat-gas-reporter

# Testing utilities
npm install --save-dev chai
npm install --save-dev @nomicfoundation/hardhat-chai-matchers
```

---

## CONFIGURATION

### hardhat.config.ts

```typescript
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import "hardhat-gas-reporter";

// Load environment variables
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    // Local Hardhat Network (for testing)
    hardhat: {
      chainId: 31337,
    },

    // Ethereum Testnet (Sepolia)
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111,
    },

    // Ethereum Mainnet (Production)
    mainnet: {
      url: process.env.MAINNET_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 1,
    },

    // Polygon (Alternative L2)
    polygon: {
      url: process.env.POLYGON_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 137,
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      sepolia: process.env.ETHERSCAN_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS === "true",
    currency: "USD",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
};

export default config;
```

---

### Environment Variables (.env)

**Create file:** `.env` (add to .gitignore!)

```bash
# RPC URLs (Blockchain node providers)
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_KEY
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_KEY
POLYGON_RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_KEY

# Private key for deployment (NEVER commit this!)
# For development only - use HSM for production
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# Etherscan API key (for contract verification)
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
POLYGONSCAN_API_KEY=YOUR_POLYGONSCAN_API_KEY

# Gas reporter
REPORT_GAS=true
COINMARKETCAP_API_KEY=YOUR_CMC_API_KEY
```

**Security Note:**
- ⚠️ `.env` file contains secrets → NEVER commit to Git
- ✅ Add to `.gitignore`: `echo ".env" >> .gitignore`
- ✅ For production: Use AWS Secrets Manager or HashiCorp Vault

---

## SAMPLE SMART CONTRACT

### Create: contracts/StablecoinVault.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title StablecoinVault
 * @notice Bank-controlled vault for managing customer USDC allocations
 * @dev Implements enterprise controls: role-based access, pausable, reentrancy protection
 */
contract StablecoinVault is AccessControl, ReentrancyGuard, Pausable {
    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    // USDC token contract
    IERC20 public immutable usdcToken;

    // Customer balances (internal tracking)
    mapping(address => uint256) private _balances;

    // Daily transfer limits (per customer)
    mapping(address => uint256) public dailyLimit;
    mapping(address => uint256) public dailySpent;
    mapping(address => uint256) public lastResetDay;

    // Events
    event Deposit(address indexed customer, uint256 amount);
    event Withdrawal(address indexed customer, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event DailyLimitSet(address indexed customer, uint256 limit);

    constructor(address _usdcToken) {
        require(_usdcToken != address(0), "Invalid USDC address");
        usdcToken = IERC20(_usdcToken);

        // Grant admin role to deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Deposit USDC into vault (bank operation)
     * @param customer Address of customer
     * @param amount Amount of USDC to credit
     */
    function deposit(address customer, uint256 amount)
        external
        onlyRole(TREASURY_ROLE)
        whenNotPaused
        nonReentrant
    {
        require(customer != address(0), "Invalid customer address");
        require(amount > 0, "Amount must be > 0");

        // Transfer USDC from msg.sender to this contract
        require(
            usdcToken.transferFrom(msg.sender, address(this), amount),
            "USDC transfer failed"
        );

        // Credit customer's internal balance
        _balances[customer] += amount;

        emit Deposit(customer, amount);
    }

    /**
     * @notice Withdraw USDC from vault (customer-initiated)
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        require(amount > 0, "Amount must be > 0");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        // Check daily limit
        _checkDailyLimit(msg.sender, amount);

        // Debit customer's balance
        _balances[msg.sender] -= amount;

        // Transfer USDC to customer
        require(
            usdcToken.transfer(msg.sender, amount),
            "USDC transfer failed"
        );

        emit Withdrawal(msg.sender, amount);
    }

    /**
     * @notice Transfer USDC between customers (internal transfer)
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function transfer(address to, uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        // Check daily limit
        _checkDailyLimit(msg.sender, amount);

        // Update balances
        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    /**
     * @notice Set daily transfer limit for customer
     * @param customer Customer address
     * @param limit Daily limit in USDC
     */
    function setDailyLimit(address customer, uint256 limit)
        external
        onlyRole(COMPLIANCE_ROLE)
    {
        dailyLimit[customer] = limit;
        emit DailyLimitSet(customer, limit);
    }

    /**
     * @notice Emergency pause (circuit breaker)
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Resume operations
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Get customer balance
     * @param customer Customer address
     * @return Balance in USDC
     */
    function balanceOf(address customer) external view returns (uint256) {
        return _balances[customer];
    }

    /**
     * @notice Internal: Check and update daily spending limit
     */
    function _checkDailyLimit(address customer, uint256 amount) private {
        uint256 currentDay = block.timestamp / 1 days;

        // Reset daily spent if new day
        if (lastResetDay[customer] < currentDay) {
            dailySpent[customer] = 0;
            lastResetDay[customer] = currentDay;
        }

        // Check limit
        uint256 limit = dailyLimit[customer];
        if (limit > 0) {
            require(
                dailySpent[customer] + amount <= limit,
                "Daily limit exceeded"
            );
            dailySpent[customer] += amount;
        }
    }
}
```

---

## COMPILING CONTRACTS

### Compile Command

```bash
npx hardhat compile
```

**Output:**
```
Compiled 15 Solidity files successfully
Artifacts written to artifacts/
Cache written to cache/
```

**Generated Files:**
```
artifacts/
└── contracts/
    └── StablecoinVault.sol/
        ├── StablecoinVault.json   # ABI + bytecode
        └── StablecoinVault.dbg.json
```

---

## TESTING

### Create: test/StablecoinVault.test.ts

```typescript
import { expect } from "chai";
import { ethers } from "hardhat";
import { StablecoinVault, MockERC20 } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("StablecoinVault", function () {
  let vault: StablecoinVault;
  let usdc: MockERC20;
  let admin: SignerWithAddress;
  let treasury: SignerWithAddress;
  let customer1: SignerWithAddress;
  let customer2: SignerWithAddress;

  beforeEach(async function () {
    [admin, treasury, customer1, customer2] = await ethers.getSigners();

    // Deploy mock USDC token
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    usdc = await MockERC20.deploy("USD Coin", "USDC", 6);
    await usdc.waitForDeployment();

    // Mint USDC to treasury
    await usdc.mint(treasury.address, ethers.parseUnits("1000000", 6));

    // Deploy vault
    const Vault = await ethers.getContractFactory("StablecoinVault");
    vault = await Vault.deploy(await usdc.getAddress());
    await vault.waitForDeployment();

    // Grant roles
    const TREASURY_ROLE = await vault.TREASURY_ROLE();
    await vault.grantRole(TREASURY_ROLE, treasury.address);

    // Approve vault to spend treasury's USDC
    await usdc.connect(treasury).approve(
      await vault.getAddress(),
      ethers.parseUnits("1000000", 6)
    );
  });

  describe("Deposit", function () {
    it("Should deposit USDC successfully", async function () {
      const amount = ethers.parseUnits("10000", 6);

      await expect(
        vault.connect(treasury).deposit(customer1.address, amount)
      )
        .to.emit(vault, "Deposit")
        .withArgs(customer1.address, amount);

      expect(await vault.balanceOf(customer1.address)).to.equal(amount);
    });

    it("Should reject deposit from non-treasury", async function () {
      await expect(
        vault.connect(customer1).deposit(customer1.address, 1000)
      ).to.be.reverted;
    });
  });

  describe("Withdrawal", function () {
    beforeEach(async function () {
      // Deposit 10K USDC to customer1
      await vault
        .connect(treasury)
        .deposit(customer1.address, ethers.parseUnits("10000", 6));
    });

    it("Should withdraw USDC successfully", async function () {
      const amount = ethers.parseUnits("5000", 6);

      await expect(vault.connect(customer1).withdraw(amount))
        .to.emit(vault, "Withdrawal")
        .withArgs(customer1.address, amount);

      expect(await vault.balanceOf(customer1.address)).to.equal(
        ethers.parseUnits("5000", 6)
      );
    });

    it("Should reject withdrawal exceeding balance", async function () {
      await expect(
        vault.connect(customer1).withdraw(ethers.parseUnits("20000", 6))
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Transfer", function () {
    beforeEach(async function () {
      await vault
        .connect(treasury)
        .deposit(customer1.address, ethers.parseUnits("10000", 6));
    });

    it("Should transfer between customers", async function () {
      const amount = ethers.parseUnits("3000", 6);

      await expect(vault.connect(customer1).transfer(customer2.address, amount))
        .to.emit(vault, "Transfer")
        .withArgs(customer1.address, customer2.address, amount);

      expect(await vault.balanceOf(customer1.address)).to.equal(
        ethers.parseUnits("7000", 6)
      );
      expect(await vault.balanceOf(customer2.address)).to.equal(amount);
    });
  });

  describe("Daily Limit", function () {
    beforeEach(async function () {
      await vault
        .connect(treasury)
        .deposit(customer1.address, ethers.parseUnits("10000", 6));

      // Set daily limit: 5000 USDC
      const COMPLIANCE_ROLE = await vault.COMPLIANCE_ROLE();
      await vault.grantRole(COMPLIANCE_ROLE, admin.address);
      await vault
        .connect(admin)
        .setDailyLimit(customer1.address, ethers.parseUnits("5000", 6));
    });

    it("Should enforce daily limit", async function () {
      // First withdrawal: 4000 USDC (OK)
      await vault.connect(customer1).withdraw(ethers.parseUnits("4000", 6));

      // Second withdrawal: 2000 USDC (exceeds limit of 5000)
      await expect(
        vault.connect(customer1).withdraw(ethers.parseUnits("2000", 6))
      ).to.be.revertedWith("Daily limit exceeded");
    });
  });

  describe("Emergency Pause", function () {
    it("Should pause and unpause", async function () {
      await vault.connect(admin).pause();

      await expect(
        vault
          .connect(treasury)
          .deposit(customer1.address, ethers.parseUnits("1000", 6))
      ).to.be.revertedWith("Pausable: paused");

      await vault.connect(admin).unpause();

      await expect(
        vault
          .connect(treasury)
          .deposit(customer1.address, ethers.parseUnits("1000", 6))
      ).to.not.be.reverted;
    });
  });
});
```

---

### Run Tests

```bash
npx hardhat test
```

**Output:**
```
  StablecoinVault
    Deposit
      ✓ Should deposit USDC successfully (125ms)
      ✓ Should reject deposit from non-treasury (45ms)
    Withdrawal
      ✓ Should withdraw USDC successfully (98ms)
      ✓ Should reject withdrawal exceeding balance (52ms)
    Transfer
      ✓ Should transfer between customers (110ms)
    Daily Limit
      ✓ Should enforce daily limit (145ms)
    Emergency Pause
      ✓ Should pause and unpause (89ms)

  7 passing (1.2s)
```

---

## DEPLOYMENT

### Local Network (Testing)

```bash
# Start local Hardhat network (separate terminal)
npx hardhat node

# Deploy to local network
npx hardhat run scripts/deploy.ts --network localhost
```

---

### Testnet (Sepolia)

**1. Get Test ETH:**
- Visit: https://sepoliafaucet.com/
- Enter your wallet address
- Receive 0.5 test ETH

**2. Deploy:**
```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

**Output:**
```
Deploying StablecoinVault...
Vault deployed to: 0x1234567890abcdef1234567890abcdef12345678
USDC address: 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
```

**3. Verify on Etherscan:**
```bash
npx hardhat verify --network sepolia 0x1234567890abcdef... 0xa0b86991c...
```

---

### Mainnet (Production) - REQUIRES APPROVAL

**Pre-Deployment Checklist:**
- [ ] External audit completed (Trail of Bits, OpenZeppelin)
- [ ] Bug bounty run (4 weeks, Immunefi)
- [ ] Formal verification passed (Certora)
- [ ] CAB (Change Advisory Board) approval obtained
- [ ] CFO + CTO + CCO sign-off
- [ ] Insurance policy active ($10M+ coverage)

**Deployment:**
```bash
# ONLY after all approvals
npx hardhat run scripts/deploy.ts --network mainnet
```

**Cost:** ~$500 in gas fees (Ethereum mainnet)

---

## GAS OPTIMIZATION

### Run Gas Reporter

```bash
REPORT_GAS=true npx hardhat test
```

**Output:**
```
·---------------------------------|---------------------------|-------------|-----------------------------·
|       Solc version: 0.8.20       ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 30000000 gas  │
··································|···························|·············|······························
|  Methods                                                                                                  │
·················|················|·············|·············|·············|···············|··············
|  Contract      ·  Method        ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
·················|················|·············|·············|·············|···············|··············
|  Vault         ·  deposit       ·      45123  ·      62341  ·      53732  ·           12  ·       2.15  │
·················|················|·············|·············|·············|···············|··············
|  Vault         ·  withdraw      ·      28456  ·      41234  ·      34845  ·            8  ·       1.39  │
·················|················|·············|·············|·············|···············|··············
```

---

## CI/CD INTEGRATION

### GitHub Actions Workflow

**Create:** `.github/workflows/test.yml`

```yaml
name: Hardhat Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Install dependencies
        run: npm ci

      - name: Compile contracts
        run: npx hardhat compile

      - name: Run tests
        run: npx hardhat test

      - name: Run coverage
        run: npx hardhat coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
```

---

## SECURITY BEST PRACTICES

### Development

- ✅ Never commit private keys (use `.env`, add to `.gitignore`)
- ✅ Use OpenZeppelin libraries (battle-tested)
- ✅ Enable Solidity optimizer (reduce gas costs)
- ✅ Write comprehensive tests (aim for >90% coverage)
- ✅ Use static analysis (Slither, Mythril)

### Deployment

- ✅ Test on testnet first (Sepolia, Goerli)
- ✅ Get external audit before mainnet
- ✅ Use multi-sig for admin functions (Gnosis Safe)
- ✅ Implement emergency pause (circuit breaker)
- ✅ Set up monitoring (Tenderly, OpenZeppelin Defender)

---

## TROUBLESHOOTING

### Common Issues

**Issue:** `Error: Cannot find module 'hardhat'`
**Solution:** `npm install --save-dev hardhat`

**Issue:** `Error: Network 'sepolia' not found`
**Solution:** Check `hardhat.config.ts` has sepolia network defined + `.env` has RPC URL

**Issue:** `Error: Insufficient funds for gas`
**Solution:** Get test ETH from faucet (sepoliafaucet.com)

**Issue:** `TypeError: Cannot read property 'JsonRpcProvider'`
**Solution:** `npm install --save-dev ethers@^6.0.0`

---

## NEXT STEPS

- **Smart Contract Design:** See `SMART_CONTRACT_SPECIFICATIONS.md`
- **Deployment Procedures:** See `DEPLOYMENT_PROCEDURES.md`
- **Security Controls:** See `SECURITY_CONTROLS.md`

---

**Document Owner:** Blockchain Development Team
**Review Frequency:** Quarterly or upon Hardhat upgrades
**Version:** 1.0
