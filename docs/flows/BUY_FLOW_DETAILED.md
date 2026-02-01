# BUY STABLECOIN FLOW - DETAILED
## Customer Purchases Stablecoin with Fiat Currency

**Document Type:** Business Process Flow
**Audience:** Business Analysts, Developers, QA, Compliance
**Last Updated:** February 2026

---

## OVERVIEW

**Business Process:** Customer buys stablecoin (e.g., USDC) using fiat currency (e.g., USD)

**Trigger:** Customer initiates "Buy USDC" transaction via portal or API

**Duration:** 30 minutes (typical)
- Fiat receipt: 0-24 hours (wire transfer time)
- Compliance screening: <2 seconds
- Stablecoin allocation: 15-30 minutes (if on-chain) OR instant (if sub-ledger only)

**Frequency:** 1,000+ per day (Phase-1 target)

---

## ACTORS

| Actor | Role | System |
|-------|------|--------|
| **Customer** | Initiates buy order | Banking Portal / API |
| **Transaction Service** | Orchestrates buy process | Java microservice |
| **Compliance Service** | Screens for AML/sanctions | Python microservice |
| **ATLAS** | Debits customer's fiat account | Core Banking System |
| **Custody Service** | Allocates stablecoin to customer | Go microservice |
| **Issuer (Circle)** | Mints USDC (if needed) | External API |
| **Blockchain** | Stores token balances | Ethereum Mainnet |

---

## PREREQUISITES

Before customer can buy:
- ✅ Customer is onboarded (KYC approved)
- ✅ Customer has active account (not suspended)
- ✅ Customer has sufficient USD balance OR provides wire instructions
- ✅ Customer has not exceeded daily limits

---

## STEP-BY-STEP FLOW

### STEP 1: Customer Initiates Buy Order

**Actor:** Customer

**Action:**
1. Customer logs into banking portal (MFA required)
2. Navigates to "Buy Stablecoin"
3. Selects currency: USDC
4. Enters amount: $100,000
5. System displays:
   - **Amount to receive:** 100,000 USDC
   - **Fee:** $250 (0.25%)
   - **Total cost:** $100,250
   - **Exchange rate:** 1 USD = 1 USDC
   - **Estimated time:** 30 minutes
6. Customer clicks "Confirm"

**System Response:**
- Creates order ID: `ORD-2026-02-01-12345`
- Displays: "Processing... Do not close this window"

---

### STEP 2: Pre-Flight Validations

**Actor:** Transaction Service

**Validations:**

| Check | Query | Pass Criteria | Fail Action |
|-------|-------|---------------|-------------|
| **Account Status** | Query customer DB | Status = "Active" | Reject: "Account suspended" |
| **KYC Current** | Query KYC DB | Expiry date > today | Reject: "KYC expired, please renew" |
| **Compliance Hold** | Query compliance flags | No active holds | Reject: "Account under review" |
| **Balance Check** | Query ATLAS | USD balance ≥ $100,250 OR wire instructions provided | Request payment |
| **Daily Limit** | Query transaction history | Today's buys + $100K ≤ daily limit ($500K) | Reject: "Daily limit exceeded" |
| **Single Tx Limit** | Transaction amount | $100K ≤ single limit ($250K) | Reject: "Transaction too large" |

**If ALL validations pass:**
- Update order status: `VALIDATED`
- Proceed to Step 3

**If ANY validation fails:**
- Update order status: `REJECTED`
- Notify customer with specific reason
- **END FLOW**

---

### STEP 3: Fiat Receipt & Compliance Screening

**Actor:** ATLAS + Compliance Service

#### 3A: Fiat Receipt

**Scenario A:** Customer has sufficient USD balance (debit immediately)
```
ATLAS API Call: POST /accounts/debit
{
  "customer_id": "CUST123456",
  "account": "USD_CHECKING",
  "amount": 100250.00,
  "reference": "ORD-2026-02-01-12345",
  "description": "Buy 100,000 USDC"
}

Response:
{
  "status": "success",
  "transaction_id": "ATLAS-TX-789",
  "new_balance": 49750.00
}
```

**Scenario B:** Customer sends wire transfer (wait for receipt)
- Provide wire instructions:
  ```
  Bank Name: [Our Bank]
  ABA Routing: 123456789
  Account: Stablecoin Buy Orders
  Reference: ORD-2026-02-01-12345
  Amount: $100,250.00
  ```
- Wait for wire receipt (0-24 hours)
- ATLAS posts incoming wire → Triggers notification to Transaction Service
- Proceed to compliance screening

---

#### 3B: Compliance Screening

**Actor:** Compliance Service

**AML Screening (Automated):**

```python
# Pseudo-code
def screen_transaction(customer_id, amount, type):
    # Rule 1: Structuring Check
    if count_transactions(customer_id, last_24h) >= 3 and all_amounts_near_threshold():
        return ALERT("Possible structuring")

    # Rule 2: Rapid Movement
    if last_transaction_type == "BUY" and time_since_last < 1_hour:
        return ALERT("Rapid buy pattern, potential layering")

    # Rule 3: High-Risk Geography
    if customer_country in ["Iran", "North Korea", "Syria"]:
        return REJECT("Sanctioned country")

    # Rule 4: Large Transaction
    if amount > 10000:
        file_CTR()  # Currency Transaction Report

    # Rule 5: Unusual Pattern
    if amount > (avg_monthly_amount * 10):
        return ALERT("Unusual transaction size")

    # Default: Approve
    return APPROVE()
```

**Sanctions Screening:**
```
API Call: POST https://api.dowjones.com/screen
{
  "entity_type": "person",
  "name": "John Doe",
  "dob": "1985-05-15",
  "country": "USA"
}

Response:
{
  "match_status": "no_match",
  "matches": []
}
```

**Possible Outcomes:**

| Outcome | Action | Timeline |
|---------|--------|----------|
| **APPROVED** | Proceed to Step 4 | <2 seconds |
| **ALERT (Medium Risk)** | Queue for manual review | 4-24 hours |
| **REJECTED (High Risk)** | Block transaction + File SAR | Immediate |

**If APPROVED:** Update order status `COMPLIANCE_APPROVED`, proceed to Step 4

**If ALERT:** Update order status `PENDING_REVIEW`, notify compliance analyst, **PAUSE FLOW**

**If REJECTED:** Update order status `COMPLIANCE_REJECTED`, return fiat to customer, **END FLOW**

---

### STEP 4: Check USDC Liquidity

**Actor:** Custody Service

**Query:** How much USDC does bank currently have available?

```sql
SELECT SUM(balance) as available_usdc
FROM omnibus_wallets
WHERE currency = 'USDC' AND wallet_type = 'HOT';

Result: 5,000,000 USDC
```

**Decision:**

| Condition | Action |
|-----------|--------|
| Available USDC ≥ Customer Order (100K) | ✅ Proceed to Step 5 (sufficient liquidity) |
| Available USDC < Customer Order | ⚠️ Request mint from issuer (see Step 4B) |

---

#### STEP 4B: Request Mint from Issuer (If Needed)

**Actor:** Custody Service → Circle (Issuer)

**Scenario:** Bank only has 50K USDC available, but customer wants 100K

**Action:**
```
API Call: POST https://api.circle.com/v1/mint
{
  "amount": "100000.00",
  "currency": "USD",
  "destination_address": "0xBANK_OMNIBUS_WALLET",
  "reference": "BANK-MINT-2026-02-01-001"
}

Headers:
Authorization: Bearer [CIRCLE_API_KEY]

Response:
{
  "mint_id": "CIRCLE-MINT-789456",
  "status": "pending",
  "estimated_completion": "2026-02-01T10:45:00Z"
}
```

**Circle's Process:**
1. Receives $100K wire from bank's nostro account
2. Confirms receipt (T+0 or T+1)
3. Triggers smart contract `mint()` function on Ethereum
4. Mints 100K USDC to bank's omnibus wallet (on-chain transaction, ~15 min)
5. Sends webhook to bank:
   ```json
   {
     "mint_id": "CIRCLE-MINT-789456",
     "status": "completed",
     "blockchain_tx_id": "0xabc123...",
     "confirmations": 12
   }
   ```

**Bank Action:**
- Update liquidity pool: +100K USDC
- Resume customer order (proceed to Step 5)

**Timeline:** 15-30 minutes (if instant mint) OR 2-4 hours (if manual review by Circle)

---

### STEP 5: Allocate USDC to Customer

**Actor:** Custody Service

**Two Models:**

#### **Model A: Sub-Ledger Allocation (Recommended for Phase-1)**

**Description:** Customer's USDC is tracked in internal database (sub-ledger), not as separate on-chain wallet initially.

**Process:**
```sql
-- Update sub-ledger
UPDATE customer_wallets
SET usdc_balance = usdc_balance + 100000
WHERE customer_id = 'CUST123456';

-- Log transaction
INSERT INTO transactions (customer_id, type, amount, timestamp, order_id)
VALUES ('CUST123456', 'BUY', 100000, NOW(), 'ORD-2026-02-01-12345');
```

**Advantages:**
- ✅ Instant (no blockchain delay)
- ✅ No gas fees
- ✅ Easy reconciliation (all customers in one omnibus wallet on-chain)

**Disadvantages:**
- ⚠️ Customer doesn't have unique on-chain wallet (yet)
- ⚠️ Customer cannot withdraw to external wallet (Phase-1 limitation)

---

#### **Model B: On-Chain Allocation (Phase-2)**

**Description:** Customer gets unique on-chain wallet; USDC transferred on-chain.

**Process:**
```javascript
// Construct on-chain transaction
const tx = {
  from: OMNIBUS_WALLET_ADDRESS,  // Bank's wallet
  to: CUSTOMER_WALLET_ADDRESS,    // Customer's wallet (0x123...)
  value: 0,                        // No ETH transfer
  data: usdcContract.methods.transfer(
    CUSTOMER_WALLET_ADDRESS,
    100000 * 1e6  // USDC has 6 decimals
  ).encodeABI()
};

// Sign with HSM
const signedTx = await hsm.sign(tx);

// Broadcast to Ethereum
const txHash = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

// Wait for confirmations
await waitForConfirmations(txHash, 12);  // ~3 minutes

// Update sub-ledger
updateSubLedger(customer_id, +100000, txHash);
```

**Advantages:**
- ✅ Customer has true on-chain ownership
- ✅ Customer can withdraw to external wallets
- ✅ Interoperable with other VASPs

**Disadvantages:**
- ⚠️ Slower (3-15 minutes)
- ⚠️ Gas fees ($5-50 depending on network)
- ⚠️ More complex reconciliation

---

### STEP 6: Update Order Status & Notify Customer

**Actor:** Transaction Service

**Actions:**
1. Update order status: `COMPLETED`
2. Record completion timestamp
3. Update customer's transaction history
4. Generate receipt

**Customer Notification:**

**Email:**
```
Subject: Your purchase of 100,000 USDC is complete

Dear John,

Your stablecoin purchase has been completed:

- Amount: 100,000 USDC
- Cost: $100,250 (including $250 fee)
- Order ID: ORD-2026-02-01-12345
- Timestamp: 2026-02-01 10:45:00 UTC
- Your new USDC balance: 100,000 USDC

View details: [Link to portal]

Questions? Contact support@bank.com

[Bank Name] - Stablecoin Services
```

**SMS:**
```
USDC purchase complete. 100,000 USDC credited to your wallet. Order ORD-12345. View: [short link]
```

**Portal UI:**
```
✅ Transaction Complete
   100,000 USDC
   Order ORD-2026-02-01-12345
   [View Receipt] [View Wallet]
```

---

### STEP 7: Accounting & Reconciliation (End-of-Day)

**Actor:** Reconciliation Service (automated, nightly batch)

**Accounting Entries (ATLAS):**
```
DR  Customer USD Account          $100,250
    CR  Stablecoin Omnibus Account           $100,000
    CR  Fee Revenue                           $250
```

**Sub-Ledger Entry:**
```
Customer: CUST123456
Wallet: W-123456
Transaction: BUY
Amount: +100,000 USDC
Fee: $250
Balance After: 100,000 USDC
```

**Reconciliation Check (Daily):**
```
1. Sum all customer balances in sub-ledger: 5,000,000 USDC
2. Query omnibus wallet on Ethereum: 5,000,000 USDC
3. Compare: ✅ MATCH
4. Generate reconciliation report (signed by treasury manager)
```

**If mismatch:** Alert treasury team, investigate within 4 hours

---

## FAILURE SCENARIOS & HANDLING

### Scenario 1: Sanctions Hit

**Point of Failure:** Step 3B (Compliance Screening)

**Detection:**
```
Sanctions Screening API returns:
{
  "match_status": "confirmed_match",
  "matches": [
    {
      "name": "John Doe",
      "list": "OFAC-SDN",
      "score": 95
    }
  ]
}
```

**Action:**
1. **Immediately freeze transaction**
2. Update order status: `COMPLIANCE_REJECTED`
3. **Do NOT issue USDC**
4. Return fiat to customer (hold funds for 24-48h per OFAC requirements)
5. **File SAR** (Suspicious Activity Report) with FinCEN within 30 days
6. Suspend customer account pending investigation
7. Notify senior compliance officer
8. Document decision in AML case management system

**Customer Communication:**
```
"Your transaction cannot be completed due to compliance requirements.
Our compliance team will contact you within 24 hours."
```

**Regulatory Filing:**
```
SAR Narrative:
"Customer John Doe (DOB: 1985-05-15) attempted to purchase $100,000 USDC
on 2026-02-01. Sanctions screening returned confirmed match (score: 95)
on OFAC-SDN list. Transaction blocked. No funds issued. Account suspended."
```

---

### Scenario 2: Issuer (Circle) Unable to Mint

**Point of Failure:** Step 4B (Request Mint)

**Detection:**
```
Circle API response:
{
  "status": "error",
  "message": "Mint requests temporarily suspended due to reserve audit"
}
```

**Action:**
1. **Notify customer of delay:**
   ```
   "Your order is processing. Due to temporary system maintenance
   with our partner, your USDC will be available in 2-4 hours."
   ```
2. Treasury team escalates to Circle account manager
3. **Options:**
   - Wait for Circle to resume (if <4 hours expected)
   - Source USDC from secondary market (OTC desk, DEX)
   - If >24h delay: Offer refund to customer

**Customer Options:**
- Wait for completion
- Cancel order (full refund, no fee)

**SLA:** If delay >24 hours, automatically refund + apologize

---

### Scenario 3: Blockchain Network Congestion

**Point of Failure:** Step 5 (On-Chain Allocation, Model B only)

**Detection:**
```
Gas price spiked: 500 gwei (normal: 20 gwei)
Estimated transaction cost: $200 (normal: $10)
Transaction pending for 30 minutes (expected: 3 minutes)
```

**Action:**
1. **Notify customer:**
   ```
   "Due to high blockchain network activity, your transaction
   is taking longer than usual. Estimated completion: 1-2 hours."
   ```
2. **Options:**
   - **Wait:** Transaction will eventually confirm (may take hours)
   - **Speed up:** Replace transaction with higher gas fee (customer approves added cost)
   - **Cancel:** Refund customer, retry later

**Customer Choice Prompt:**
```
Your transaction is delayed due to network congestion.

Option 1: Wait (free, may take 1-2 hours)
Option 2: Speed up (+$150 gas fee, confirm in 10 minutes)
Option 3: Cancel & refund (no fee)

What would you like to do?
```

---

### Scenario 4: ATLAS System Down

**Point of Failure:** Step 3A (Fiat Debit)

**Detection:**
```
ATLAS API Call: POST /accounts/debit
Response: 503 Service Unavailable
```

**Action:**
1. **Retry** (exponential backoff: 30s, 1m, 5m)
2. If still failing after 3 attempts:
   - **Pause all buy orders** (display maintenance message)
   - Notify customers: "Stablecoin buy service temporarily unavailable. Sell and transfer services are operational."
   - Alert treasury team + IT operations
3. When ATLAS recovers:
   - Resume queued orders
   - Process in FIFO order
   - Notify customers: "Service restored. Your order is processing."

**SLA:** If ATLAS down >2 hours, executive escalation (CFO, CTO)

---

## PERFORMANCE METRICS

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Transaction Success Rate** | >99% | (Successful orders / Total orders) × 100 |
| **Average Completion Time** | <30 minutes | From order placed to USDC credited |
| **Compliance Screening Time** | <2 seconds | Step 3B duration |
| **Customer Satisfaction** | >85% NPS | Post-transaction survey |
| **False Positive Rate (AML)** | <5% | (False alerts / Total alerts) × 100 |

---

## COMPLIANCE REQUIREMENTS

### Recordkeeping (7 Years)

Must retain:
- Order details (amount, timestamp, customer ID, order ID)
- Compliance screening results (AML scores, sanctions queries)
- Fiat transaction records (ATLAS transaction IDs)
- Blockchain transaction hashes (if on-chain model)
- Customer notifications (emails, SMS)

### Regulatory Reporting

| Report Type | Trigger | Deadline | Recipient |
|-------------|---------|----------|-----------|
| **CTR** (Currency Transaction Report) | Transaction >$10K | Within 15 days | FinCEN (US) |
| **SAR** (Suspicious Activity Report) | Sanctions hit, suspicious pattern | Within 30 days | FinCEN (US) |
| **FATCA** (Foreign Account) | US person account | Annually | IRS (US) |
| **MiCA Reporting** | Monthly volumes (if EU) | Quarterly | ECB / National regulator |

---

## TESTING SCENARIOS

### Unit Tests (Automated)

```javascript
describe('Buy Flow', () => {
  it('should complete buy when all validations pass', async () => {
    // Given: Customer with active account, sufficient balance
    // When: Customer initiates buy for 100K USDC
    // Then: Order status = COMPLETED, balance = +100K USDC
  });

  it('should reject buy when daily limit exceeded', async () => {
    // Given: Customer has already bought $450K today (limit: $500K)
    // When: Customer tries to buy $100K USDC
    // Then: Order rejected with "Daily limit exceeded"
  });

  it('should block buy when sanctions hit', async () => {
    // Given: Customer name matches OFAC-SDN list
    // When: Compliance screening runs
    // Then: Order rejected, SAR filed
  });
});
```

### Integration Tests

- End-to-end buy flow (staging environment)
- ATLAS integration (debit USD, verify posting)
- Circle API integration (mint request, webhook)
- Blockchain interaction (if on-chain model)

### User Acceptance Testing (UAT)

- Business analyst performs buy as customer
- Verify: UI displays correct amounts, fees, confirmations
- Verify: Email/SMS notifications received
- Verify: Transaction appears in history

---

## NEXT STEPS

- **Sell flow:** See `SELL_FLOW_DETAILED.md`
- **Transfer flow:** See `TRANSFER_FLOW_ONCHAIN.md`
- **API contracts:** See `../contracts/` folder

---

**Document Owner:** Business Analysis Team
**Review Frequency:** Quarterly or upon process changes
**Version:** 1.0
