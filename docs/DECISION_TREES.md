# DECISION TREES & FLOWCHARTS
## Quick Decision Guides for Common Scenarios

**Last Updated:** February 2026

---

## 📖 PURPOSE

This document provides **visual decision trees** to help users quickly determine the right action path for common scenarios.

---

## 🎯 DECISION 1: WHICH FLOW SHOULD I USE?

```mermaid
graph TD
    Start[Customer Action Needed] --> Q1{Is customer<br/>already onboarded?}

    Q1 -->|NO| Onboard[Use ONBOARDING FLOW<br/>Duration: 1-10 days]
    Q1 -->|YES| Q2{What does customer<br/>want to do?}

    Q2 -->|Get USDC| Buy[Use BUY FLOW<br/>Duration: ~30 min]
    Q2 -->|Get fiat back| Sell[Use SELL FLOW<br/>Duration: 30 min - T+1]
    Q2 -->|Send USDC elsewhere| Q3{Where to send?}

    Q3 -->|Another customer<br/>in our bank| OnUs[Use ON-US TRANSFER<br/>Internal, instant]
    Q3 -->|External wallet| Transfer[Use ON-CHAIN TRANSFER FLOW<br/>Duration: 15-30 min]

    Onboard --> Complete[Process Complete]
    Buy --> Complete
    Sell --> Complete
    OnUs --> Complete
    Transfer --> Complete

    style Start fill:#e1f5ff
    style Complete fill:#d4edda
    style Onboard fill:#fff3cd
    style Buy fill:#d4edda
    style Sell fill:#fff3cd
    style Transfer fill:#f8d7da
```

---

## 🚦 DECISION 2: ONBOARDING - APPROVE OR REJECT?

```mermaid
graph TD
    Start[Customer Application Received] --> KYC{KYC Verification}

    KYC -->|PASS| AML{AML Screening}
    KYC -->|FAIL| Reject1[REJECT<br/>Reason: Identity verification failed]

    AML -->|CLEAR| Sanctions{Sanctions Check}
    AML -->|HIT| Review1{Manual Review}

    Review1 -->|False Positive| Sanctions
    Review1 -->|Confirmed Match| Reject2[REJECT<br/>Reason: Sanctions hit]

    Sanctions -->|CLEAR| PEP{PEP Check}
    Sanctions -->|HIT| Reject3[REJECT<br/>Reason: Sanctioned entity]

    PEP -->|NOT PEP| EDD{Enhanced Due Diligence<br/>Required?}
    PEP -->|IS PEP| Review2{Senior Compliance<br/>Approval}

    Review2 -->|APPROVED| EDD
    Review2 -->|REJECTED| Reject4[REJECT<br/>Reason: High-risk PEP]

    EDD -->|NO| Approve[APPROVE<br/>Provision Wallet]
    EDD -->|YES| Docs{Additional Documents<br/>Provided?}

    Docs -->|YES| Review3{Compliance Review}
    Docs -->|NO| Hold[HOLD<br/>Request documents]

    Review3 -->|APPROVED| Approve
    Review3 -->|REJECTED| Reject5[REJECT<br/>Reason: Insufficient documentation]

    Hold -->|Customer Responds| Docs
    Hold -->|30 Days No Response| Reject6[REJECT<br/>Reason: Customer unresponsive]

    style Approve fill:#d4edda
    style Reject1 fill:#f8d7da
    style Reject2 fill:#f8d7da
    style Reject3 fill:#f8d7da
    style Reject4 fill:#f8d7da
    style Reject5 fill:#f8d7da
    style Reject6 fill:#f8d7da
```

**Rejection Reasons Summary:**
- **Identity Failed:** Document fraud, poor quality images, name mismatch
- **Sanctions Hit:** OFAC, UN, EU sanctions lists
- **High-Risk PEP:** Government official from high-risk country
- **Insufficient Docs:** Cannot verify source of funds

---

## 💰 DECISION 3: BUY FLOW - INSTANT OR DELAYED?

```mermaid
graph TD
    Start[Customer Wants to Buy USDC] --> Balance{Sufficient<br/>Fiat Balance?}

    Balance -->|NO| Reject1[REJECT<br/>Insufficient funds]
    Balance -->|YES| Limits{Within Daily<br/>Limits?}

    Limits -->|NO| Reject2[REJECT<br/>Exceeds daily limit]
    Limits -->|YES| AML{AML Screening}

    AML -->|PASS| Liquidity{Bank Has<br/>USDC Liquidity?}
    AML -->|FAIL| Reject3[REJECT<br/>Sanctions/high-risk transaction]

    Liquidity -->|YES| Instant[INSTANT PATH<br/>Allocate from inventory<br/>Duration: ~30 min]
    Liquidity -->|NO| Delayed{Can Wait for<br/>T+1 Mint?}

    Delayed -->|YES| Mint[DELAYED PATH<br/>Request mint from Circle<br/>Duration: T+1]
    Delayed -->|NO| Reject4[REJECT<br/>Cannot fulfill immediately]

    Instant --> Complete[Customer Receives USDC]
    Mint --> Complete

    style Complete fill:#d4edda
    style Instant fill:#d4edda
    style Mint fill:#fff3cd
    style Reject1 fill:#f8d7da
    style Reject2 fill:#f8d7da
    style Reject3 fill:#f8d7da
    style Reject4 fill:#f8d7da
```

**Business Rules:**
- **Daily Limit (Phase 1):** $10M per customer per day
- **Liquidity Threshold:** Bank maintains 20% buffer (if <20%, request mint)
- **AML Auto-Block:** Sanctioned addresses, high-risk jurisdictions

---

## 🔄 DECISION 4: SELL FLOW - SETTLEMENT TIMING

```mermaid
graph TD
    Start[Customer Wants to Sell USDC] --> Balance{Has Sufficient<br/>USDC Balance?}

    Balance -->|NO| Reject1[REJECT<br/>Insufficient USDC]
    Balance -->|YES| AML{AML Screening}

    AML -->|PASS| Liquidity{Bank Needs<br/>USD Liquidity?}
    AML -->|FAIL| Reject2[REJECT<br/>Suspicious activity]

    Liquidity -->|YES - Has Cash| Instant[INSTANT SETTLEMENT<br/>Credit fiat immediately<br/>Burn USDC later<br/>Duration: 30 min]
    Liquidity -->|NO - Need Redemption| Delayed[T+1 SETTLEMENT<br/>Redeem with Circle first<br/>Credit after fiat received<br/>Duration: Next business day]

    Instant --> Complete[Customer Receives Fiat]
    Delayed --> Complete

    style Complete fill:#d4edda
    style Instant fill:#d4edda
    style Delayed fill:#fff3cd
    style Reject1 fill:#f8d7da
    style Reject2 fill:#f8d7da
```

**Business Logic:**
- **Instant Settlement:** Bank has sufficient fiat reserves (80%+ of sell orders)
- **T+1 Settlement:** Large redemptions, end-of-day liquidity shortfall (20% of sell orders)

---

## 📤 DECISION 5: TRANSFER FLOW - RISK ASSESSMENT

```mermaid
graph TD
    Start[Customer Wants to Transfer USDC] --> Balance{Has Sufficient<br/>USDC Balance?}

    Balance -->|NO| Reject1[REJECT<br/>Insufficient balance]
    Balance -->|YES| Limits{Within Transfer<br/>Limits?}

    Limits -->|NO| Reject2[REJECT<br/>Exceeds daily limit]
    Limits -->|YES| Destination{Internal or<br/>External?}

    Destination -->|Internal Customer| OnUs[ON-US TRANSFER<br/>Instant, no blockchain<br/>Duration: Seconds]
    Destination -->|External Wallet| Screen{Screen Recipient<br/>Address}

    Screen -->|CLEAN| Amount{Amount ><br/>$1,000?}
    Screen -->|HIGH RISK| Review{Manual Compliance<br/>Review}
    Screen -->|SEVERE| Reject3[REJECT<br/>Sanctioned/mixer address]

    Review -->|APPROVED| Amount
    Review -->|REJECTED| Reject4[REJECT<br/>High-risk recipient]

    Amount -->|< $1,000| Execute[EXECUTE TRANSFER<br/>No Travel Rule<br/>Duration: 15-30 min]
    Amount -->|>= $1,000| Travel{Travel Rule<br/>Identify Recipient VASP}

    Travel -->|VASP Identified| Share[Share Customer Info<br/>Execute Transfer<br/>Duration: 15-30 min]
    Travel -->|VASP Not Found| Reject5[REJECT<br/>Cannot comply with Travel Rule]

    OnUs --> Complete[Transfer Complete]
    Execute --> Complete
    Share --> Complete

    style Complete fill:#d4edda
    style OnUs fill:#d4edda
    style Execute fill:#d4edda
    style Share fill:#fff3cd
    style Reject1 fill:#f8d7da
    style Reject2 fill:#f8d7da
    style Reject3 fill:#f8d7da
    style Reject4 fill:#f8d7da
    style Reject5 fill:#f8d7da
```

**Risk Categories (Chainalysis):**
- **CLEAN (0-30):** Retail wallets, known exchanges → Auto-approve
- **MEDIUM (31-70):** New addresses, high-volume → Flag for review
- **HIGH (71-90):** Indirect mixer exposure → Compliance approval required
- **SEVERE (91-100):** Direct sanctions match, mixers → Auto-block

---

## 🔍 DECISION 6: RECONCILIATION - BREAK HANDLING

```mermaid
graph TD
    Start[Daily Reconciliation Runs] --> Compare{Sub-Ledger =<br/>Blockchain?}

    Compare -->|MATCH| Report1[Generate Clean Report<br/>No action needed]
    Compare -->|BREAK DETECTED| Amount{Break Amount?}

    Amount -->|< $100| Minor[MINOR BREAK<br/>Auto-resolve next cycle<br/>Log for audit]
    Amount -->|$100 - $10K| Material[MATERIAL BREAK<br/>Treasury investigates within 24h]
    Amount -->|> $10K| Critical[CRITICAL BREAK<br/>IMMEDIATE ESCALATION]

    Material --> Investigate{Root Cause<br/>Identified?}
    Critical --> Investigate

    Investigate -->|Failed blockchain tx| Fix1[Retry transaction<br/>Update sub-ledger]
    Investigate -->|Duplicate credit| Fix2[Reverse duplicate<br/>Correct balance]
    Investigate -->|Timing difference| Fix3[Wait for settlement<br/>Re-run recon]
    Investigate -->|Unauthorized tx| Incident[SECURITY INCIDENT<br/>Freeze accounts<br/>Forensic investigation]

    Minor --> Report2[Daily Report: Minor break noted]
    Fix1 --> Report3[Daily Report: Break resolved]
    Fix2 --> Report3
    Fix3 --> Report3
    Incident --> Report4[Incident Report to Board]

    style Report1 fill:#d4edda
    style Minor fill:#fff3cd
    style Material fill:#ffc107
    style Critical fill:#f8d7da
    style Incident fill:#dc3545
```

**Break Response SLAs:**
- **Minor (<$100):** Review within 48 hours, no immediate action
- **Material ($100-$10K):** Investigate within 24 hours, resolve within 48 hours
- **Critical (>$10K):** Immediate escalation (within 1 hour), resolve within 24 hours

---

## ⚠️ DECISION 7: ERROR HANDLING - RETRY OR FAIL?

```mermaid
graph TD
    Start[Transaction Error Occurred] --> Type{Error Type?}

    Type -->|Network Timeout| Retry1{Attempts < 3?}
    Type -->|AML Service Down| Retry2{Critical Transaction?}
    Type -->|Blockchain Congestion| Retry3{Increase Gas Fee?}
    Type -->|Insufficient Funds| Fail1[FAIL IMMEDIATELY<br/>Notify customer: Top up balance]
    Type -->|Sanctions Hit| Fail2[FAIL IMMEDIATELY<br/>Block transaction + Alert compliance]
    Type -->|Invalid Address| Fail3[FAIL IMMEDIATELY<br/>Notify customer: Check address]

    Retry1 -->|YES| Wait1[Wait 10 sec<br/>Exponential backoff<br/>Retry]
    Retry1 -->|NO| Fail4[FAIL<br/>Notify customer: Service unavailable]

    Retry2 -->|YES| Queue1[Queue for later<br/>Process when service recovers]
    Retry2 -->|NO| Fail5[FAIL<br/>Notify customer: Try again later]

    Retry3 -->|YES| Boost[Increase gas by 20%<br/>Resubmit transaction]
    Retry3 -->|NO| Fail6[FAIL<br/>Notify customer: Network congested]

    Wait1 -->|Success| Success[Transaction Complete]
    Queue1 -->|Processed| Success
    Boost -->|Confirmed| Success

    style Success fill:#d4edda
    style Fail1 fill:#f8d7da
    style Fail2 fill:#dc3545
    style Fail3 fill:#f8d7da
    style Fail4 fill:#f8d7da
    style Fail5 fill:#f8d7da
    style Fail6 fill:#f8d7da
```

**Error Categories:**
- **Retryable:** Network issues, service timeouts, congestion
- **Non-Retryable:** Compliance failures, invalid input, insufficient balance
- **Escalate:** Security incidents, critical system failures

---

## 🎯 DECISION 8: CUSTOMER SUPPORT - ESCALATION PATH

```mermaid
graph TD
    Start[Customer Contacts Support] --> Issue{Issue Type?}

    Issue -->|Transaction Status| L1[L1 Support<br/>Check status in system<br/>Provide update<br/>SLA: 15 min]
    Issue -->|KYC Pending| L1
    Issue -->|Transaction Failed| L2[L2 Support<br/>Review error logs<br/>Attempt resolution<br/>SLA: 2 hours]
    Issue -->|Balance Discrepancy| L2
    Issue -->|Suspected Fraud| L3[L3 Compliance<br/>Freeze account<br/>Investigate<br/>SLA: 1 hour]
    Issue -->|System Outage| L3
    Issue -->|Regulatory Question| Legal[Legal/Compliance Team<br/>Formal response<br/>SLA: 48 hours]

    L1 -->|Resolved| Close[Ticket Closed<br/>Customer Notified]
    L1 -->|Cannot Resolve| L2

    L2 -->|Resolved| Close
    L2 -->|Cannot Resolve| L3

    L3 -->|Resolved| Close
    L3 -->|Requires Approval| Exec[Executive Review<br/>Board notification if needed]

    Exec -->|Approved| Close
    Exec -->|Escalate to Regulator| Regulator[Regulatory Filing<br/>SAR/Incident Report]

    style Close fill:#d4edda
    style L1 fill:#d1ecf1
    style L2 fill:#fff3cd
    style L3 fill:#f8d7da
    style Regulator fill:#dc3545
```

**Support Tiers:**
- **L1:** Customer service (routine inquiries, status checks)
- **L2:** Operations (technical issues, transaction troubleshooting)
- **L3:** Compliance/Security (fraud, suspicious activity, critical errors)
- **Legal:** Regulatory questions, legal disputes

---

## 📊 QUICK REFERENCE: COMMON SCENARIOS

| Scenario | Decision Path | Expected Outcome | Duration |
|----------|--------------|------------------|----------|
| **New customer applies** | Onboarding flow → KYC → AML → Approve | Account active | 1-10 days |
| **Customer buys $100K USDC** | Buy flow → Bank has liquidity → Instant | USDC credited | 30 min |
| **Customer sells $50K USDC** | Sell flow → Bank redeems with Circle → T+1 | Fiat credited next day | T+1 |
| **Customer sends to Coinbase** | Transfer flow → Screen address (CLEAN) → Execute | USDC arrives at Coinbase | 15-30 min |
| **Customer sends to mixer** | Transfer flow → Screen address (SEVERE) → Block | Transaction rejected | Instant |
| **Reconciliation finds $5K break** | Material break → Investigate → Failed tx identified → Retry | Break resolved | 24 hours |
| **Transaction fails 3 times** | Retry exhausted → Fail → Notify customer | Manual intervention | Immediate |

---

## 🔗 RELATED DOCUMENTS

- [Process Flows](./flows/ALL_FLOWS_INDEX.md) - Detailed flow documentation
- [Customer Journey Map](./CUSTOMER_JOURNEY_MAP.md) - End-to-end lifecycle
- [Glossary](./GLOSSARY.md) - Term definitions

---

**Document Owner:** Business Analysis Team
**Version:** 1.0
