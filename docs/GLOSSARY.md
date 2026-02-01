# GLOSSARY - STABLECOIN BANKING TERMS
## Complete Reference Guide

**Last Updated:** February 2026

---

## 📖 PURPOSE

This glossary explains all technical terms, acronyms, and concepts used throughout the stablecoin implementation documentation. Written for **non-technical business analysts** and executives.

---

## 🏦 CORE CONCEPTS

### Stablecoin
**Definition:** A digital token (cryptocurrency) whose value is pegged 1:1 to a traditional fiat currency.

**Example:** 1 USDC = 1 USD (always)

**How it works:** Issuer holds $1 in reserve for every 1 USDC token in circulation.

**Not to be confused with:** Bitcoin (volatile, not pegged to anything)

---

### Issuer
**Definition:** The entity that creates (mints) and destroys (burns) stablecoins.

**Example:** Circle (issues USDC), Paxos (issues USDP)

**Our bank's role:** We are NOT the issuer. We distribute stablecoins created by Circle.

**Key responsibility:** Maintaining 1:1 fiat reserves to back every token.

---

### Settlement Bank
**Definition:** The bank that holds the issuer's fiat reserves backing the stablecoin.

**Example:** If Circle has $40 billion in reserves, those dollars sit in accounts at settlement banks like BNY Mellon, Citizens Bank.

**Our bank's role:** We are a settlement bank for Circle's reserves.

---

### Distributor
**Definition:** A financial institution that provides customers access to buy, sell, and transfer stablecoins.

**Our bank's role:** We are a distributor. We give our corporate customers the ability to use USDC without dealing directly with Circle.

**Analogy:** Like a retail bank distributing cash withdrawn from the central bank.

---

### Blockchain
**Definition:** A public, decentralized digital ledger that records all transactions permanently.

**Key properties:**
- **Immutable:** Cannot delete or modify past transactions
- **Transparent:** Anyone can view all transactions
- **Decentralized:** No single company controls it

**Blockchains we use:** Ethereum (primary), Polygon (lower fees)

**Not to be confused with:** Our internal database (sub-ledger)

---

### On-Chain
**Definition:** A transaction recorded on the public blockchain.

**Examples:**
- Customer transfers USDC to external wallet → On-chain
- Bank mints USDC from Circle → On-chain

**Characteristics:**
- Publicly visible
- Immutable (cannot be reversed)
- Takes 15-30 minutes to confirm

---

### Off-Chain
**Definition:** A transaction that happens in our internal systems (not on blockchain).

**Examples:**
- Customer buys USDC (we credit their sub-ledger balance, but don't move tokens on-chain yet)
- Customer A sends to Customer B (both are our customers) → We update our database, no blockchain transaction needed

**Characteristics:**
- Private (only we see it)
- Instant
- Cheaper (no blockchain fees)

---

### Omnibus Wallet
**Definition:** A single blockchain wallet that holds stablecoins on behalf of multiple customers.

**Analogy:** Like a bank's vault holding cash for all depositors (not separate safe deposit boxes per customer).

**Example:**
- Bank omnibus wallet holds: 10 million USDC
- Customer A owns: 500K USDC (tracked in sub-ledger)
- Customer B owns: 300K USDC (tracked in sub-ledger)
- ...and so on

**Why we use it:**
- Lower operational complexity (1 wallet vs 1,000 wallets)
- Lower blockchain fees
- Easier reconciliation

**Risk:** Must maintain accurate sub-ledger to know who owns what.

---

### Sub-Ledger
**Definition:** Our internal database that tracks individual customer balances.

**Purpose:** Since we use an omnibus wallet, the blockchain only shows "Bank holds 10M USDC". The sub-ledger tells us "Customer A owns 500K, Customer B owns 300K."

**Critical requirement:** Sub-ledger MUST always match omnibus wallet balance (this is what daily reconciliation checks).

---

## 🔐 SECURITY & CUSTODY

### HSM (Hardware Security Module)
**Definition:** A physical device that stores cryptographic keys (passwords for wallets) in a tamper-proof way.

**Why we need it:** Blockchain wallets are controlled by private keys. If someone steals the key, they steal all the money. HSM protects keys.

**Features:**
- Cannot extract keys (even with physical access)
- Requires multiple authorized personnel (multi-signature)
- Logs all access attempts

---

### Multi-Signature (Multi-Sig)
**Definition:** A wallet that requires multiple people to approve transactions (like dual-signature checks).

**Example:** Our omnibus wallet requires 3 out of 5 authorized signers to approve any withdrawal.

**Why we use it:** Prevents single point of failure, reduces insider fraud risk.

---

### Hot Wallet
**Definition:** A wallet connected to the internet, used for daily operations.

**Characteristics:**
- Fast access
- Convenient
- Higher security risk (can be hacked)

**Our usage:** Hold only 5-10% of total USDC for daily customer transactions.

---

### Cold Wallet
**Definition:** A wallet stored offline (not connected to internet), used for long-term storage.

**Characteristics:**
- Very secure (cannot be hacked remotely)
- Slower to access
- Requires physical procedures to move funds

**Our usage:** Hold 90-95% of total USDC in cold storage.

---

### Wallet Sweep
**Definition:** Automated daily process of moving excess funds from hot wallet to cold wallet.

**Example:**
- Day starts: Hot wallet has 1M USDC
- Day's transactions: +500K inflow, -200K outflow
- Day ends: Hot wallet has 1.3M USDC
- Overnight: Sweep 300K to cold wallet → Hot wallet back to 1M

---

## 💼 BANKING OPERATIONS

### ATLAS
**Definition:** Our bank's core banking system (the main database for all customer accounts, transactions, balances).

**Role in stablecoin platform:**
- Tracks customer fiat balances
- Processes debits/credits when customers buy/sell USDC
- Source of truth for customer identity, account status

---

### Mint
**Definition:** Creating new stablecoin tokens (issuer only).

**Example:** Bank requests 10M USDC from Circle:
1. Bank sends $10M fiat to Circle
2. Circle creates 10M new USDC tokens on blockchain
3. Circle sends tokens to our omnibus wallet

**Not to be confused with:** "Buy" (customer buying from us - we don't mint, we allocate from existing inventory)

---

### Burn
**Definition:** Destroying stablecoin tokens (issuer only).

**Example:** Bank redeems 10M USDC with Circle:
1. Bank sends 10M USDC tokens to Circle
2. Circle destroys (burns) the tokens
3. Circle sends $10M fiat back to bank

**Not to be confused with:** "Sell" (customer selling to us - we don't burn immediately, we may reuse for next customer)

---

### Liquidity
**Definition:** Bank's inventory of USDC available for immediate customer purchases.

**Scenario 1 - Sufficient liquidity:**
- Customer wants to buy 1M USDC
- Bank has 5M USDC in omnibus wallet
- → Instant allocation (30 min total)

**Scenario 2 - Insufficient liquidity:**
- Customer wants to buy 10M USDC
- Bank has only 2M USDC
- → Must request mint from Circle (T+1 settlement)

---

### Reconciliation
**Definition:** Daily automated check to ensure all systems show the same balances.

**What we reconcile:**
1. **Sub-Ledger ↔ Omnibus Wallet:** Do customer balances add up to blockchain balance?
2. **Sub-Ledger ↔ ATLAS:** Does USDC liability match customer accounts?
3. **Our Reserves ↔ Issuer Supply:** Do our holdings match what Circle shows?

**Frequency:** Every night at 11:59 PM

**Tolerance:** <$100 difference = Minor (auto-resolve), >$100 = Investigation

---

## ⚖️ COMPLIANCE & REGULATION

### KYC (Know Your Customer)
**Definition:** Process of verifying customer identity before opening an account.

**What we collect:**
- Government-issued ID (passport, driver's license)
- Proof of address (utility bill)
- Business registration (for corporate customers)
- Ultimate beneficial owner information

**Provider:** Jumio (third-party KYC service)

**Duration:** 24-48 hours (automated) or 5-10 days (if manual review needed)

---

### AML (Anti-Money Laundering)
**Definition:** Screening customers and transactions to detect/prevent money laundering.

**Checks we perform:**
- **Sanctions screening:** Is customer on OFAC, UN, EU sanctions lists?
- **PEP (Politically Exposed Person):** Is customer a government official or family member?
- **Adverse media:** Any negative news about customer (fraud, criminal activity)?

**Providers:** Chainalysis (blockchain), Refinitiv World-Check (traditional)

**Frequency:** Initial screening + ongoing monitoring of every transaction

---

### Travel Rule (FATF Recommendation 16)
**Definition:** Regulation requiring financial institutions to share sender/recipient information for transactions above a threshold.

**Threshold:**
- US: $3,000
- EU: €1,000
- Singapore: No threshold (all transfers)

**What we share:**
- Sender name, address, account number
- Recipient name, address, account number
- Transaction amount

**Challenge:** Hard to implement for blockchain transfers (how do we contact recipient's service provider?)

---

### VASP (Virtual Asset Service Provider)
**Definition:** Regulatory term for businesses that provide crypto/stablecoin services.

**Examples:** Coinbase, Kraken, our bank (as stablecoin distributor)

**Why it matters:** VASPs must follow AML/Travel Rule regulations (unlike regular crypto wallets).

---

### MiCA (Markets in Crypto-Assets)
**Definition:** European Union's comprehensive crypto regulation framework (effective 2024-2025).

**Key requirements for stablecoin distributors:**
- Authorized as credit institution or investment firm
- Capital requirements
- Customer fund segregation
- Transaction reporting
- White paper disclosures

**Our status:** Applying for MiCA license for EU operations (Phase 2)

---

### GDPR (General Data Protection Regulation)
**Definition:** EU privacy law giving individuals control over their personal data.

**Conflict with blockchain:** GDPR says customers have "right to erasure" (delete my data). Blockchain is immutable (cannot delete).

**Our solution:**
- Store only wallet addresses on-chain (not names, emails)
- Store personal data in our database (can be deleted)
- Use encryption/pseudonymization

---

## 🔧 TECHNICAL TERMS

### Smart Contract
**Definition:** Self-executing code on the blockchain (like a vending machine - put money in, get product out automatically).

**Example:** USDC smart contract rules:
- Only Circle can mint new tokens
- Anyone can transfer tokens they own
- Cannot create tokens out of thin air

**Why we need it:** Stablecoins exist as smart contracts on Ethereum/Polygon.

---

### Gas Fees
**Definition:** Transaction fees paid to blockchain network (like stamp fee for mailing a letter).

**Factors affecting cost:**
- Network congestion (busy times = higher fees)
- Transaction complexity (simple transfer = low, complex contract = high)

**Typical costs:**
- Ethereum: $5-$50 per transaction
- Polygon: $0.01-$0.50 per transaction

**Who pays:** We pay gas fees for customer transactions (absorbed as operational cost).

---

### Block Confirmation
**Definition:** Process of a transaction being permanently recorded on the blockchain.

**How it works:**
1. Transaction submitted to network
2. Miners/validators include it in a block
3. Block is added to blockchain
4. Wait 12 more blocks for safety (to prevent reversals)

**Time:**
- Ethereum: 12-25 minutes (12 blocks × ~2 min per block)
- Polygon: 5-10 minutes (faster blocks)

**Why we wait:** Ensures transaction cannot be reversed (finality).

---

### Hardhat
**Definition:** Development tool for writing, testing, and deploying smart contracts.

**Analogy:** Like an IDE (Integrated Development Environment) for blockchain development.

**Our usage:** Phase 2+ when we need custom smart contracts (Phase 1 uses only Circle's USDC contract).

---

### Testnet
**Definition:** A separate blockchain network used for testing (uses fake money).

**Examples:** Sepolia (Ethereum testnet), Mumbai (Polygon testnet)

**Why we use it:** Test all flows without risking real money before going live.

---

### Mainnet
**Definition:** The real blockchain network (uses real money).

**Examples:** Ethereum Mainnet, Polygon Mainnet

**When we use it:** Production environment with real customer transactions.

---

## 📊 BUSINESS TERMS

### T+1 (Trade Date + 1 Business Day)
**Definition:** Settlement happens the next business day after the transaction.

**Example:** Customer sells USDC on Monday → Receives fiat on Tuesday.

**Why it happens:** Bank needs to request redemption from issuer (Circle), who processes settlements once daily.

---

### SLA (Service Level Agreement)
**Definition:** Contractual commitment on service performance metrics.

**Examples:**
- "Buy transactions complete within 30 minutes" (99.5% of time)
- "Customer support responds within 4 hours"

**Consequences of missing SLA:** Penalty fees, customer compensation.

---

### Idempotency
**Definition:** Sending the same request multiple times produces the same result (prevents duplicate transactions).

**Example:**
- Customer clicks "Buy 1M USDC" button twice by accident
- System sees same idempotency key → Ignores second request
- Only 1 purchase processed

**Implementation:** Every API call includes unique idempotency_key.

---

## 🌐 COUNTRY-SPECIFIC TERMS

### OFAC (Office of Foreign Assets Control)
**Definition:** US government agency that enforces economic sanctions.

**What we check:** Is customer/transaction involving sanctioned countries (North Korea, Iran, etc.) or individuals?

**Frequency:** Real-time screening on every transaction.

---

### FinCEN (Financial Crimes Enforcement Network)
**Definition:** US agency that collects/analyzes financial transaction data to combat money laundering.

**Our obligation:** File SARs (Suspicious Activity Reports) for unusual transactions.

---

### FCA (Financial Conduct Authority)
**Definition:** UK's financial regulator.

**Relevance:** We need FCA authorization to offer stablecoin services to UK customers (Phase 2).

---

### MAS (Monetary Authority of Singapore)
**Definition:** Singapore's central bank and financial regulator.

**Relevance:** Singapore is our Phase 1 launch market (clear regulatory framework for stablecoins).

---

## 🔄 PROCESS-SPECIFIC TERMS

### Sanctions Hit
**Definition:** When AML screening detects a match with a sanctioned entity.

**What happens:**
1. Transaction automatically blocked
2. Compliance team notified immediately
3. Manual investigation required
4. Cannot proceed until cleared or rejected

---

### Manual Review
**Definition:** Human compliance officer examines a case (not automated).

**When it happens:**
- Sanctions hit (potential match needs verification)
- High-risk customer (PEP, adverse media)
- Large transaction (>$1M)
- Unusual pattern (sudden spike in activity)

**Duration:** 1-5 business days.

---

### Break (Reconciliation)
**Definition:** When two systems show different balances (discrepancy).

**Example:**
- Sub-ledger shows: Customers own 10,000,000 USDC
- Blockchain shows: Omnibus wallet has 9,999,500 USDC
- **Break = 500 USDC missing**

**Severity:**
- <$100: Minor (auto-resolve)
- $100-$10K: Material (investigate within 24 hours)
- >$10K: Critical (emergency response)

---

## ❓ COMMON CONFUSIONS CLARIFIED

| Often Confused | Distinction |
|----------------|-------------|
| **Issuer vs Distributor** | Issuer creates tokens (Circle). Distributor sells to customers (our bank). |
| **Mint vs Buy** | Mint = Circle creates new tokens. Buy = Customer purchases from us. |
| **Burn vs Sell** | Burn = Circle destroys tokens. Sell = Customer redeems with us. |
| **On-chain vs Off-chain** | On-chain = Recorded on public blockchain. Off-chain = Our internal database. |
| **Hot wallet vs Cold wallet** | Hot = Online (fast, less secure). Cold = Offline (slow, very secure). |
| **Blockchain vs Database** | Blockchain = Public, immutable, decentralized. Database = Private, editable, centralized. |
| **Stablecoin vs Bitcoin** | Stablecoin = Pegged 1:1 to USD. Bitcoin = Volatile, no backing. |
| **USDC vs USD** | USDC = Digital token on blockchain. USD = Fiat money in bank account. |

---

## 📚 RELATED DOCUMENTS

- [Customer Journey Map](./CUSTOMER_JOURNEY_MAP.md)
- [System Architecture](./architecture/SYSTEM_CONTEXT_DIAGRAM.md)
- [Process Flows](./flows/ALL_FLOWS_INDEX.md)

---

**Document Owner:** Business Analysis Team
**Version:** 1.0
