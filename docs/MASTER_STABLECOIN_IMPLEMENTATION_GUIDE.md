# ENTERPRISE STABLECOIN IMPLEMENTATION GUIDE
## For Settlement Bank & Distributor Role

**Document Classification:** Internal - Strategic
**Regulatory Scope:** Multi-jurisdictional (US, EU, UK, India, Singapore, UAE)
**Target Audience:** Executive Leadership, Business Analysis, Technology, Risk & Compliance
**Prepared by:** Enterprise Transformation Office
**Version:** 1.0
**Date:** February 2026

---

## DOCUMENT PURPOSE

This guide provides a complete, regulator-ready framework for implementing a bank-grade stablecoin distribution platform. It assumes **zero prior blockchain knowledge** and is written for traditional banking professionals.

**Critical Context:**
- **Bank's Role:** Settlement Bank → Distributor (NOT Issuer)
- **Core Banking System:** ATLAS
- **Blockchain Framework:** Hardhat (Ethereum-based)
- **Regulatory Posture:** Conservative, compliance-first
- **Target:** Enterprise-grade, audit-ready system

---

## TABLE OF CONTENTS

1. [Executive Overview (for CXOs)](#section-1)
2. [Operating & Business Model](#section-2)
3. [Complete Functional Scope](#section-3)
4. [Phase-1 Scope vs Out-of-Scope](#section-4)
5. [Buy / Sell Flow Diagrams](#section-5)
6. [System Context & Architecture](#section-6)
7. [Hardhat & Smart Contract Design](#section-7)
8. [Integration Contracts](#section-8)
9. [Accounting & Financial Reporting](#section-9)
10. [Tax & Withholding](#section-10)
11. [Regulatory Comparison Table](#section-11)
12. [GDPR & Data Localization](#section-12)
13. [Reconciliation & Controls](#section-13)
14. [Risk & Governance](#section-14)
15. [Final Deliverables](#section-15)

---

<a name="section-1"></a>
# SECTION 1 — EXECUTIVE OVERVIEW (FOR CXOs)

## 1.1 What is a Stablecoin? (Banking Terms)

### Simple Definition
A **stablecoin** is a digital representation of fiat currency (e.g., USD, EUR, GBP) that exists on a blockchain network. Think of it as:

> **"A tokenized bank deposit that can be transferred 24/7/365 across borders with cryptographic security, settling in minutes instead of days."**

### Banking Translation

| Traditional Banking Term | Stablecoin Equivalent |
|--------------------------|------------------------|
| Wire Transfer | Token Transfer |
| Nostro/Vostro Account | Blockchain Wallet |
| SWIFT Message | Smart Contract Transaction |
| Central Ledger | Distributed Ledger (Blockchain) |
| Account Balance | Token Balance |
| Settlement | On-chain Confirmation |
| Ledger Entry | Blockchain Transaction |

### Key Characteristics

1. **Peg to Fiat:** 1 Stablecoin = 1 Unit of Fiat (e.g., 1 USDC = 1 USD)
2. **Issued Against Reserves:** Each token is backed by equivalent fiat held in custody
3. **Programmable:** Can embed compliance rules directly into the transfer mechanism
4. **Always-On:** Operates 24/7, including weekends and holidays
5. **Near-Instant Settlement:** Transactions confirm in 2-15 minutes vs. 1-3 days for traditional rails

### NOT the Same As

| What It Is NOT | Why This Matters |
|----------------|------------------|
| Cryptocurrency (like Bitcoin) | Stablecoins don't fluctuate in value; they're pegged 1:1 to fiat |
| E-Money (like PayPal balance) | Stablecoins exist on public/permissioned blockchains, not private databases |
| CBDC (Central Bank Digital Currency) | Stablecoins are issued by private entities, not central banks |
| Securities | Properly structured stablecoins are payment instruments, not investment products |

---

## 1.2 Why Banks Use Stablecoins

### Strategic Business Drivers

#### 1. **Cross-Border Payments Transformation**
- **Current Problem:** SWIFT payments take 1-5 days, cost $25-50, involve 3-6 intermediaries
- **Stablecoin Solution:** Settlement in <15 minutes, cost <$1, direct peer-to-peer
- **Business Impact:** Competitive advantage in trade finance, remittances, treasury operations

#### 2. **24/7 Liquidity Management**
- **Current Problem:** FX markets closed weekends; liquidity trapped in nostro accounts
- **Stablecoin Solution:** Move liquidity between jurisdictions instantly, any time
- **Business Impact:** Reduced idle capital, optimized nostro funding, improved treasury yields

#### 3. **Programmable Compliance**
- **Current Problem:** Manual AML checks, post-transaction monitoring, reactive controls
- **Stablecoin Solution:** Embed KYC/AML rules into smart contracts; auto-reject non-compliant transfers
- **Business Impact:** Reduced compliance costs, real-time risk mitigation, audit trail by design

#### 4. **New Revenue Streams**
- Custody fees (asset safeguarding)
- Transaction fees (buy/sell/transfer)
- FX conversion spreads
- Liquidity provision services
- API access for corporate clients
- White-label distribution for other FIs

#### 5. **Regulatory Preparedness**
- Positions bank ahead of CBDC rollout
- Builds blockchain competency for future digitized assets
- Demonstrates innovation to regulators and shareholders

---

## 1.3 How This Differs from Crypto Exchanges

### Bank vs. Exchange: Critical Distinctions

| Dimension | Traditional Bank (Us) | Crypto Exchange |
|-----------|----------------------|-----------------|
| **Regulatory Status** | Licensed bank (OCC, ECB, MAS, RBI) | Money Services Business or unregulated |
| **Capital Requirements** | Tier-1 capital ratios, BASEL III | Minimal or none |
| **Insurance** | FDIC/DGS insured deposits | No deposit insurance |
| **Custody Model** | Qualified custodian, institutional-grade | Self-custody or opaque arrangements |
| **KYC/AML Standards** | Bank-grade KYC, EDD for high-risk | Variable; often minimal |
| **Audit & Reporting** | Quarterly external audits, SOC2, ISO27001 | Often unaudited or self-reported |
| **Customer Protection** | Ombudsman, dispute resolution, legal recourse | Limited to no consumer protection |
| **Operating Hours** | Business hours + batch processing | 24/7 but with operational risk |
| **Risk Management** | Enterprise risk framework, stress-tested | Often inadequate; history of hacks |
| **Target Customers** | Institutional, corporate treasury, HNW retail | Retail speculators, traders |

### Why This Matters to Regulators

Regulators expect banks to:
- **NOT operate like crypto exchanges** (avoid speculation, gambling behavior)
- **Maintain banking standards** (KYC, AML, sanctions screening, transaction monitoring)
- **Segregate activities** (payments use case, not trading or investment)
- **Demonstrate control** (governance, risk management, audit trails)

---

## 1.4 Bank's Role: Settlement Bank → Distributor

### Ecosystem Roles (defined)

#### **1. Stablecoin Issuer**
- **Responsibility:** Creates and destroys stablecoins; holds fiat reserves
- **Examples:** Circle (USDC), Paxos (USDP), Tether (USDT)
- **Regulatory Requirements:** Money Transmitter License, Trust Charter, or E-Money License
- **Assets Under Management:** Billions in T-bills, money market funds, bank deposits
- **Our Bank:** **NOT playing this role in Phase-1**

#### **2. Settlement Bank (Reserve Custodian)**
- **Responsibility:** Holds the fiat reserves backing the stablecoin
- **Examples:** BNY Mellon, State Street, JPMorgan
- **Regulatory Requirements:** Banking license, custody authorization
- **Our Bank:** **YES - This is our primary role**

#### **3. Distributor**
- **Responsibility:** Provides customer access to buy/sell/transfer stablecoins
- **Examples:** Coinbase Institutional, Anchorage Digital Bank
- **Regulatory Requirements:** Banking license or MSB registration, AML program
- **Our Bank:** **YES - This is our customer-facing role**

#### **4. Custodian (Wallet Provider)**
- **Responsibility:** Safeguards customers' private keys; manages hot/cold wallets
- **Examples:** Fireblocks, BitGo, Copper
- **Our Bank:** **Hybrid - We custody on behalf of customers but may use sub-custodian for cold storage**

### Our Bank's Specific Scope

```
┌─────────────────┐         ┌──────────────┐         ┌─────────────────┐
│  USDC ISSUER    │────────▶│   OUR BANK   │────────▶│   CUSTOMERS     │
│  (Circle)       │         │              │         │ - Retail        │
│                 │         │ ROLES:       │         │ - Corporate     │
│ - Mints USDC    │         │ 1. Settlement│         │ - FI Partners   │
│ - Burns USDC    │         │    Bank      │         │                 │
│ - Holds reserves│         │ 2. Distributor│        │ They can:       │
│   in our bank   │         │ 3. Custodian │         │ - Buy USDC      │
└─────────────────┘         └──────────────┘         │ - Sell USDC     │
                                                      │ - Transfer USDC │
                                                      │ - Hold USDC     │
                                                      └─────────────────┘
```

#### **Settlement Bank Responsibilities:**
- Hold Circle's (Issuer's) USD reserves in segregated accounts
- Process mint/burn instructions from Issuer
- Provide daily attestation of reserve balances
- Ensure 1:1 backing at all times
- **NOT customer-facing for this function**

#### **Distributor Responsibilities:**
- Onboard customers (KYC/AML)
- Facilitate buy/sell transactions
- Provide custody wallets
- Handle customer support
- Report suspicious activities
- Maintain transaction records

---

## 1.5 Business Value, Risks, and Regulatory Posture

### Business Value Proposition

#### Quantified Benefits (Conservative Estimates)

| Benefit Category | Traditional Model | Stablecoin Model | Impact |
|------------------|-------------------|------------------|--------|
| **Cross-border settlement time** | 2-5 days | 15 minutes | 99% reduction |
| **Transaction cost (avg)** | $35-50 | $0.50-2 | 95% reduction |
| **Operating hours** | 8-12 hrs/day | 24/7/365 | 3x availability |
| **Nostro capital tied up** | $50-100M | $10-20M | 60-80% reduction |
| **FX conversion time** | T+2 | Instant | Real-time |
| **Compliance false positives** | 95%+ | 60-70% | 25-35% improvement |

#### Revenue Model (Annual, Scaled)

| Revenue Stream | Year 1 | Year 3 | Year 5 |
|----------------|--------|--------|--------|
| Custody fees (0.1-0.5% AUM) | $2M | $15M | $50M |
| Transaction fees ($0.50-2 per) | $5M | $30M | $100M |
| FX spreads (0.25-0.5%) | $3M | $20M | $75M |
| API/platform fees | $1M | $5M | $20M |
| **Total** | **$11M** | **$70M** | **$245M** |

*Assumptions: $2B AUM Year-1, $15B Year-3, $50B Year-5; 10M transactions/year scaling to 100M*

---

### Risk Assessment

#### Risk Matrix

| Risk Category | Likelihood | Impact | Mitigation Priority | Mitigation Strategy |
|---------------|------------|--------|---------------------|---------------------|
| **Regulatory Change** | High | Critical | P0 | Modular architecture; jurisdiction-specific controls; regular regulator dialogue |
| **Smart Contract Vulnerability** | Medium | Critical | P0 | Formal verification; multi-sig; time-locks; insurance; third-party audits |
| **Liquidity Crunch** | Low | High | P1 | Maintain 120% liquidity buffer; credit lines; issuer guarantees |
| **Operational Failure** | Medium | High | P1 | 99.9% SLA; disaster recovery; backup custody provider |
| **Reputational Risk** | Medium | Critical | P0 | Transparency reports; regular audits; conservative onboarding |
| **Cyber Attack** | Medium | Critical | P0 | SOC2 Type 2; penetration testing; cold storage; MFA; HSM |
| **AML/Sanctions Breach** | Low | Critical | P0 | Real-time screening; blockchain analytics; suspicious activity monitoring |
| **Market Risk (FX)** | Low | Medium | P2 | Instant settlement minimizes exposure; back-to-back hedging |

---

### Regulatory Posture: Conservative & Transparent

#### Guiding Principles

1. **Regulator as Partner, Not Adversary**
   - Proactive engagement with central banks and regulators
   - Seek no-objection letters before launch
   - Monthly reporting even if not required

2. **Compliance by Design**
   - Build controls into architecture, not bolted-on
   - Default-deny approach (whitelist only)
   - Immutable audit trails

3. **Customer Protection First**
   - Clear disclosures (stablecoins are NOT deposits)
   - Robust dispute resolution
   - Insurance coverage where available

4. **Transparency**
   - Publish reserve attestations
   - Annual third-party audits
   - Open API documentation

5. **Responsible Innovation**
   - Start with institutional/corporate customers
   - Gradual rollout across jurisdictions
   - Pilot programs with regulator oversight

---

### Key Regulatory Concerns & Our Responses

| Regulator Concern | Our Response |
|-------------------|--------------|
| **"Stablecoins are not truly backed 1:1"** | Daily attestation by Big-4 auditor; real-time reserve dashboard; held in our own bank |
| **"Used for money laundering"** | Bank-grade KYC/AML; transaction monitoring; blockchain analytics; SAR filings |
| **"Systemic risk to financial system"** | Limited to payment use cases; no lending/leverage; stress-tested liquidity |
| **"Consumer confusion with deposits"** | Clear T&Cs; separate from deposit accounts; educational materials |
| **"Technology risk / smart contract bugs"** | Formal verification; audited code; insurance; emergency pause mechanism |
| **"Lack of consumer protection"** | Ombudsman access; dispute resolution; terms matching traditional banking products |

---

### Success Criteria (12-Month Horizon)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Regulatory approvals obtained | 3+ jurisdictions | Signed no-objection letters |
| Zero AML/sanctions breaches | 100% | Internal audit + regulator exam |
| Customer onboarding | 50 corporate clients | CRM data |
| Transaction volume | $500M | Blockchain + ATLAS reconciliation |
| System uptime | 99.9% | Monitoring logs |
| Audit findings | Zero critical | External audit report |
| Customer satisfaction | >85% NPS | Quarterly survey |
| Profitability | Break-even by Month 18 | P&L |

---

<a name="section-2"></a>
# SECTION 2 — OPERATING & BUSINESS MODEL

## 2.1 Stablecoin Ecosystem Roles (Detailed)

### Role Definitions & Responsibilities

#### **ISSUER (e.g., Circle, Paxos)**

**Core Function:** Creates and destroys stablecoins against fiat reserves

**Responsibilities:**
- Mint new stablecoins when customers deposit fiat
- Burn stablecoins when customers redeem for fiat
- Maintain 1:1 fiat reserve backing (or better)
- Publish regular attestation reports
- Manage reserve asset portfolio (T-bills, overnight repos, bank deposits)
- Deploy and upgrade smart contracts
- Set transfer rules (whitelist, blacklist, pause)

**Liabilities:**
- Must redeem stablecoins for fiat on demand
- Responsible for reserve adequacy
- Subject to issuer-specific regulations (Money Transmitter, Trust Charter, E-Money License)
- Must maintain reserves in bankruptcy-remote vehicles
- Liable for smart contract bugs or exploits

**Regulatory Exposure:**
- US: FinCEN (MSB), State Money Transmitter Licenses, potential OCC charter
- EU: E-Money Directive, MiCA (Markets in Crypto-Assets Regulation)
- UK: FCA authorization as E-Money Institution
- Singapore: MAS Payment Services Act
- Other: Varies; often unregulated or grey area

**Why We Are NOT the Issuer:**
- Issuing requires different regulatory permissions (not all banks have E-Money licenses)
- High capital lock-up in reserve assets
- Direct liability for stablecoin redemptions
- Complex reserve management
- Smart contract development and security responsibility
- Focus on core banking vs. crypto infrastructure

---

#### **SETTLEMENT BANK (Reserve Custodian) — OUR PRIMARY ROLE**

**Core Function:** Holds the issuer's fiat reserves and processes mint/burn settlements

**Responsibilities:**
- Open segregated, bankruptcy-remote accounts for issuer
- Hold cash reserves backing outstanding stablecoins
- Process wire transfers for mints (fiat in → issuer credits stablecoins)
- Process wire transfers for burns (stablecoins redeemed → fiat out)
- Provide daily balance attestation to issuer
- Maintain sufficient liquidity for redemption requests
- Reconcile issuer instructions vs. on-chain supply
- Report large transactions per Bank Secrecy Act / local AML rules

**Liabilities:**
- Safeguarding customer (issuer's) funds per custody regulations
- Operational risk if funds misapplied
- Reputational risk if issuer fails (even if not legally liable)
- Must maintain segregation of issuer reserves from bank's own capital

**Regulatory Exposure:**
- Subject to banking supervision (OCC, Fed, ECB, PRA, MAS, RBI, etc.)
- Custody regulations (e.g., ICA 1940 in US, MiFID in EU)
- KYC/AML on issuer (as our customer)
- Transaction monitoring for issuer's activity
- No direct regulatory burden for stablecoin design (that's on issuer)

**Why This Is Attractive for Us:**
- Leverages existing banking license and custody infrastructure
- Low regulatory incremental burden (issuer carries most)
- Deposit-like liabilities (issuer's reserves sit in our accounts)
- Stable fee income (custody fees, wire fees)
- Lower technology risk (we don't deploy smart contracts)

**Key Controls:**
- Daily reconciliation: Issuer's fiat balance = On-chain stablecoin supply
- Dual-authorization for large withdrawals
- Ring-fenced accounts (not commingled with bank's operating funds)
- Monthly audits by internal audit + external auditor spot checks

---

#### **DISTRIBUTOR — OUR CUSTOMER-FACING ROLE**

**Core Function:** Provides customer access to buy, sell, hold, and transfer stablecoins

**Responsibilities:**
- **Customer Onboarding:**
  - KYC/AML per banking standards
  - CIP (Customer Identification Program)
  - EDD (Enhanced Due Diligence) for high-risk customers
  - Ongoing monitoring and periodic re-certification

- **Transaction Facilitation:**
  - Accept fiat deposits to buy stablecoins
  - Purchase stablecoins from issuer or secondary market
  - Credit customer wallets
  - Process sell orders (stablecoins → fiat)
  - Enable peer-to-peer transfers (our customers to external wallets, if permitted)

- **Custody:**
  - Safeguard customer private keys
  - Maintain hot/warm/cold wallet architecture
  - Provide wallet statements and reporting
  - Handle wallet recovery requests

- **Compliance:**
  - Transaction monitoring (unusual patterns, structuring)
  - Sanctions screening (OFAC, UN, EU, etc.)
  - Travel Rule compliance (share sender/receiver info for transfers >$1,000)
  - SAR (Suspicious Activity Report) filings
  - CTR (Currency Transaction Report) for large cash equivalents

- **Customer Service:**
  - Support tickets (login issues, transaction failures)
  - Dispute resolution (unauthorized transfers, errors)
  - Educational content (how stablecoins work, risks)
  - Account statements (monthly)

**Liabilities:**
- Responsible for customer losses due to our operational failures
- AML violations if inadequate monitoring
- Must compensate customers for unauthorized transactions (if negligence proven)
- Reputational risk if customers use stablecoins for illicit activity

**Regulatory Exposure:**
- **Highest exposure** of the three roles
- Banking regulations (since we're a bank)
- Payment Services Directive (EU)
- Money transmission rules
- Consumer protection laws
- Data privacy (GDPR, etc.)

**Why This Is Core to Our Strategy:**
- Direct customer relationships (upsell other banking services)
- Transaction fee revenue
- Differentiation from traditional correspondent banking
- Data insights (payment flows, customer behavior)

**Key Controls:**
- Automated AML transaction monitoring (Actimize, SAS, etc.)
- Real-time sanctions screening
- Maker-checker for large transfers
- Wallet access controls (MFA, biometrics)
- Insurance (cyber, custody, E&O)

---

#### **CUSTODIAN (Wallet Service Provider)**

**Core Function:** Safeguards private keys and manages blockchain wallet infrastructure

**Responsibilities:**
- Generate and store private keys securely
- Sign blockchain transactions on behalf of customers
- Maintain hot wallets (online, for daily transactions)
- Maintain cold wallets (offline, for bulk storage)
- Implement multi-signature controls
- Provide HSM (Hardware Security Module) integration
- Disaster recovery and key backup
- Wallet infrastructure monitoring (balance checks, gas fees, nonce management)

**Liabilities:**
- Loss of funds if keys compromised
- Operational failures (e.g., insufficient gas, nonce errors)
- Must maintain insurance (custody insurance, crime insurance)

**Regulatory Exposure:**
- Qualified Custodian rules (SEC, OCC, state banking depts)
- SOC 2 Type 2 audit requirements
- Annual penetration testing
- Incident reporting requirements

**Our Approach:**
- **Hybrid Model:**
  - **Hot Wallet (5-10% of AUM):** Managed in-house for immediate customer transactions
  - **Cold Wallet (90-95% of AUM):** Outsourced to qualified third-party custodian (e.g., Fireblocks, BitGo, Anchorage)
  - **Warm Wallet (Optional):** Semi-offline, for medium-sized transactions

**Why Hybrid:**
- **In-house hot wallet:** Low latency, full control, cost-effective for high-frequency small transactions
- **Third-party cold storage:** Best-in-class security, insurance coverage ($100M+ policies), regulatory credibility
- **Risk distribution:** No single point of failure

**Key Controls:**
- Multi-signature wallets (3-of-5 for cold storage)
- Daily wallet sweeps (hot → cold)
- Geographically distributed key shards
- Time-locked transactions for large amounts
- Intrusion detection and 24/7 SOC monitoring

---

### Ecosystem Interaction Flow

```
CUSTOMER                  OUR BANK                    ISSUER               BLOCKCHAIN
   │                          │                          │                       │
   │──(1) "Buy $10K USDC"───▶│                          │                       │
   │                          │                          │                       │
   │                          │──(2) Wire $10K USD────▶│                       │
   │                          │    (Settlement Bank role)│                       │
   │                          │                          │                       │
   │                          │                          │──(3) Mint 10K USDC──▶│
   │                          │                          │     (Issuer role)     │
   │                          │                          │                       │
   │                          │◀─(4) Transfer 10K USDC──│◀─────────────────────│
   │                          │    (to our omnibus wallet)                       │
   │                          │                          │                       │
   │◀─(5) Credit wallet─────│                          │                       │
   │     (Distributor role)   │                          │                       │
   │                          │                          │                       │
   │     [Now customer can transfer to others on-chain]  │                       │
   │                          │                          │                       │
```

---

## 2.2 Where This Bank Fits

### Our Unique Position

| Dimension | Our Bank | Pure Crypto Exchange | Traditional Correspondent Bank |
|-----------|----------|----------------------|-------------------------------|
| **Licenses** | Full banking charter + payments | MSB or none | Full banking charter |
| **Services** | Deposits + Stablecoins | Stablecoins only | Deposits + Wire/SWIFT |
| **Custody** | Qualified custodian | Self-custody or unregulated | N/A (fiat only) |
| **Settlement Speed** | 15 minutes (stablecoin) | 15 minutes | 2-5 days (wire) |
| **Operating Hours** | 24/7 (stablecoin), business hours (fiat) | 24/7 | Business hours |
| **Customer Protection** | Banking regulations + consumer protection | Limited | Banking regulations |
| **Innovation** | High (blockchain-enabled) | High (but risky) | Low (legacy rails) |
| **Regulatory Credibility** | Very High | Low to Medium | Very High |

### Competitive Advantages

1. **Trusted Brand:** Established banking relationship; not a "crypto startup"
2. **Integrated Platform:** Customers can hold fiat + stablecoins in one relationship
3. **Seamless FX:** Convert USD → USDC → EUR → EEUR (Euro stablecoin) in minutes
4. **Corporate Treasury Tools:** API integration, bulk payments, reporting dashboards
5. **Regulatory Certainty:** Customers prefer regulated banks over exchanges for large amounts
6. **Credit Facilities:** Can offer credit lines collateralized by stablecoin holdings (future phase)

---

## 2.3 Responsibilities vs. Liabilities

### Responsibility Matrix

| Activity | Bank Responsibility | Customer Responsibility | Issuer Responsibility |
|----------|---------------------|--------------------------|------------------------|
| **KYC/AML on customer** | ✅ Bank (full) | Provide accurate info | ❌ Not involved |
| **Custody of customer funds** | ✅ Bank (if using our wallet) | Opt for self-custody if prefer | ❌ Not custodian |
| **Stablecoin redemption** | ❌ Not directly | Request redemption from us | ✅ Issuer (ultimate obligor) |
| **Smart contract security** | ❌ Not our code | Accept risk | ✅ Issuer (deployed contract) |
| **Transaction validity** | ✅ Bank (screen for fraud/AML) | Initiate legitimate transactions | ❌ Not monitoring |
| **Reserve backing** | ✅ Bank (hold reserves safely) | N/A | ✅ Issuer (maintain 1:1 backing) |
| **Tax reporting** | ✅ Bank (1099, FATCA, CRS) | Pay taxes | ❌ Not tax collector |
| **Data privacy** | ✅ Bank (GDPR compliance) | Grant consent | ❌ Not data controller |
| **Dispute resolution** | ✅ Bank (for our operational errors) | File disputes promptly | ✅ Issuer (for redemption failures) |

---

### Liability Framework

#### **When We Are Liable**

| Scenario | Liability | Mitigation |
|----------|-----------|------------|
| **Key Compromise (Hot Wallet)** | 100% liable for losses | Insurance, HSM, multi-sig, daily sweeps to cold storage |
| **Operational Error (wrong address)** | Liable if our system error | Maker-checker, whitelist-only transfers, address validation |
| **AML Failure (didn't detect illicit)** | Regulatory fines + reputational | Real-time monitoring, blockchain analytics, SAR filings |
| **Unauthorized Access (hacked account)** | Liable unless customer negligence | MFA, anomaly detection, transaction limits |
| **Mis-selling (customer didn't understand risk)** | Potential liability | Clear disclosures, suitability assessments, recorded consent |

#### **When We Are NOT Liable**

| Scenario | Reasoning | Disclosure to Customer |
|----------|-----------|------------------------|
| **Issuer Insolvency** | We're distributor, not guarantor | "Stablecoins are liabilities of Issuer, not Bank" |
| **Smart Contract Bug (issuer's contract)** | Not our code | "Smart contract risks exist; Bank does not control code" |
| **Blockchain Network Failure** | Infrastructure risk | "Transactions may delay if network congested" |
| **Customer Lost Private Keys (if self-custody)** | Customer opted out of our custody | "Self-custody = you are responsible for keys" |
| **Market Value Fluctuation (de-peg)** | Stablecoins may temporarily trade off-peg | "Not a deposit; not FDIC insured; value may fluctuate" |
| **Regulatory Ban** | Force majeure | "Service may be suspended if regulations change" |

---

### Legal Structuring

#### **Recommended T&C Provisions**

1. **Not a Deposit:**
   > "Stablecoins held in your wallet are NOT deposits, are NOT insured by FDIC/FSCS/equivalent, and are NOT guaranteed by [Bank Name]."

2. **Issuer as Obligor:**
   > "Your stablecoins are liabilities of [Issuer Name]. Redemption is subject to Issuer's terms. Bank acts as distributor only."

3. **Technology Risks:**
   > "Blockchain technology is novel and carries risks including smart contract bugs, network delays, and potential loss of access."

4. **Regulatory Risk:**
   > "Stablecoin regulations are evolving. Service may be modified or discontinued based on regulatory changes."

5. **No Investment Advice:**
   > "Bank does not provide advice on stablecoin investment. This is a payment product, not an investment."

6. **AML Cooperation:**
   > "You agree to cooperate with KYC/AML requests. Bank may freeze or report transactions per legal requirements."

---

## 2.4 Customer Types

### Target Customer Segments

#### **1. Institutional / Corporate Treasury**

**Profile:**
- Large multinationals with cross-border payment needs
- Import/export businesses
- E-commerce platforms
- Payroll service providers

**Use Cases:**
- Supplier payments (e.g., pay factories in Bangladesh using USDC → convert to local currency)
- Intra-company transfers (HQ in US → subsidiary in Singapore, 24/7)
- FX hedging (lock in rates using stablecoin liquidity)
- Just-in-time funding (reduce idle nostro balances)

**Volume:** High ($1M+ per month)
**Revenue:** Medium per transaction, high in aggregate
**Risk:** Low (sophisticated customers, strong AML controls)
**Priority:** **PRIMARY TARGET**

**Onboarding Requirements:**
- Corporate KYC (LEI, ownership structure, beneficial owners)
- Board resolution authorizing stablecoin use
- Designated authorized signers
- Source of funds documentation
- API integration (optional)

---

#### **2. Small-Medium Enterprises (SMEs)**

**Profile:**
- Freelancers, agencies, SaaS companies
- Cross-border e-commerce
- Remittance-dependent businesses

**Use Cases:**
- Receiving international payments (avoid high wire fees)
- Paying contractors in other countries
- Managing cash flow across currencies

**Volume:** Medium ($10K-$500K per month)
**Revenue:** High per transaction (less price-sensitive)
**Risk:** Medium (less sophisticated AML, some high-risk industries)
**Priority:** **SECONDARY TARGET (Phase 2)**

**Onboarding Requirements:**
- Business registration documents
- Director KYC
- Business plan / website review
- Transaction monitoring (more intensive than corporate)

---

#### **3. High Net-Worth Individuals (HNW Retail)**

**Profile:**
- Ultra-HNW individuals (>$10M AUM)
- Family offices
- Expats with multi-currency needs

**Use Cases:**
- Cross-border real estate transactions
- Family remittances
- Diversification (small % of portfolio in stablecoins)
- Travel / living abroad expenses

**Volume:** Low to Medium ($50K-$1M per month)
**Revenue:** High per transaction
**Risk:** Medium (PEP screening required, source of wealth)
**Priority:** **SECONDARY TARGET (Phase 2)**

**Onboarding Requirements:**
- Individual KYC (passport, utility bill, tax residency)
- Source of wealth declaration
- PEP screening
- Risk tolerance assessment

---

#### **4. Financial Institution Partners**

**Profile:**
- Smaller banks without blockchain capability
- Payment processors
- Fintech partners (white-label)

**Use Cases:**
- White-label stablecoin services for their customers
- Correspondent banking alternative
- Liquidity management

**Volume:** Very High ($10M+ per month)
**Revenue:** Low per transaction, very high in aggregate
**Risk:** Low (institutional counterparties)
**Priority:** **STRATEGIC (Phase 2-3)**

**Onboarding Requirements:**
- Institutional KYC
- Regulatory licenses (verify partner is licensed)
- Legal agreement (liability, data sharing, branding)
- Technical integration (API, reconciliation)

---

### Customer Segmentation: Phase Approach

| Phase | Target Segment | Rationale |
|-------|----------------|-----------|
| **Phase 1 (MVP)** | Corporate Treasury (top 20 clients) | High volume, low risk, strong relationships, regulatory credibility |
| **Phase 2** | SMEs + HNW Individuals | Expand revenue base, diversify risk, test scalability |
| **Phase 3** | FI Partners + Mass Retail | White-label, full-scale platform, maximize network effects |

---

## 2.5 Supported Currencies and Corridors

### Initial Currency Pairs (Phase 1)

| Stablecoin | Pegged To | Issuer | Reserve Bank (Us) | Blockchain | Liquidity | Priority |
|------------|-----------|--------|-------------------|-----------|-----------|----------|
| **USDC** | USD | Circle | BNY Mellon / Our Bank | Ethereum, Solana, Polygon | Very High | **P0 (Launch)** |
| **EURC** | EUR | Circle | European bank partner | Ethereum | Medium | **P0 (Launch)** |
| **GBPT** | GBP | Paxos or Circle | UK bank partner | Ethereum | Low | **P1 (6 months)** |
| **XSGD** | SGD | Xfers / StraitsX | DBS / Our Bank | Ethereum, Zilliqa | Low | **P2 (12 months)** |

*Note: Selection based on issuer regulatory status, reserve transparency, and customer demand.*

---

### Target Payment Corridors

#### **Priority Corridors (Phase 1)**

| Corridor | Use Case | Volume (Est.) | Regulatory Considerations |
|----------|----------|---------------|---------------------------|
| **US ↔ EU** | Corporate payments, treasury management | Very High | MiCA compliance (EU), FinCEN (US) |
| **US ↔ UK** | Trade finance, FX hedging | High | FCA authorization, OFAC |
| **US ↔ Singapore** | Asian treasury hub, fintech partnerships | High | MAS approval, travel rule |
| **EU ↔ UK** | Post-Brexit trade | Medium | GDPR, data localization |

#### **Expansion Corridors (Phase 2-3)**

| Corridor | Use Case | Regulatory Challenges |
|----------|----------|----------------------|
| **US ↔ India** | Remittances, IT services payments | RBI restrictions on crypto (grey area for stablecoins) |
| **US ↔ UAE** | Trade finance, construction | DFSA (Dubai), ADGM (Abu Dhabi) licensing |
| **EU ↔ India** | Pharma, automotive supply chain | Data localization, rupee convertibility |
| **Singapore ↔ India** | IT/BPO payments | Regulatory uncertainty |

---

### Corridor-Specific Considerations

#### **US (Base Jurisdiction)**
- **Regulators:** FinCEN, OCC, SEC, CFTC, State regulators
- **Status:** Stablecoins treated as payment instruments (not securities if structured properly)
- **Requirements:** MSB registration, state MTLs, Bank Secrecy Act, OFAC
- **Data:** No localization requirements (but CLOUD Act applies)
- **Launch Readiness:** ✅ Cleared for launch (assuming MSB/MTL in place)

#### **EU (MiCA Regime)**
- **Regulators:** ECB, National Competent Authorities (e.g., BaFin, AMF)
- **Status:** MiCA (Markets in Crypto-Assets) effective 2024; stablecoins = "E-Money Tokens"
- **Requirements:** E-Money license, reserve requirements, white paper, regular audits
- **Data:** GDPR applies (right to be forgotten, consent management)
- **Launch Readiness:** ⚠️ Requires E-Money license or partnership with licensed issuer

#### **UK (Post-Brexit)**
- **Regulators:** FCA, Bank of England
- **Status:** Stablecoins in regulatory perimeter as of 2024; treated as e-money
- **Requirements:** FCA authorization, safeguarding, audit
- **Data:** UK GDPR (similar to EU GDPR)
- **Launch Readiness:** ⚠️ Requires FCA authorization (6-12 month process)

#### **Singapore (Progressive)**
- **Regulators:** MAS (Monetary Authority of Singapore)
- **Status:** Payment Services Act; stablecoins = "digital payment tokens"
- **Requirements:** MAS license, AML, travel rule
- **Data:** PDPA (similar to GDPR)
- **Launch Readiness:** ✅ MAS open to innovation; can apply for license

#### **India (Restrictive)**
- **Regulators:** RBI, SEBI
- **Status:** ⛔ Crypto/stablecoin regulatory uncertainty; RBI historically hostile
- **Requirements:** Awaiting Digital Rupee and crypto regulations
- **Data:** Data localization MANDATORY (Payment and Settlement Systems Act)
- **Launch Readiness:** ❌ HIGH RISK; await regulatory clarity (2025-2026)

#### **UAE (Emerging)**
- **Regulators:** DFSA (Dubai), ADGM (Abu Dhabi), SCA (federal)
- **Status:** Crypto-friendly; licensing frameworks in ADGM/DIFC
- **Requirements:** Virtual Asset License, AML
- **Data:** Local data storage preferred
- **Launch Readiness:** ✅ Can launch in free zones (ADGM, DIFC)

---

### Currency Conversion Matrix (Phase 1)

```
Customer Journey Example: US Corporate paying EU Supplier

Step 1: Customer deposits $100,000 USD → Our Bank (ATLAS account)
Step 2: Bank buys 100,000 USDC from Circle
Step 3: Bank converts USDC → EURC on-chain (via DEX or OTC)
Step 4: Bank credits supplier's wallet with ~€92,000 EURC (at current FX rate)
Step 5: Supplier redeems EURC → EUR with us or another distributor

Total Time: 15-30 minutes
Total Cost: $50 (vs. $250 SWIFT wire)
FX Spread: 0.3% (vs. 1-2% correspondent banking)
```

---

### Blocked Corridors (Regulatory/Sanctions)

| Corridor | Reason | Status |
|----------|--------|--------|
| **US ↔ Iran, North Korea, Syria** | OFAC sanctions | ⛔ Permanently blocked |
| **US ↔ Russia** | Sanctions (post-2022) | ⛔ Blocked (except humanitarian) |
| **US ↔ China** | Capital controls (PRC side) | ⚠️ Outbound only (very limited) |
| **EU ↔ Belarus** | Sanctions | ⛔ Blocked |

---

<a name="section-3"></a>
# SECTION 3 — COMPLETE FUNCTIONAL SCOPE

## 3.1 Overview of Functional Domains

A bank-grade stablecoin system encompasses **10 functional domains**:

1. **Customer Lifecycle Management** (Onboarding, KYC, AML)
2. **Transaction Processing** (Buy, Sell, Transfer)
3. **Custody & Wallet Management** (Key management, hot/cold storage)
4. **Liquidity & Treasury** (Mint/burn coordination, FX, nostro management)
5. **Compliance & Risk** (Monitoring, sanctions, fraud detection)
6. **Reconciliation & Accounting** (ATLAS ↔ Blockchain, GL posting)
7. **Reporting** (Regulatory, management, customer)
8. **Customer Service** (Disputes, inquiries, account management)
9. **Fee Management** (Billing, invoicing, revenue recognition)
10. **System Administration** (User management, audit trails, configurations)

---

## 3.2 Detailed Functional Requirements (ALL FLOWS)

### DOMAIN 1: Customer Lifecycle Management

#### **F1.1: Customer Onboarding**

**Business Description:**
Prospective customers apply for stablecoin services. Bank performs KYC/AML checks, assesses suitability, and provisions wallets upon approval.

**Trigger:**
- Customer initiates application via digital banking portal, relationship manager, or API

**Happy Path:**
1. Customer submits application (personal/corporate info, documents)
2. System performs identity verification (IDV) via third-party (e.g., Jumio, Onfido)
3. AML screening (PEP, sanctions lists, adverse media) via Dow Jones, World-Check
4. Risk assessment (high/medium/low risk scoring)
5. Manual review if medium/high risk
6. Approval → Wallet provisioned → Customer notified → Account activated

**Failure Scenarios:**
- **IDV Failure:** Documents unclear → Request re-upload
- **Sanctions Hit:** Match on OFAC → Application declined + SAR filed
- **High-Risk Jurisdiction:** Customer in sanctioned country → Auto-reject
- **Incomplete Info:** Missing beneficial owner data → Return to customer

**Regulatory Checks:**
- CIP (Customer Identification Program) compliance
- Beneficial ownership (FinCEN rule for corporates >25% ownership)
- PEP screening
- Country risk assessment

**Systems Involved:**
- CRM (Salesforce, Microsoft Dynamics)
- KYC Platform (Jumio, Onfido, Refinitiv)
- AML System (Actimize, NICE, SAS)
- ATLAS (Customer master)

**Timing:**
- Retail: 1-2 days
- Corporate: 5-10 days (due diligence)
- High-risk: 15-30 days (enhanced due diligence)

---

#### **F1.2: Customer Re-Certification (Periodic KYC)**

**Business Description:**
Existing customers must update KYC info periodically (annual for high-risk, every 3 years for low-risk).

**Trigger:**
- Scheduled job (cron) flags accounts due for re-certification
- Significant change in customer profile (e.g., new director, address change)

**Happy Path:**
1. System sends notification to customer (30 days before due)
2. Customer uploads updated documents
3. Automated re-screening (sanctions, PEP, credit)
4. Approval → Account remains active
5. No response after 60 days → Account restricted (view-only)

**Failure Scenarios:**
- **Customer unresponsive:** Escalate to RM → Final notice → Suspend account
- **New sanctions hit:** Freeze account → File SAR → Close account per legal review

**Regulatory Checks:**
- Ongoing due diligence (FATF Recommendation 10)
- PEP re-screening

---

#### **F1.3: Customer Off-boarding (Account Closure)**

**Business Description:**
Customer requests account closure, or bank initiates closure due to risk/inactivity.

**Trigger:**
- Customer request
- Regulatory requirement (sanctions)
- Risk decision (suspicious activity)
- Dormancy (no activity >2 years)

**Happy Path:**
1. Customer requests closure
2. Check outstanding balances (must be zero stablecoin balance, zero fiat balance)
3. If balances exist, instruct customer to withdraw/sell
4. Final AML review (check for SARs, holds)
5. Close account in ATLAS
6. Archive data per retention policy (7 years)
7. Notify customer of closure

**Failure Scenarios:**
- **Outstanding Balance:** Cannot close until zero
- **Pending Investigation:** Must resolve before closure
- **Legal Hold:** Cannot close without legal clearance

**Regulatory Checks:**
- Record retention (Bank Secrecy Act: 5 years; some jurisdictions: 7 years)
- Final SAR if closure due to suspicion

---

### DOMAIN 2: Transaction Processing

#### **F2.1: Buy Stablecoin (Fiat → Stablecoin)**

**Business Description:**
Customer deposits fiat currency and receives equivalent stablecoin in their wallet.

**Trigger:**
- Customer initiates "Buy USDC" transaction via app/portal/API

**Happy Path:**
1. Customer specifies amount (e.g., $10,000 USD → USDC)
2. System validates:
   - Customer account is active
   - No compliance holds
   - Sufficient balance (if debiting existing account) OR wire instructions (if new deposit)
3. If fiat not yet received, provide wire instructions → Customer sends wire
4. Upon fiat receipt:
   - ATLAS receives credit (+$10,000 USD)
   - Compliance screening (AML, sanctions)
   - If cleared, send mint request to Issuer (via API or omnibus flow)
   - Issuer mints 10,000 USDC → Sends to our omnibus wallet (on-chain)
5. Sub-ledger allocation: Credit customer's internal wallet (10,000 USDC)
6. Notification: "10,000 USDC available in your wallet"

**Timing:**
- Fiat wire receipt: Same-day or T+1 (depending on wire timing)
- Mint + credit: 15-30 minutes after fiat receipt

**Failure Scenarios:**
- **Sanctions Hit:** Fiat received but customer flagged → Return fiat → File SAR
- **Mint Failure:** Issuer API down → Retry → If persistent, manual intervention
- **Insufficient Fiat:** Customer sent $9,999 but ordered $10,000 → Contact customer for balance
- **Network Congestion:** On-chain transaction delayed → Notify customer of delay

**Regulatory Checks:**
- AML screening on incoming wire
- OFAC sanctions screening
- CTR (Currency Transaction Report) if >$10,000 cash equivalent
- Large transaction reporting per jurisdiction

**Fees:**
- Wire fee: $15-25 (if incoming wire)
- Buy spread: 0.25-0.5% (bank's margin)
- Blockchain gas (absorbed by bank in Phase-1)

**Systems Involved:**
- ATLAS (fiat ledger)
- Issuer API (mint request)
- Blockchain (on-chain transfer)
- Sub-ledger (customer wallet allocation)
- AML System (screening)

---

#### **F2.2: Sell Stablecoin (Stablecoin → Fiat)**

**Business Description:**
Customer redeems stablecoin for fiat currency.

**Trigger:**
- Customer initiates "Sell USDC" transaction

**Happy Path:**
1. Customer specifies amount (e.g., 10,000 USDC → USD)
2. System validates:
   - Customer has ≥10,000 USDC balance
   - No compliance holds
   - No pending disputes on wallet
3. Debit customer's internal wallet (-10,000 USDC)
4. Transfer 10,000 USDC from our omnibus wallet to Issuer's burn address (on-chain)
5. Issuer burns 10,000 USDC → Wires $10,000 USD to our nostro account
6. ATLAS credits customer's fiat account (+$10,000 USD, minus fees)
7. Notification: "Funds available in your USD account"

**Timing:**
- Wallet debit: Instant
- On-chain burn: 15-30 minutes
- Fiat credit: T+0 or T+1 (depending on issuer settlement)

**Failure Scenarios:**
- **Insufficient Balance:** Customer tries to sell 10,000 but has 9,999 → Reject
- **Burn Failure:** Blockchain congestion → Retry → Manual intervention if persistent
- **Issuer Delay:** Issuer takes >24h to send fiat → Escalate to issuer
- **Fiat Account Frozen:** Customer's fiat account has legal hold → Hold proceeds, notify legal

**Regulatory Checks:**
- AML screening (check if redemption pattern is suspicious)
- Source of stablecoins (did customer receive from high-risk wallet?)
- CTR if large redemption

**Fees:**
- Sell spread: 0.25-0.5%
- Wire fee (if customer wants external wire-out): $25

**Systems Involved:**
- Sub-ledger (wallet debit)
- Blockchain (burn transaction)
- Issuer API (burn + fiat settlement)
- ATLAS (fiat credit)

---

#### **F2.3: Peer-to-Peer Transfer (On-Us)**

**Business Description:**
Customer transfers stablecoin to another customer within our bank's system (both have wallets with us).

**Trigger:**
- Customer initiates "Send USDC" to recipient (using recipient's email, phone, or wallet ID)

**Happy Path:**
1. Customer specifies recipient and amount
2. System validates:
   - Sender has sufficient balance
   - Recipient exists in our system
   - No compliance holds on either party
3. Debit sender's wallet (-amount)
4. Credit recipient's wallet (+amount)
5. NO on-chain transaction (off-chain, internal ledger transfer)
6. Both parties receive notification
7. Instant settlement

**Timing:** <1 second

**Failure Scenarios:**
- **Recipient Not Found:** Email/wallet ID doesn't match any customer → Reject, notify sender
- **Compliance Hold:** Sender or recipient flagged → Hold transaction → Review
- **Daily Limit Exceeded:** Sender exceeds daily transfer limit → Reject (or require additional auth)

**Regulatory Checks:**
- AML screening (unusual patterns, e.g., rapid in-out movements)
- Travel Rule NOT required (on-us, so we know both parties)

**Fees:**
- None (or nominal, e.g., $0.10) for on-us transfers

**Systems Involved:**
- Sub-ledger (debit sender, credit recipient)
- AML System (transaction monitoring)

---

#### **F2.4: Peer-to-Peer Transfer (Off-Us, On-Chain)**

**Business Description:**
Customer transfers stablecoin to an external wallet (not in our system).

**Trigger:**
- Customer initiates "Send USDC" to external blockchain address

**Happy Path:**
1. Customer provides recipient's wallet address (0x123abc...)
2. System validates:
   - Address format (checksum validation)
   - Address not on blacklist (sanctioned addresses per TRM Labs, Chainalysis)
   - Customer has sufficient balance + gas fees
3. Optional: Customer adds to whitelist (pre-approved addresses for future)
4. Debit customer's wallet
5. Construct on-chain transaction (from our hot wallet)
6. Sign with HSM/multi-sig
7. Broadcast to blockchain
8. Monitor confirmations (12 blocks for high-value)
9. Update customer's transaction history ("Sent, Confirmed")
10. If Travel Rule threshold (>$1,000), collect recipient info and share per FATF

**Timing:** 15-30 minutes (depending on blockchain congestion)

**Failure Scenarios:**
- **Invalid Address:** Checksum fails → Reject before broadcasting
- **Sanctioned Address:** Address on OFAC SDN list → Reject + File SAR
- **Insufficient Gas:** Network fees spiked → Request customer to wait or pay higher fee
- **Transaction Reverted:** Smart contract rejection (e.g., recipient is blocklisted by issuer) → Funds may be stuck (escalate to issuer)

**Regulatory Checks:**
- Sanctions screening on recipient address
- Travel Rule (collect recipient name, address if >$1,000)
- Blockchain analytics (flag if recipient is mixer, gambling site, darknet market)

**Fees:**
- Network gas fee (pass-through or absorbed)
- Transfer fee: $1-5

**Systems Involved:**
- Sub-ledger (debit sender)
- Blockchain node (broadcast transaction)
- HSM (transaction signing)
- AML/Sanctions screening (TRM Labs, Chainalysis, Elliptic)

---

#### **F2.5: Mint (Issuer Operation via Settlement Bank)**

**Business Description:**
Issuer instructs settlement bank (us) to receive fiat and expects stablecoin to be minted on-chain. This is a wholesale operation, not customer-facing.

**Trigger:**
- Issuer's treasury team sends instruction: "We need to mint $50M USDC; please confirm fiat receipt"

**Happy Path:**
1. Issuer wires $50M USD to our segregated account (their reserve account)
2. ATLAS confirms receipt (+$50M in Issuer's account)
3. We notify Issuer of receipt
4. Issuer triggers smart contract mint (creates 50M new USDC tokens)
5. Issuer credits our omnibus wallet (or direct to customers if direct model)
6. We reconcile: $50M fiat in = 50M USDC minted

**Failure Scenarios:**
- **Fiat Not Received:** Issuer claims they sent, but we don't see it → Trace wire
- **Mint/Burn Imbalance:** Issuer minted 50M but we only received $49.9M → Investigate discrepancy
- **Unauthorized Mint:** Issuer mints without fiat backing → Breach of contract → Escalate to legal/regulators

**Regulatory Checks:**
- Daily reconciliation (fiat reserves = on-chain supply)
- Attestation report (monthly by auditor)

**Timing:** T+0 (same-day)

**Systems Involved:**
- ATLAS (fiat tracking)
- Issuer's smart contract (mint function)
- Blockchain (on-chain event log)

---

#### **F2.6: Burn (Redemption by Issuer via Settlement Bank)**

**Business Description:**
Issuer destroys stablecoin and instructs settlement bank to wire fiat back.

**Trigger:**
- Issuer sends burn instruction: "We are burning 50M USDC; please wire $50M USD to [account]"

**Happy Path:**
1. Issuer burns 50M USDC (on-chain transaction to burn address)
2. We verify on-chain event
3. ATLAS debits Issuer's segregated account (-$50M USD)
4. We wire $50M to Issuer's designated account
5. Reconciliation: 50M USDC burned = $50M fiat out

**Failure Scenarios:**
- **Burn Not Visible:** Blockchain delay → Wait for confirmation
- **Insufficient Fiat:** Issuer requests $50M but their account has $49M → Reject (should never happen if reserves maintained correctly)

**Regulatory Checks:**
- Reserve adequacy check
- Large transaction reporting

**Timing:** T+0 or T+1 (depending on wire cut-off)

**Systems Involved:**
- Blockchain (burn event monitoring)
- ATLAS (fiat debit + wire)
- Reconciliation engine

---

### DOMAIN 3: Custody & Wallet Management

#### **F3.1: Wallet Provisioning**

**Business Description:**
Upon customer approval, system generates a blockchain wallet (public/private key pair) and assigns to customer.

**Trigger:**
- KYC approval

**Happy Path:**
1. Call custody provider API (e.g., Fireblocks, or in-house HSM)
2. Generate key pair
3. Store private key in HSM/MPC (multi-party computation)
4. Assign public address to customer in sub-ledger
5. Customer can now view wallet in app (displays address, QR code)

**Failure Scenarios:**
- **HSM Failure:** Retry → If persistent, manual key generation with backup procedures

**Regulatory Checks:**
- Key generation must be auditable (log who, when, entropy source)

**Timing:** <1 minute

**Systems Involved:**
- HSM (Thales, Utimaco, or Fireblocks MPC)
- Sub-ledger (wallet registry)

---

#### **F3.2: Wallet Sweep (Hot → Cold)**

**Business Description:**
Periodically (e.g., daily), move funds from hot wallet (online, operational) to cold wallet (offline, secure) to minimize exposure.

**Trigger:**
- Scheduled job (e.g., 2 AM daily)
- Threshold breach (hot wallet >$10M)

**Happy Path:**
1. Calculate excess balance (hot wallet target: $5M; current: $12M → sweep $7M)
2. Construct on-chain transaction (hot → cold)
3. Require multi-sig approval (e.g., 3-of-5 signers)
4. Signers approve via hardware tokens
5. Broadcast transaction
6. Confirm settlement
7. Update internal records

**Failure Scenarios:**
- **Signers Unavailable:** Cannot get quorum → Delay sweep (acceptable if hot wallet not at risk)
- **High Gas Fees:** Delay until fees normalize

**Regulatory Checks:**
- Audit trail of who approved sweep

**Timing:** 30-60 minutes (including approvals)

**Systems Involved:**
- Custody platform (Fireblocks, BitGo)
- Multi-sig wallet (Gnosis Safe or similar)
- Monitoring (alert if sweep fails)

---

#### **F3.3: Wallet Recovery**

**Business Description:**
Customer loses access (forgot password, device lost). Bank must recover wallet without compromising security.

**Trigger:**
- Customer support request

**Happy Path:**
1. Customer contacts support
2. Identity verification (KYC refresh, challenge questions, video call)
3. If verified, reset MFA credentials
4. Customer regains access to wallet (private key never exposed)

**Failure Scenarios:**
- **Failed Identity Verification:** Require in-branch visit or notarized documents
- **Private Key Compromised (Suspected):** Migrate funds to new wallet, deactivate old wallet

**Regulatory Checks:**
- Strong identity verification (prevent social engineering)

**Timing:** 1-3 days (depending on verification method)

**Systems Involved:**
- Customer support (Zendesk, ServiceNow)
- Identity verification (video call, notary)

---

### DOMAIN 4: Liquidity & Treasury Management

#### **F4.1: Liquidity Forecasting**

**Business Description:**
Treasury team forecasts daily buy/sell volumes to ensure sufficient stablecoin and fiat liquidity.

**Trigger:**
- Daily (automated) or ad-hoc

**Happy Path:**
1. ML model analyzes historical buy/sell patterns
2. Predicts next 7 days' net flow (e.g., expect $20M net buys this week)
3. Treasury pre-purchases $25M USDC from issuer (buffer)
4. Maintains fiat liquidity for redemptions

**Failure Scenarios:**
- **Unexpected Surge:** Black swan event (e.g., bank run) → Activate emergency credit lines

**Regulatory Checks:**
- Liquidity coverage ratio (internal policy: maintain 120% of expected redemptions)

**Systems Involved:**
- Data warehouse (historical transaction data)
- ML model (Python, R, or vendor solution)
- ATLAS (fiat liquidity)
- Treasury management system (TMS)

---

#### **F4.2: FX Conversion (USDC ↔ EURC)**

**Business Description:**
Customer wants to convert stablecoin from one currency to another.

**Trigger:**
- Customer initiates "Convert 10,000 USDC → EURC"

**Happy Path:**
1. System fetches real-time FX rate (USD/EUR = 1.08)
2. Quotes customer: 10,000 USDC → 9,259 EURC (minus 0.5% spread)
3. Customer accepts
4. Bank swaps on-chain:
   - Option A: Use DEX (decentralized exchange like Uniswap, Curve) → atomic swap
   - Option B: OTC desk (e.g., Circle's liquidity network)
5. Customer's wallet updated (-10,000 USDC, +9,259 EURC)

**Timing:** 15-30 minutes

**Failure Scenarios:**
- **High Slippage:** FX rate moved during transaction → Re-quote customer
- **Liquidity Shortage:** Not enough EURC available → Source from issuer (may take hours)

**Regulatory Checks:**
- FX reporting (some jurisdictions require FX transaction logs)

**Fees:**
- FX spread: 0.3-0.5%

**Systems Involved:**
- FX rate feed (Reuters, Bloomberg)
- DEX aggregator (1inch, Paraswap) or OTC desk
- Sub-ledger (wallet updates)

---

### DOMAIN 5: Compliance & Risk

#### **F5.1: Real-Time Transaction Monitoring**

**Business Description:**
Every transaction is screened for AML red flags (structuring, rapid movement, layering, etc.).

**Trigger:**
- Every buy/sell/transfer transaction

**Happy Path:**
1. Transaction submitted
2. AML engine (Actimize, NICE) applies rules:
   - Structuring: Multiple transactions just below reporting threshold?
   - Rapid movement: Funds in, immediately out?
   - High-risk counterparty: Recipient is casino, mixer, darknet?
   - Geographic risk: Transfer to high-risk jurisdiction?
3. If low-risk score → Approve (straight-through processing)
4. If medium-risk score → Queue for analyst review (T+1)
5. If high-risk score → Block transaction + escalate to senior compliance

**Failure Scenarios:**
- **False Positive:** Legitimate transaction blocked → Customer contacts support → Analyst reviews → Unblocks
- **False Negative:** Illicit transaction approved → Detected in periodic review → File SAR → Customer investigation

**Regulatory Checks:**
- SAR filing if suspicious (within 30 days of detection)
- Recordkeeping (all decisions documented)

**Timing:**
- Real-time: <2 seconds for automated decisions
- Manual review: 4-24 hours

**Systems Involved:**
- AML platform (Actimize, SAS, NICE Actimize)
- Blockchain analytics (Chainalysis, TRM Labs, Elliptic)
- Case management (for investigations)

---

#### **F5.2: Sanctions Screening**

**Business Description:**
Screen customers and transactions against sanctions lists (OFAC, UN, EU, HMT, etc.).

**Trigger:**
- Onboarding (screen customer)
- Every transaction (screen counterparty wallet address)
- Daily batch (re-screen all customers against updated lists)

**Happy Path:**
1. Query sanctions database (Dow Jones, World-Check, Chainalysis)
2. No match → Approve
3. Match → Freeze account/transaction → Investigate
4. If confirmed match → File SAR → Block customer → Report to OFAC

**Failure Scenarios:**
- **Delayed List Update:** Sanctioned entity transacts before list updates → Detect in daily batch → Reverse transaction if possible (difficult on-chain)

**Regulatory Checks:**
- Must screen against all applicable lists (US: OFAC SDN; EU: EU sanctions list; UK: HMT; UN)
- Must complete within 24 hours of list update

**Timing:** Real-time (<1 second per check)

**Systems Involved:**
- Sanctions screening engine (Dow Jones, Refinitiv, or in-house)
- Blockchain analytics (for wallet address screening)

---

#### **F5.3: Travel Rule Compliance**

**Business Description:**
For transfers >$1,000 (or local equivalent), share sender and recipient info with counterparty VASP (Virtual Asset Service Provider).

**Trigger:**
- Off-us transfer >$1,000

**Happy Path:**
1. Customer initiates transfer to external wallet
2. System prompts: "Recipient's name and address required (regulatory)"
3. Customer provides (or selects from whitelist)
4. System identifies recipient VASP (using blockchain analytics or manual lookup)
5. Share info via Travel Rule protocol (e.g., TRP, Sygna, Notabene)
6. Recipient VASP confirms receipt of info
7. Proceed with transfer

**Failure Scenarios:**
- **Recipient VASP Not Registered:** Cannot identify counterparty → Risk-based decision (approve small amounts, block large amounts)
- **Recipient VASP Doesn't Respond:** Wait 24h → Escalate to compliance → May decline transaction

**Regulatory Checks:**
- FATF Recommendation 16 (Travel Rule)
- FinCEN rule (US), MiCA (EU), FCA (UK), MAS (Singapore)

**Timing:** Adds 5-15 minutes to transaction (waiting for VASP response)

**Systems Involved:**
- Travel Rule solution (Notabene, Sygna, TRP)
- Blockchain analytics (identify recipient VASP)

---

### DOMAIN 6: Reconciliation & Accounting

#### **F6.1: Daily Reconciliation (ATLAS ↔ Blockchain)**

**Business Description:**
Ensure bank's internal records (sub-ledger) match on-chain reality.

**Trigger:**
- Scheduled (daily, end-of-day)

**Happy Path:**
1. Query blockchain: Sum all customer wallet balances (on-chain)
2. Query sub-ledger: Sum all customer wallet balances (internal DB)
3. Compare:
   - On-chain: 1,000,000 USDC
   - Sub-ledger: 1,000,000 USDC
   - ✅ Match → Generate reconciliation report
4. Archive report for audit

**Failure Scenarios:**
- **Mismatch Detected:**
   - Example: On-chain = 1,000,000 USDC; Sub-ledger = 999,990 USDC (missing 10 USDC)
   - Investigate: Check transaction logs for failed credits
   - Resolve: Manually adjust sub-ledger (with approval + documentation)
   - Escalate: If unexplained, escalate to CFO + auditors

**Regulatory Checks:**
- Must reconcile daily (banking regulation)
- Breaks >$10K must be reported to senior management within 24h

**Timing:** 30-60 minutes (automated)

**Systems Involved:**
- Blockchain indexer (Etherscan API, Alchemy, or in-house node)
- Sub-ledger (PostgreSQL, Oracle)
- Reconciliation engine (custom or vendor like AutoRek)

---

#### **F6.2: General Ledger Posting**

**Business Description:**
Post stablecoin transactions to ATLAS general ledger for financial reporting.

**Trigger:**
- End-of-day batch

**Happy Path:**
1. Sub-ledger generates journal entries:
   - Buy transaction: Debit "Customer USDC Wallet" / Credit "USDC Omnibus Wallet"
   - Sell transaction: Debit "USDC Omnibus Wallet" / Credit "Customer USDC Wallet"
   - Fee: Debit "Customer Cash" / Credit "Fee Revenue"
2. Post to ATLAS GL
3. Update financial statements (balance sheet, P&L)

**Failure Scenarios:**
- **GL Posting Error:** Interface down → Queue entries → Retry → Manual posting if persistent

**Regulatory Checks:**
- GAAP/IFRS compliance (see Section 9)

**Timing:** Nightly batch (runs at midnight)

**Systems Involved:**
- ATLAS (Core Banking GL)
- Sub-ledger
- ETL pipeline (Informatica, Talend, or custom)

---

### DOMAIN 7: Reporting

#### **F7.1: Customer Statements**

**Business Description:**
Monthly statements showing all stablecoin transactions.

**Trigger:**
- Monthly (1st of month)

**Happy Path:**
1. Generate PDF statement:
   - Opening balance
   - All transactions (buys, sells, transfers in/out)
   - Fees charged
   - Closing balance
2. Email to customer + available in portal

**Failure Scenarios:**
- **Customer Opt-Out:** Honor preference (paperless-only)

**Regulatory Checks:**
- Required by banking regulations (periodic statements)

**Timing:** Generated overnight (1st of month)

**Systems Involved:**
- Reporting engine (Tableau, Power BI, or custom)
- Email service

---

#### **F7.2: Regulatory Reporting (SAR, CTR, etc.)**

**Business Description:**
File required reports with regulators (FinCEN, FCA, MAS, etc.).

**Trigger:**
- Event-driven (suspicious activity) or periodic (quarterly)

**Happy Path:**
- SAR (Suspicious Activity Report): File within 30 days of detection
- CTR (Currency Transaction Report): File within 15 days of transaction >$10K
- MiCA reporting: Quarterly transaction volume to ECB

**Failure Scenarios:**
- **Missed Deadline:** Regulatory fine → Process improvement

**Regulatory Checks:**
- Varies by jurisdiction (see Section 11)

**Timing:** Per regulatory requirement

**Systems Involved:**
- AML platform (generates reports)
- Regulatory filing portal (FinCEN BSA E-Filing, FCA RegData, etc.)

---

### DOMAIN 8: Customer Service

#### **F8.1: Dispute Resolution**

**Business Description:**
Customer disputes a transaction (unauthorized, error, etc.).

**Trigger:**
- Customer files dispute via support ticket

**Happy Path:**
1. Customer describes issue
2. Support agent reviews:
   - Transaction logs
   - Blockchain confirmation
   - Customer's recent activity
3. If error confirmed (e.g., wrong amount credited):
   - Adjust customer's balance
   - Compensate if applicable
4. If unauthorized transaction:
   - Investigate (was it social engineering? Key compromise?)
   - If bank's fault → Reimburse
   - If customer's fault (shared password) → May decline reimbursement (per T&Cs)

**Failure Scenarios:**
- **Complex Case:** Escalate to legal + compliance

**Regulatory Checks:**
- Must respond within regulatory timeframes (e.g., EU: 15 days)

**Timing:** 5-10 business days

**Systems Involved:**
- Support ticketing (Zendesk, ServiceNow)
- Transaction logs
- Blockchain explorer

---

### DOMAIN 9: Fee Management

#### **F9.1: Fee Calculation & Billing**

**Business Description:**
Calculate and charge fees (transaction fees, custody fees, FX spreads).

**Trigger:**
- Every transaction (transaction fees)
- Monthly (custody fees)

**Happy Path:**
1. Transaction completes
2. Calculate fee (e.g., 0.5% of $10,000 buy = $50)
3. Debit customer's fiat account or stablecoin wallet (per T&Cs)
4. Credit "Fee Revenue" GL account
5. Include in monthly statement

**Failure Scenarios:**
- **Insufficient Funds for Fee:** Transaction declines (or net settle)

**Regulatory Checks:**
- Fee disclosure (must be transparent, no hidden fees)

**Timing:** Real-time (transaction fees) or monthly (custody fees)

**Systems Involved:**
- Fee engine (in-house or vendor)
- ATLAS (GL posting)

---

### DOMAIN 10: System Administration

#### **F10.1: User Access Management**

**Business Description:**
Manage internal users (employees) and their permissions.

**Trigger:**
- New employee onboarding
- Role change
- Termination

**Happy Path:**
1. HR system triggers IAM (Identity & Access Management)
2. Provision user in Active Directory / SSO
3. Assign role (e.g., "Customer Support Agent" → read-only access to customer data)
4. User can log in to internal tools

**Failure Scenarios:**
- **Orphaned Accounts:** Terminated employee still has access → Audit quarterly → Revoke

**Regulatory Checks:**
- SOX controls (segregation of duties)
- Audit trail (who accessed what, when)

**Timing:** Real-time

**Systems Involved:**
- Active Directory / Okta / Auth0
- ATLAS
- Internal tools (admin panels)

---

