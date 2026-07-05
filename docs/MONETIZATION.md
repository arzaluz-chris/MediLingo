# MediLingo — Monetization & Financial Plan

## Model: Freemium (No Intrusive Ads)

### Free Tier
- Intro lessons (first 2 modules per path)
- Basic vocabulary
- Limited hearts (5/day, refill 1 every 4 hours)
- Limited flashcard reviews
- No AI conversations

### Premium Tier
- All courses + specialty paths
- Unlimited hearts
- Unlimited AI conversations
- Pronunciation evaluation
- Offline mode
- Advanced analytics dashboard
- Downloadable certificates
- Priority access to new content

## Pricing

| Region | Monthly | Annual | Savings |
|--------|---------|--------|---------|
| Mexico | 179 MXN | 1,199 MXN | ~44% |
| International | $9.99 USD | $69.99 USD | ~42% |

ARPU (after Apple commission + discounts): ~$8 USD/month.

## Implementation

- **StoreKit 2** for iOS subscriptions
- **RevenueCat** for cross-platform management, analytics, A/B pricing
- Support Family Sharing + Student discounts
- No banner ads. At most: optional ad to earn heart refill (future)

## Conversion Assumptions (Conservative)

- Downloads → active user: 35%
- Active users → premium subscriber: 5%
- Reference: Duolingo converts 6-10%

## Projections (Conservative)

| Month | Downloads | Active | Premium | Revenue | Costs | Profit |
|-------|-----------|--------|---------|---------|-------|--------|
| 1 | 500 | 175 | 9 | $72 | $400 | -$328 |
| 3 | 3,000 | 1,000 | 50 | $400 | $400 | $0 |
| 6 | 10,000 | 3,500 | 175 | $1,400 | $600 | $800 |
| 12 | 40,000 | 14,000 | 700 | $5,600 | $1,000 | $4,600 |

Break-even: ~Month 3. Year 1 profit (cumulative): ~$24,500.

## Projections (Optimistic — viral TikTok/content)

| Year | Downloads | Active | Premium | Revenue/mo |
|------|-----------|--------|---------|------------|
| 1 | 100,000 | 35,000 | 2,000 | $16,000 |
| 3 | 300,000 | — | 15,000 | $120,000 |
| 6 | 1,000,000 | — | 50,000 | $400,000 |

## Monthly Operating Costs (Year 1)

| Item | USD/month |
|------|-----------|
| Supabase Pro | $25 |
| Storage/CDN | $10 |
| AI APIs | $50 |
| Domain/Email | $12 |
| Marketing | $300 |
| **Total** | **~$400** |
| Without marketing | ~$100 |

## Initial Investment

- Minimum: $500 USD
- Comfortable: $1,500 USD
- Aggressive: $3,000 USD

## Future Revenue Streams

- **B2B/Institutional**: Hospital + university licenses, admin dashboards
- **Certification fees**: Premium verified certifications
- **White-label**: MediLingo platform licensed to medical schools
- **Referral program**: Invite friend → both get 1 week Premium + gems + unlock

## Marketing Strategy

Primary acquisition: personal brand ("Mi Doctor Chris").

| Channel | Content Type |
|---------|-------------|
| TikTok | 30-60s: "¿Sabías que rash no es rascarse?", pronunciation mistakes |
| Instagram Reels | Same format, repurposed |
| YouTube Shorts | Wider reach, medical English tips |
| LinkedIn | Professional audience, hospitals, recruiters |

Educational content drives organic installs. Low CAC — existing audience.