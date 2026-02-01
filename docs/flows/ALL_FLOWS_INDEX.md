# ALL JOURNEY FLOWS - COMPLETE INDEX
## Bank-Grade Stablecoin Platform

**Last Updated:** February 2026

---

## OVERVIEW

This document provides a complete index of all customer and operational journey flows with graphical representations (Mermaid sequence diagrams).

**Total Flows Documented:** 5 Core Flows + 2 Main Guides with embedded flows

---

## ✅ COMPLETED FLOWS WITH DIAGRAMS

### 1. **CUSTOMER ONBOARDING FLOW**
**File:** `docs/flows/CUSTOMER_ONBOARDING_FLOW.md`
**Journey:** Application → KYC → AML → Wallet Provisioning → Active Account
**Duration:** 1-10 days
**Diagram Type:** Mermaid Sequence Diagram
**Key Phases:**
- Phase 1: Application Submission
- Phase 2: Identity Verification (Jumio KYC)
- Phase 3: AML Screening (Sanctions, PEP, Adverse Media)
- Phase 4: Account Setup (ATLAS + Wallet)
- Phase 5: Customer Notification

**Failure Scenarios:**
- Sanctions hit
- Document fraud
- Customer unresponsive

---

### 2. **BUY STABLECOIN FLOW**
**File:** `docs/flows/BUY_FLOW_DETAILED.md`
**Journey:** Customer deposits fiat → Receives stablecoin
**Duration:** 30 minutes
**Diagram Type:** Mermaid Sequence Diagram
**Key Phases:**
- Phase 1: Customer initiates buy order
- Phase 2: Pre-flight validations (balance, limits, compliance)
- Phase 3: Fiat receipt & AML screening
- Phase 4: Check USDC liquidity / Request mint if needed
- Phase 5: Allocate USDC to customer (sub-ledger or on-chain)
- Phase 6: Notification & accounting

**Failure Scenarios:**
- Sanctions hit during AML
- Issuer unable to mint
- Blockchain congestion
- ATLAS system down

---

### 3. **SELL STABLECOIN FLOW**
**File:** `docs/MASTER_STABLECOIN_IMPLEMENTATION_GUIDE_PART2.md` (Section 5.2)
**Journey:** Customer redeems stablecoin → Receives fiat
**Duration:** 30 minutes to T+1
**Diagram Type:** Mermaid Sequence Diagram
**Key Phases:**
- Phase 1: Customer initiates sell order
- Phase 2: Validate balance & limits
- Phase 3: Debit customer wallet & AML screening
- Phase 4: Burn USDC (on-chain or internal rebalancing)
- Phase 5: Fiat settlement (credit ATLAS account)
- Phase 6: Notification

**Failure Scenarios:**
- Customer tries to sell USDC from sanctioned wallet
- Issuer fails to settle fiat
- Customer's fiat account frozen

---

### 4. **ON-CHAIN TRANSFER FLOW**
**File:** `docs/flows/TRANSFER_FLOW_ONCHAIN.md`
**Journey:** Customer sends stablecoin to external wallet
**Duration:** 15-30 minutes
**Diagram Type:** Mermaid Sequence Diagram
**Key Phases:**
- Phase 1: Initiation (customer provides recipient address)
- Phase 2: Balance & limit checks
- Phase 3: Recipient screening (Chainalysis)
- Phase 4: Travel Rule compliance (if >$1,000)
- Phase 5: Blockchain execution (sign, broadcast, confirm)
- Phase 6: Post-transaction & reconciliation

**Failure Scenarios:**
- High-risk recipient (sanctioned, mixer)
- Network congestion (high gas fees)
- Transaction stuck or reverted
- Travel Rule: Recipient VASP not identified

---

### 5. **DAILY RECONCILIATION FLOW**
**File:** `docs/flows/RECONCILIATION_FLOW.md`
**Journey:** Automated daily check to ensure ledgers match
**Duration:** 30-60 minutes (automated)
**Diagram Type:** Mermaid Sequence Diagram
**Key Phases:**
- Phase 1: Scheduled trigger (daily 11:59 PM)
- Phase 2: Data collection (sub-ledger, blockchain, ATLAS)
- Phase 3: Comparison & analysis
- Phase 4: Investigation (if break detected)
- Phase 5: Reporting & sign-off

**Break Scenarios:**
- Perfect match (no action)
- Minor break (<$100, auto-resolve)
- Material break (>$100, urgent investigation)
- Critical break (>$10K, emergency response)

**Root Causes:**
- Failed on-chain transaction
- Duplicate credit
- Unauthorized transaction (security incident)

---

## 📊 FLOW SUMMARY TABLE

| Flow | File | Diagram | Duration | Actors | Complexity |
|------|------|---------|----------|--------|------------|
| **Onboarding** | `CUSTOMER_ONBOARDING_FLOW.md` | ✅ Mermaid | 1-10 days | Customer, KYC, AML, Custody | High |
| **Buy** | `BUY_FLOW_DETAILED.md` | ✅ Mermaid | 30 min | Customer, ATLAS, Issuer, Blockchain | High |
| **Sell** | `MASTER_GUIDE_PART2.md` | ✅ Mermaid | 30 min - T+1 | Customer, ATLAS, Issuer | Medium |
| **Transfer (On-Chain)** | `TRANSFER_FLOW_ONCHAIN.md` | ✅ Mermaid | 15-30 min | Customer, Compliance, Blockchain | High |
| **Reconciliation** | `RECONCILIATION_FLOW.md` | ✅ Mermaid | 30-60 min | Automated, Treasury | Medium |

---

## 📁 ADDITIONAL FLOWS IN MAIN GUIDES

### From MASTER_STABLECOIN_IMPLEMENTATION_GUIDE_PART2.md:

**Section 5.1: Buy Flow Sequence Diagram**
- Full Mermaid sequence diagram
- Step-by-step narrative
- Failure scenarios

**Section 5.2: Sell Flow Sequence Diagram**
- Full Mermaid sequence diagram
- Step-by-step narrative
- Failure scenarios

---

## 🎨 HOW TO VIEW THE DIAGRAMS

All flows include **Mermaid sequence diagrams** that show visual step-by-step interactions between actors.

### View Methods:

1. **GitHub** (Easiest - Automatic Rendering):
   - Go to: https://github.com/anandkedari/stablecoins
   - Open any flow file
   - Diagrams render automatically!

2. **Mermaid Live Editor** (No Installation):
   - Go to: https://mermaid.live/
   - Copy Mermaid code from flow file
   - Paste into editor
   - See visual diagram!

3. **VS Code** (For Developers):
   - Install "Markdown Preview Mermaid Support" extension
   - Open flow file
   - Right-click → "Open Preview"
   - Diagrams render in preview pane

4. **See:** `QUICK_START_DIAGRAMS.md` for detailed instructions

---

## 🔍 FLOW CHARACTERISTICS

### Customer-Facing Flows (4)
1. Onboarding - Customer applies for service
2. Buy - Customer purchases stablecoin
3. Sell - Customer redeems stablecoin
4. Transfer - Customer sends to external wallet

### Operational Flows (1)
1. Reconciliation - Daily automated check (treasury operation)

---

## 📋 FLOW COVERAGE CHECKLIST

| Process | Diagram | Detailed Steps | Failure Scenarios | Testing | Status |
|---------|---------|----------------|-------------------|---------|--------|
| **Customer Onboarding** | ✅ | ✅ | ✅ | ✅ | **COMPLETE** |
| **Buy Stablecoin** | ✅ | ✅ | ✅ | ✅ | **COMPLETE** |
| **Sell Stablecoin** | ✅ | ✅ | ✅ | ✅ | **COMPLETE** |
| **Transfer (On-Chain)** | ✅ | ✅ | ✅ | ✅ | **COMPLETE** |
| **Transfer (On-Us)** | ⏸️ | ✅ | ✅ | - | Mentioned in Section 3 |
| **Reconciliation** | ✅ | ✅ | ✅ | ✅ | **COMPLETE** |
| **Mint/Burn (Issuer)** | ⏸️ | ✅ | ✅ | - | Mentioned in Section 3 |
| **Wallet Sweep (Hot→Cold)** | ⏸️ | ✅ | ✅ | - | Mentioned in Section 3 |
| **Dispute Resolution** | ⏸️ | ✅ | - | - | Mentioned in Section 3 |
| **AML Screening** | ⏸️ | ✅ | ✅ | - | Embedded in Buy/Transfer flows |

**Legend:**
- ✅ = Fully documented with diagram
- ⏸️ = Described in text (no dedicated diagram yet)

---

## 🚀 ADDITIONAL FLOWS TO CREATE (Phase 2)

If you need more flows with diagrams, these can be added:

1. **Transfer (On-Us) Flow** - Between two customers in our system
2. **Mint/Burn Flow** - Bank requests mint from issuer (wholesale operation)
3. **Wallet Sweep Flow** - Hot wallet → Cold wallet daily sweep
4. **Dispute Resolution Flow** - Customer disputes unauthorized transaction
5. **KYC Re-Certification Flow** - Annual re-verification of customers
6. **Account Closure Flow** - Customer or bank-initiated closure
7. **Liquidity Management Flow** - Treasury forecasting and rebalancing
8. **FX Conversion Flow** - USDC → EURC on-chain swap

**Would you like me to create any of these additional flows?**

---

## 📈 FLOW METRICS

### Coverage Statistics:
- **Total Business Processes:** 10
- **Flows with Detailed Diagrams:** 5 (50%)
- **Flows with Textual Description:** 10 (100%)
- **Flows with Failure Scenarios:** 5 (50%)
- **Flows with Testing Scenarios:** 5 (50%)

### Documentation Quality:
- All flows include:
  - ✅ Step-by-step narrative
  - ✅ Actor identification
  - ✅ Duration estimates
  - ✅ Key phases
  - ✅ Failure scenarios
  - ✅ Compliance requirements

---

## 🔗 QUICK LINKS

**Main Flows:**
- [Customer Onboarding](./CUSTOMER_ONBOARDING_FLOW.md)
- [Buy Stablecoin](./BUY_FLOW_DETAILED.md)
- [Sell Stablecoin](../MASTER_STABLECOIN_IMPLEMENTATION_GUIDE_PART2.md#section-5-2)
- [On-Chain Transfer](./TRANSFER_FLOW_ONCHAIN.md)
- [Daily Reconciliation](./RECONCILIATION_FLOW.md)

**Guides:**
- [Master Implementation Guide - Part 1](../MASTER_STABLECOIN_IMPLEMENTATION_GUIDE.md)
- [Master Implementation Guide - Part 2](../MASTER_STABLECOIN_IMPLEMENTATION_GUIDE_PART2.md)
- [Master Implementation Guide - Part 3](../MASTER_STABLECOIN_IMPLEMENTATION_GUIDE_PART3.md)

**Diagrams:**
- [How to View Diagrams](../../HOW_TO_VIEW_DIAGRAMS.md)
- [Quick Start Diagrams](../../QUICK_START_DIAGRAMS.md)

---

## ✅ SUMMARY

**You now have 5 complete end-to-end journey flows with:**
- ✅ Visual Mermaid sequence diagrams
- ✅ Detailed step-by-step narratives
- ✅ Failure scenario analysis
- ✅ Testing scenarios
- ✅ Compliance requirements
- ✅ Metrics and SLAs

**All flows are:**
- Bank-grade (conservative, regulator-ready)
- Production-ready (include error handling)
- Auditable (clear responsibilities, timing, evidence)

---

**Document Owner:** Business Analysis Team
**Version:** 1.0
