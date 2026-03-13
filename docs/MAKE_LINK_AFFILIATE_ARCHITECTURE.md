# Make Link / Profit Link – Architecture & How We Achieve It

This document explains how we will implement an **EarnKaro-style** “Make Link” flow: user pastes a product URL (Flipkart, Amazon, Myntra, etc.) → gets a **custom profit link** → shares it → earns **commission** when someone buys using that link.

Reference: [EarnKaro – India's #1 Affiliate Marketing Platform](https://earnkaro.com/)

---

## 1. How EarnKaro-Style Platforms Work (Reference)

### 1.1 High-level idea

- **Users** (affiliates) do **not** have their own Flipkart/Amazon/Myntra affiliate accounts.
- The **platform** (EarnKaro / SnatchMart) has **one affiliate account per merchant** (e.g. one Flipkart Affiliate account).
- User flow:
  1. User **pastes** any product (or store) link from a supported brand.
  2. Platform **converts** it into a **trackable affiliate link** that:
     - Still opens the **same product/page** on the merchant site.
     - Adds the **platform’s** affiliate/tracking ID (so the merchant pays the platform).
     - Adds a **user identifier** (e.g. `sub_id`, `affExtParam1`) so the platform knows **which user** to credit when a sale happens.
  3. User **shares** this “Profit Link” (WhatsApp, Telegram, social, etc.).
  4. When someone **clicks** and **buys**, the merchant records the sale with the platform’s affiliate ID and the sub-id.
  5. Merchant pays **commission to the platform**. Platform **attributes** the sale to the user (via sub-id) and **credits** that user (e.g. wallet, payout to bank).

So: **one platform affiliate account + per-user sub-ids = every user gets their own “profit link” and earns when their link converts.**

### 1.2 What we need to build (conceptually)

| Piece | Purpose |
|-------|--------|
| **Link conversion** | Input: raw URL + user id → Output: affiliate URL with our tag + user sub-id. |
| **Supported merchants** | Flipkart, Amazon, Myntra, etc. – each has different URL/API rules. |
| **Storing “my links”** | Optional: save user’s generated links for “My Links” and analytics. |
| **Attribution** | When merchant reports a sale (e.g. via Report API), we read sub-id → credit the right user. |
| **Commission / payout** | Internal: credit user’s balance; later: withdraw to bank (like EarnKaro’s “AsliCash”). |

---

## 2. End-to-end flow (SnatchMart goal)

```
┌─────────────┐     Paste URL      ┌─────────────┐     Convert      ┌─────────────────┐
│   User      │ ──────────────────► │  Make Link  │ ───────────────► │  Backend        │
│  (App)      │                    │  Screen     │   POST /convert  │  (Link Service) │
└─────────────┘                    └─────────────┘                  └────────┬────────┘
       ▲                                   │                                  │
       │                                   │  Show profit link                │
       │                                   │  + Copy button                   │
       │                                   ◄──────────────────────────────────┘
       │                                   │
       │  Share link (WhatsApp, etc.)      │  Optional: save to "My Links"
       │                                   │
       └──────────────────────────────────┘

When friend clicks profit link:
  Browser → Merchant (e.g. Flipkart) with our affiliate id + user sub-id
  Friend shops → Merchant records sale → Merchant pays us (platform)
  We get report (e.g. Flipkart Report API) → We credit user by sub-id
```

- **Make Link screen (existing):** User pastes URL, taps “MAKE PROFIT LINK”. We need to call backend to **convert** that URL and show the **generated profit link** (and optionally save it).
- **Backend:** New **link-conversion** service that:
  - Detects merchant (Flipkart / Amazon / Myntra from URL).
  - Appends (or rewrites) affiliate tracking + **user sub-id**.
  - Returns the new URL and optionally persists a “user link” record.
- **Commission:** When we get order reports from the merchant (e.g. Flipkart Orders Report API with `affExtParam1` = user id), we **attribute** the order to a user and **credit** them (DB + later payout).

---

## 3. Architecture (system level)

### 3.1 Model: platform is the affiliate

- SnatchMart holds **one** Flipkart Affiliate account (id + token).
- All Flipkart “profit links” use:
  - Same **Fk-Affiliate-Id** (ours).
  - A **sub-id** in the URL (or in `affExtParam1` / `affExtParam2`) = **SnatchMart user id** (or a stable ref to the user).
- Same idea for Amazon (tag + user param), Myntra (their affiliate params), etc.

So we do **not** ask each user to have their own Flipkart/Amazon account; we use **one** account per merchant and sub-ids to attribute sales to users.

### 3.2 Components

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           Flutter App                                      │
│  • Make Link screen: paste URL → call API → show profit link + copy       │
│  • Optional: My Links list (GET /api/v1/users/me/links)                   │
│  • Optional: Earnings / commission summary                                │
└──────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ REST
                                      ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                     Backend (Spring Boot)                                  │
│                                                                           │
│  • ProfitLinkController (or MakeLinkController)                           │
│      POST /api/v1/profit-link/convert  { "url": "...", "userId": "..." }   │
│      → returns { "profitLink": "...", "merchant": "flipkart", ... }        │
│                                                                           │
│  • ProfitLinkService (or LinkConversionService)                           │
│      – Detect merchant from URL (Flipkart / Amazon / Myntra)               │
│      – Merchant-specific converters:                                      │
│          FlipkartLinkConverter:  append affid + affExtParam1=userId       │
│          AmazonLinkConverter:   append tag + custom param                 │
│          MyntraLinkConverter:    (per Myntra affiliate docs)               │
│      – Save UserProfitLink (user_id, original_url, profit_url, merchant)   │
│                                                                           │
│  • Commission / reporting (later phase)                                    │
│      – Sync orders from Flipkart Report API (affExtParam1 → user)         │
│      – UserCommission or Wallet entity; credit on confirmed order          │
└──────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS (outbound)
                                      ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  Merchants: Flipkart, Amazon, Myntra (affiliate programs + report APIs)   │
└──────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Data we need

- **UserProfitLink** (new table, optional but useful):
  - `id`, `user_id`, `original_url`, `profit_url`, `merchant` (e.g. flipkart/amazon/myntra), `created_at`.
  - Lets us show “My Links” and later tie clicks/orders to a link.
- **Commission / earnings** (later):
  - e.g. `user_commission` or `wallet`: `user_id`, `order_id` (from merchant), `amount`, `status` (pending/confirmed/paid), `merchant`, `created_at`.
  - Filled when we process merchant report APIs.

### 3.4 Link conversion logic (per merchant)

- **Flipkart**
  - Product URLs look like `https://www.flipkart.com/...` or `https://dl.flipkart.com/...`.
  - We must append (or ensure presence of):
    - `affid=<our_flipkart_tracking_id>`
    - `affExtParam1=<snatchmart_user_id>` (so Report API returns this and we credit the user).
  - Existing Flipkart Affiliate docs: [Registration](https://affiliate.flipkart.com/api-docs/af_register.html), [Report API](https://affiliate.flipkart.com/api-docs/af_report_ref.html) (Orders Report has `affExtParam1`, `affExtParam2`).
- **Amazon**
  - Associate tag in URL: `tag=<our_amazon_associate_tag>` and a custom param for user (e.g. `ref` or tracking id that we map to user).
  - We need an Amazon Associates account and then implement URL rewriting per their link format.
- **Myntra**
  - Depends on their affiliate program (network or direct). Same idea: detect Myntra domain, add their required params + our user ref.

Implementation: **one interface** `ProfitLinkConverter` with `boolean supports(String url)` and `String convert(String url, String userId)`, and one implementation per merchant.

---

## 4. Current state vs gaps

| What we have | What’s missing |
|--------------|----------------|
| **Make Link screen** (Flutter): paste URL, “MAKE PROFIT LINK” button | Backend API to convert URL and return profit link; UI to show result + copy. |
| **FlipkartAffiliateClient** (offers/DOTD); Flipkart config (id/token) | Use same Flipkart **tracking id** in generated links; add **affExtParam1=userId** in convert step. |
| **AffiliateClick** (track when user clicks a product link in app) | Not the same as “convert any URL to profit link”; we keep clicks for in-app products, and add **link conversion** for user-pasted URLs. |
| **User, Product, Merchant, Category** | **UserProfitLink** (and later commission/wallet) entities and repos. |

So the **first milestone** is: **link conversion API + wire Make Link screen to it.** Commission sync and payout come next.

---

## 5. Task breakdown (implementation order)

### Phase 1 – Link conversion (MVP)

1. **Backend: Merchant detection**
   - Add a small util or service that, given a URL, returns merchant enum/string: `FLIPKART`, `AMAZON`, `MYNTRA`, `UNKNOWN`.
   - Based on hostname (e.g. flipkart.com, dl.flipkart.com, amazon.in, myntra.com).

2. **Backend: Flipkart link converter**
   - Input: `String url`, `String snatchMartUserId`, `String flipkartAffiliateId`.
   - Parse URL; if already has `affid`, optionally replace or keep and add `affExtParam1=<userId>`.
   - If no `affid`, append `?affid=<id>&affExtParam1=<userId>` (or use `&` if query already exists).
   - Return the full profit link string.
   - Handle `dl.flipkart.com` vs `www.flipkart.com` (both are used by Flipkart).

3. **Backend: Amazon link converter (stub or minimal)**
   - Same idea: add `tag=<our_amazon_tag>` and a user param. Can return “not supported yet” or a placeholder until we have an Amazon Associates account.

4. **Backend: Make Link API**
   - `POST /api/v1/profit-link/convert` (or `/api/v1/make-link/convert`).
   - Body: `{ "url": "https://..." }` (userId from JWT or passed; prefer JWT).
   - Call merchant detector → choose converter → convert.
   - Response: `{ "profitLink": "...", "merchant": "flipkart", "originalUrl": "..." }`.
   - Optional: persist `UserProfitLink` and return `linkId` for “My Links” later.

5. **Backend: Config**
   - Use existing `flipkart.affiliate.id` for the `affid` in converted links. No need to expose token in this API.

6. **Flutter: Make Link screen**
   - On “MAKE PROFIT LINK”: call `POST /api/v1/profit-link/convert` with `url: _linkController.text`.
   - On success: show the returned `profitLink` in a read-only field or dialog; add **Copy** button (Clipboard).
   - On error (e.g. unsupported merchant): show message “We don’t support this link yet” or similar.

7. **Optional: UserProfitLink entity + save**
   - Entity: `user_id`, `original_url`, `profit_url`, `merchant`, `created_at`.
   - Save in convert API; later we can add GET “My Links” for the user.

### Phase 2 – Attribution & commission (later)

8. **Orders report sync (Flipkart)**
   - Use existing Flipkart Report API (Orders) with our token.
   - Map `affExtParam1` to SnatchMart user id; create commission record (e.g. `UserCommission`: user_id, order_id, amount, status).

9. **Wallet / balance**
   - Table or entity for user’s earned balance; update when order is confirmed in report.

10. **Payout (withdraw to bank)**
    - Like EarnKaro: user requests withdrawal; admin or automated process pays and marks as paid. Can be manual at first.

### Phase 3 – More merchants & UX

11. **Amazon Associates**
    - Register; get tag; implement full Amazon link converter and (if available) reporting.

12. **Myntra**
    - Research Myntra affiliate program; implement converter + reporting if they provide it.

13. **“SEE PARTNERS & PROFIT RATES”**
    - Static page or list: which brands we support and commission rates (from our config or copy).

---

## 6. Summary

- **EarnKaro-style** = one platform affiliate account per merchant + **sub-id = user id** in every profit link so we know who to pay.
- **SnatchMart:** We add a **link-conversion** API that takes a pasted URL and returns a **profit link** (Flipkart first: `affid` + `affExtParam1=userId`), then wire the **Make Link** screen to it and show/copy the result.
- **Later:** Sync order reports from Flipkart (and others), attribute by sub-id, credit user and add payout.

This gives a clear path from “paste link → get profit link → share → earn” with minimal scope for the first version, and a straightforward way to add more merchants and full commission/payout later.
