# ATLAS API INTEGRATION CONTRACTS
## Core Banking System Integration

**Document Type:** Technical Specification - API Contracts
**Audience:** Backend Developers, Integration Team, ATLAS Vendor
**Last Updated:** February 2026

---

## OVERVIEW

This document defines API contracts between the Stablecoin Platform and ATLAS (Core Banking System).

**Integration Type:** REST API (primary) with SOAP fallback
**Authentication:** OAuth 2.0 Client Credentials + mTLS
**Protocol:** HTTPS only (TLS 1.3+)
**Data Format:** JSON (primary), XML (SOAP fallback)
**Idempotency:** All write operations use idempotency keys
**Retry:** Exponential backoff (30s, 1m, 5m)

---

## AUTHENTICATION

### OAuth 2.0 Token Endpoint

**Request:**
```http
POST https://atlas.bank.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=stablecoin-platform
&client_secret=[SECRET]
&scope=accounts.read accounts.write gl.write
```

**Response:**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "accounts.read accounts.write gl.write"
}
```

**Token Usage:**
```http
Authorization: Bearer eyJhbGci...
```

---

## API ENDPOINTS

### 1. DEBIT CUSTOMER ACCOUNT (Buy Stablecoin)

**Endpoint:** `POST /api/v1/accounts/debit`

**Purpose:** Debit customer's USD account when they buy stablecoin

**Request:**
```json
{
  "idempotency_key": "ORD-2026-02-01-12345",
  "customer_id": "CUST123456",
  "account_number": "1234567890",
  "amount": 100250.00,
  "currency": "USD",
  "reference": "Buy 100,000 USDC",
  "transaction_type": "STABLECOIN_BUY",
  "metadata": {
    "order_id": "ORD-2026-02-01-12345",
    "stablecoin_amount": 100000,
    "stablecoin_currency": "USDC",
    "fee": 250.00
  }
}
```

**Response (Success):**
```json
{
  "status": "success",
  "transaction_id": "ATLAS-TX-789456",
  "customer_id": "CUST123456",
  "account_number": "1234567890",
  "amount_debited": 100250.00,
  "currency": "USD",
  "new_balance": 49750.00,
  "timestamp": "2026-02-01T10:30:45Z",
  "reference": "Buy 100,000 USDC"
}
```

**Response (Error - Insufficient Funds):**
```json
{
  "status": "error",
  "error_code": "INSUFFICIENT_FUNDS",
  "error_message": "Account balance ($50,000) is less than requested debit ($100,250)",
  "customer_id": "CUST123456",
  "account_number": "1234567890",
  "available_balance": 50000.00
}
```

**Error Codes:**
| Code | HTTP Status | Description | Action |
|------|-------------|-------------|--------|
| `INSUFFICIENT_FUNDS` | 400 | Balance < debit amount | Reject transaction, notify customer |
| `ACCOUNT_NOT_FOUND` | 404 | Invalid account number | Reject, log error |
| `ACCOUNT_FROZEN` | 403 | Account has legal hold | Reject, notify compliance |
| `DUPLICATE_TRANSACTION` | 409 | Idempotency key already used | Return original response |
| `INTERNAL_ERROR` | 500 | ATLAS system error | Retry with backoff |

**Idempotency:**
- If same `idempotency_key` sent twice → Return original response (do NOT double-debit)
- Idempotency keys retained for 24 hours

---

### 2. CREDIT CUSTOMER ACCOUNT (Sell Stablecoin)

**Endpoint:** `POST /api/v1/accounts/credit`

**Purpose:** Credit customer's USD account when they sell stablecoin

**Request:**
```json
{
  "idempotency_key": "ORD-2026-02-01-98765",
  "customer_id": "CUST123456",
  "account_number": "1234567890",
  "amount": 49875.00,
  "currency": "USD",
  "reference": "Sell 50,000 USDC",
  "transaction_type": "STABLECOIN_SELL",
  "metadata": {
    "order_id": "ORD-2026-02-01-98765",
    "stablecoin_amount": 50000,
    "stablecoin_currency": "USDC",
    "fee": 125.00
  }
}
```

**Response (Success):**
```json
{
  "status": "success",
  "transaction_id": "ATLAS-TX-789457",
  "customer_id": "CUST123456",
  "account_number": "1234567890",
  "amount_credited": 49875.00,
  "currency": "USD",
  "new_balance": 99625.00,
  "timestamp": "2026-02-01T14:20:10Z",
  "reference": "Sell 50,000 USDC"
}
```

**Error Codes:**
| Code | HTTP Status | Description | Action |
|------|-------------|-------------|--------|
| `ACCOUNT_NOT_FOUND` | 404 | Invalid account number | Reject, investigate |
| `ACCOUNT_CLOSED` | 410 | Account closed | Reject, escalate |
| `DUPLICATE_TRANSACTION` | 409 | Idempotency key used | Return original |
| `INTERNAL_ERROR` | 500 | ATLAS error | Retry |

---

### 3. QUERY ACCOUNT BALANCE

**Endpoint:** `GET /api/v1/accounts/{account_number}/balance`

**Purpose:** Check customer's available USD balance before buy transaction

**Request:**
```http
GET /api/v1/accounts/1234567890/balance
Authorization: Bearer [TOKEN]
X-Customer-ID: CUST123456
```

**Response:**
```json
{
  "account_number": "1234567890",
  "customer_id": "CUST123456",
  "currency": "USD",
  "available_balance": 150000.00,
  "pending_balance": 5000.00,
  "total_balance": 155000.00,
  "overdraft_limit": 0.00,
  "account_status": "ACTIVE",
  "timestamp": "2026-02-01T10:25:00Z"
}
```

**Fields:**
- `available_balance`: Can be withdrawn/debited immediately
- `pending_balance`: Funds on hold (e.g., check clearing)
- `total_balance`: available + pending
- `account_status`: ACTIVE, FROZEN, CLOSED

---

### 4. QUERY CUSTOMER DETAILS

**Endpoint:** `GET /api/v1/customers/{customer_id}`

**Purpose:** Retrieve customer master data for onboarding sync

**Request:**
```http
GET /api/v1/customers/CUST123456
Authorization: Bearer [TOKEN]
```

**Response:**
```json
{
  "customer_id": "CUST123456",
  "customer_type": "CORPORATE",
  "legal_name": "ABC Manufacturing Inc.",
  "trading_name": "ABC Mfg",
  "registration_number": "12-3456789",
  "tax_id": "98-7654321",
  "incorporation_date": "2010-05-15",
  "country_of_incorporation": "USA",
  "primary_contact": {
    "name": "John Doe",
    "title": "CFO",
    "email": "john@abcmfg.com",
    "phone": "+1-555-123-4567"
  },
  "registered_address": {
    "line1": "123 Main Street",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "country": "USA"
  },
  "account_status": "ACTIVE",
  "kyc_status": "APPROVED",
  "kyc_expiry_date": "2027-01-01",
  "risk_rating": "LOW",
  "relationship_manager": "RM-456"
}
```

---

### 5. POST GENERAL LEDGER ENTRIES (End-of-Day)

**Endpoint:** `POST /api/v1/gl/batch`

**Purpose:** Post stablecoin transaction journal entries to GL

**Request:**
```json
{
  "batch_id": "GL-BATCH-2026-02-01",
  "posting_date": "2026-02-01",
  "source_system": "STABLECOIN",
  "entries": [
    {
      "entry_id": "GL-001",
      "account_code": "1100-CUSTOMER-USDC-WALLET",
      "debit": 0,
      "credit": 100000,
      "currency": "USD-EQUIVALENT",
      "description": "Customer buy USDC",
      "reference": "ORD-2026-02-01-12345",
      "customer_id": "CUST123456"
    },
    {
      "entry_id": "GL-002",
      "account_code": "2100-USDC-OMNIBUS-WALLET",
      "debit": 100000,
      "credit": 0,
      "currency": "USD-EQUIVALENT",
      "description": "Omnibus wallet allocation",
      "reference": "ORD-2026-02-01-12345"
    },
    {
      "entry_id": "GL-003",
      "account_code": "4500-FEE-REVENUE",
      "debit": 0,
      "credit": 250,
      "currency": "USD",
      "description": "USDC buy fee",
      "reference": "ORD-2026-02-01-12345",
      "customer_id": "CUST123456"
    }
  ]
}
```

**Response:**
```json
{
  "status": "posted",
  "batch_id": "GL-BATCH-2026-02-01",
  "atlas_batch_id": "ATLAS-GL-56789",
  "posting_date": "2026-02-01",
  "entries_posted": 3,
  "posted_at": "2026-02-02T00:05:30Z",
  "errors": []
}
```

**Error Response (Partial Failure):**
```json
{
  "status": "partial_failure",
  "batch_id": "GL-BATCH-2026-02-01",
  "entries_posted": 2,
  "entries_failed": 1,
  "errors": [
    {
      "entry_id": "GL-002",
      "error_code": "INVALID_ACCOUNT_CODE",
      "error_message": "Account code 2100-USDC-OMNIBUS-WALLET not found in chart of accounts"
    }
  ]
}
```

**Retry Logic:**
- Retry batch 3 times (1 min, 5 min, 15 min intervals)
- If still failing → Create ops ticket → Manual GL entry

---

### 6. INCOMING WIRE NOTIFICATION (Webhook)

**Endpoint:** `POST https://stablecoin.bank.com/api/webhooks/atlas/wire-received`

**Purpose:** ATLAS notifies stablecoin platform when wire is received

**Request (from ATLAS):**
```json
{
  "event_type": "WIRE_RECEIVED",
  "wire_id": "WIRE-2026-02-01-45678",
  "timestamp": "2026-02-01T09:15:30Z",
  "sender": {
    "name": "ABC Manufacturing Inc.",
    "bank_name": "Bank of America",
    "aba_routing": "026009593",
    "account_number": "XXXX5678"
  },
  "receiver": {
    "account_number": "9876543210",
    "account_name": "Stablecoin Buy Orders"
  },
  "amount": 100250.00,
  "currency": "USD",
  "reference": "ORD-2026-02-01-12345",
  "wire_details": "Buy 100,000 USDC"
}
```

**Response (from Stablecoin Platform):**
```json
{
  "status": "received",
  "wire_id": "WIRE-2026-02-01-45678",
  "matched_order": "ORD-2026-02-01-12345",
  "action": "processing_buy_order"
}
```

**If No Match:**
```json
{
  "status": "unmatched",
  "wire_id": "WIRE-2026-02-01-45678",
  "action": "manual_review_required",
  "reason": "Reference ORD-2026-02-01-12345 not found in pending orders"
}
```

---

## DATA SYNCHRONIZATION

### Customer Master Data Sync

**Frequency:** Real-time (event-driven) + Daily batch (reconciliation)

**Event-Driven (ATLAS → Stablecoin Platform):**
- Customer onboarded in ATLAS → Webhook to stablecoin platform
- Customer KYC updated → Webhook
- Customer account status changed (frozen, closed) → Webhook

**Daily Batch:**
- Full customer extract (CSV or JSON)
- Delivered via SFTP or S3
- Stablecoin platform reconciles: Detect new customers, status changes

---

## ERROR HANDLING

### Transient Errors (Retry)

| Error | HTTP Status | Retry Strategy |
|-------|-------------|----------------|
| Connection timeout | 504 | Retry 3x (exponential backoff) |
| Rate limit | 429 | Wait 60s, retry |
| Internal server error | 500 | Retry 3x |
| Service unavailable | 503 | Retry 3x |

### Permanent Errors (Do Not Retry)

| Error | HTTP Status | Action |
|-------|-------------|--------|
| Unauthorized | 401 | Refresh OAuth token, retry |
| Forbidden | 403 | Alert ops team (permissions issue) |
| Not found | 404 | Log error, reject transaction |
| Bad request | 400 | Log error, reject (client error) |

---

## SECURITY

### Transport Security
- **TLS 1.3** only (TLS 1.2 fallback allowed)
- **Certificate Pinning:** Validate ATLAS certificate against known CA

### Authentication
- **OAuth 2.0:** Client credentials flow
- **Token Expiry:** 1 hour (refresh before expiry)
- **Secret Rotation:** Every 90 days

### Data Encryption
- **At Rest:** N/A (ATLAS handles)
- **In Transit:** TLS 1.3

### IP Whitelisting
- **ATLAS API:** Only accept requests from stablecoin platform IPs (203.0.113.0/24)
- **Stablecoin Webhooks:** Only accept from ATLAS IPs (198.51.100.0/24)

---

## PERFORMANCE REQUIREMENTS

| Metric | Requirement | Measurement |
|--------|-------------|-------------|
| **Response Time (p95)** | <500ms | API Gateway metrics |
| **Throughput** | 100 TPS (transactions/second) | Load testing |
| **Availability** | 99.95% (4 hours downtime/year) | Uptime monitoring |
| **Error Rate** | <0.1% | Error logs |

---

## TESTING

### Unit Tests
```javascript
describe('ATLAS API Integration', () => {
  it('should debit account successfully', async () => {
    const response = await atlasClient.debitAccount({
      idempotency_key: 'TEST-001',
      customer_id: 'CUST123',
      amount: 1000,
      currency: 'USD'
    });
    expect(response.status).toBe('success');
  });

  it('should handle insufficient funds error', async () => {
    await expect(
      atlasClient.debitAccount({ amount: 999999 })
    ).rejects.toThrow('INSUFFICIENT_FUNDS');
  });
});
```

### Integration Tests
- **Staging Environment:** Test against ATLAS UAT
- **Scenarios:**
  - Successful debit/credit
  - Insufficient funds
  - Account not found
  - Network timeout (simulate)

---

## MONITORING & ALERTING

### Metrics to Monitor
- API call latency (p50, p95, p99)
- Error rate (by endpoint, error code)
- Request volume (TPS)
- OAuth token refresh failures

### Alerts
- **Critical:** API availability <99% → Page on-call engineer
- **Warning:** Error rate >1% → Slack alert
- **Info:** Response time p95 >500ms → Log for review

---

## DISASTER RECOVERY

### ATLAS Outage Scenario

**Detection:**
- Health check fails (3 consecutive failures)
- All API calls return 503 or timeout

**Action:**
1. **Pause all stablecoin buy/sell transactions** (display maintenance message)
2. **Alert treasury team + ATLAS vendor**
3. **Customer communication:** "Stablecoin services temporarily unavailable due to scheduled maintenance. Expected restoration: [time]"
4. **Monitor ATLAS status page**
5. **Resume services** when health check passes
6. **Process queued transactions** (FIFO order)

**SLA:** If ATLAS down >2 hours → Executive escalation

---

## APPENDIX

### Sample Chart of Accounts

| Account Code | Account Name | Type |
|--------------|--------------|------|
| 1100-CUSTOMER-USDC-WALLET | Customer USDC Wallet (Off-BS Memo) | Asset (Memo) |
| 2100-USDC-OMNIBUS-WALLET | USDC Omnibus Wallet | Asset (Memo) |
| 4500-FEE-REVENUE | Stablecoin Transaction Fees | Revenue |
| 1000-CASH | Cash & Cash Equivalents | Asset |
| 2000-CUSTOMER-DEPOSITS | Customer Deposits | Liability |

---

**Document Owner:** Integration Team Lead
**Review Frequency:** Quarterly or upon ATLAS API changes
**Version:** 1.0
