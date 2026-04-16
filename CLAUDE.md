# Dishboard ROI Calculator — Project Knowledge Base

## What this project is
A single-file interactive ROI calculator for Dishboard.io sales demos.
Built as a standalone HTML file using Alpine.js + Tailwind CSS (both CDN, no build step).
Shows restaurant owners how much money they lose through manual processes and how much they'd save with Dishboard.

**Live URL:** https://tomislav-db.github.io/dishboard-roi-calculator
**GitHub repo:** git@github.com:tomislav-db/dishboard-roi-calculator.git
**Main file:** `dishboard-roi-calculator.html` (also copied to `index.html` for clean URL)

---

## Deploying changes

SSH is configured. Just run:
```bash
~/deploy.sh
```
This copies the calculator to `index.html`, commits, and pushes. Site updates within ~1 minute.

**SSH key location:** `~/.ssh/id_ed25519` (already added to GitHub account `tomislav-db`)
No tokens needed — SSH handles authentication permanently.

---

## Calculator structure

5-step wizard:
1. **Country** — UK / Czech Republic / Slovakia
2. **Business type** — FSR / QSR / Bar / Café
3. **Numbers** — monthly revenue, food cost %, invoices/month (bar also has pour cost, revenue split)
4. **Plan** — Starter / Professional / Premium + Cost Radar add-on + invoice volume
5. **Results** — 4 cards + summary ROI strip

Tech: Alpine.js reactive state (`x-data`, `x-model`, `x-show`, `x-text`), Tailwind v3 CDN, `requestAnimationFrame` counter animation on results.

---

## Country configuration (in code, ~line 840)

| Country | Currency | Symbol | Admin rate | Revenue defaults |
|---------|----------|--------|------------|-----------------|
| UK | GBP | £ (prefix) | £15/hr | FSR £55k, QSR £35k, Bar £30k, Café £20k |
| CZ | CZK | Kč (suffix) | 250 Kč/hr | FSR 1.2M, QSR 800k, Bar 650k, Café 450k |
| SK | EUR | € (prefix) | €8.5/hr | FSR €20k, QSR €13k, Bar €11k, Café €7.5k |

Revenue benchmarks represent the ICP (software-adopting operators, £500k+/year equivalent), NOT national averages which include micro-businesses.

---

## ROI formulas — the gastro consultant logic

### Card 1: Food Cost Savings
**What it measures:** Operational efficiency improvement — less waste, better ordering, portion control. Driven by the operator's own behaviour improving with Dishboard visibility.

```js
foodSavingsRate() based on food cost %:
  < 28%  → 1pp saving (rate = 0.01) — already well-controlled
  28–32% → 2pp saving (rate = 0.02) — industry average
  32–37% → 3pp saving (rate = 0.03) — above average, meaningful room
  > 37%  → 4pp saving (rate = 0.04) — high leakage, transformative

foodCostSavings() = annualFoodBevSpend() × foodSavingsRate()

For bars: foodSavingsRate() uses pourCostPercent (not foodCostPercent) as reference.
Bar savings applied to (bevSpend + foodSpend) combined.
```

**Why food_spend × rate (not revenue × pp):**
Using `food_spend × rate` is deliberately conservative. The economically exact formula for "3pp reduction" would be `revenue × 3%` — which gives much larger numbers. We use the smaller base intentionally to avoid overselling.

**Pour cost ideal range (bars):** 18–24%. Above this = room for improvement.
**Food cost ideal range:** FSR 28–30%, QSR/Café 25–28%.

---

### Card 2: Cost Leakage Recovery
**What it measures:** Overcharges, duplicate invoices, pricing errors surfaced when real-time visibility replaces manual processes. Front-loaded (most found in early months).

**Basis:** Beverley Hills Diner saved £1,300 in month 1 on £45k/month revenue = 0.24% of annual revenue.

```js
transparencySavingsRate() based on ratio of monthlyRevenue / benchmark.revenue:
  < 0.4×  → 0.8%  (very lean, minimal controls — lots to surface)
  0.4–0.8× → 0.5% (below-average controls)
  0.8–2.0× → 0.35% (typical operator)
  > 2.0×  → 0.24% (larger operator, Beverley Hills baseline)

errorSavings() = annualRevenue() × transparencySavingsRate()
```

**Logic:** Smaller operations have less infrastructure (no bookkeeper, no systems) so more errors slip through. Larger operators already catch more, so savings proportionally less. Uses benchmark.revenue from the current country/type config — so it's currency-neutral.

---

### Card 3: Cost Radar Savings (add-on, conditional)
**What it measures:** Supplier price increases detected immediately vs going unnoticed for 6-10 weeks. Operator challenges, renegotiates, or switches supplier before loss compounds.

**DISTINCT from Card 1** — this is about what SUPPLIERS do to you, not your own operational efficiency. A perfectly-run restaurant (at 25% food cost, Card 1 gives almost nothing) can still lose €6k in 4 months to an unnoticed meat price change.

**Basis:** Beverley Hills £8,000/year on ~£178k food spend = 4.5% of food spend. Using 3.5% is conservative.

```js
radarSavings() = annualFoodBevSpend() × 0.035
```

Only counted in gross ROI if `hasCostRadar = true`. If not selected, shown as "potential upside" on Card 3 with different styling.

**No cannibalization with Card 1:** Different mechanisms. Card 1 = your efficiency with same prices. Card 3 = protection from supplier price changes. Genuinely additive.

---

### Card 4: Time Returned (informational — not in monetary ROI)
**What it shows:** Hours saved per month and per year. Presented as a genuine co-equal benefit, not a footnote.

```js
hoursSavedPerMonth() = linear from 15 hrs/mo at 50 invoices → 30 hrs/mo at 200 invoices (capped)
formula: 15 + (min(invoices, 200) - 50) × (15/150), capped at 30

hoursSavedPerYear() = hoursSavedPerMonth() × 12
```

**For small venues:** time returned IS the primary value. Card 4 is styled prominently (violet, same visual weight as monetary cards) so it doesn't feel like a consolation prize.

---

### Summary strip
```
Gross Annual Savings = foodCostSavings + errorSavings + (hasCostRadar ? radarSavings : 0)
Dishboard cost = (plan price + radar add-on + invoice overage) × 12
Net Annual ROI = max(0, Gross - Dishboard cost)
ROI multiple = Gross / Dishboard cost (shown as "for every £1 spent, you save £X")
```

---

## Pricing (as of build date)

| Tier | UK | CZ | SK |
|------|----|----|-----|
| Starter | £70/mo | 1,725 Kč/mo | €70/mo |
| Professional | £115/mo | 2,825 Kč/mo | €115/mo |
| Premium | £165/mo | 3,990 Kč/mo | €165/mo |
| Cost Radar add-on | £40/mo | 5,000 Kč/mo | €40/mo |
| Invoice block (+50) | £20/mo | 500 Kč/mo | €20/mo |

Invoice slider: 150 (included), 200, 250, 300. Auto-set in Step 4 by rounding up from Step 3 invoice count.

---

## Key design decisions (do not reverse without good reason)

- **Labor savings excluded from ROI** — user decision. Time is shown as Card 4 (informational) only. Do not add a £ value to hours saved.
- **No payback period shown** — removed as it showed "Day 1" which was misleading.
- **No "Most Popular" badge** on plan cards — removed, just show 3 clean plan cards.
- **No yellow tier indicator boxes in Step 3** — removed as background info not for customer view.
- **Estimated savings NOT shown in Step 3** — only revealed on the results page to preserve the "reveal" moment.
- **Food savings formula uses food_spend × rate** (not revenue × pp) — deliberately conservative.

---

## Case studies referenced in logic

| Business | Key data | Used for |
|----------|----------|----------|
| Beverley Hills Diner & Bar (UK) | £1,300 saved month 1, ~£45k/mo revenue | Card 2 floor rate (0.24%) |
| Beverley Hills (Cost Radar) | £8,000/year from Cost Radar, ~£178k food spend = 4.5% | Card 3 rate basis |
| Bistro Lagom (UK) / Automat Matuška (CZ) | 15 spreadsheets eliminated, 35 hrs/month saved, 4% pour cost reduction | Time savings formula, food savings |
| Bistro Karel (CZ) | Replaced full-time person's admin workload | Card 4 narrative |
| Beer Brothers (Operators→Owners) | Multiple venues, zero additional hires | General narrative |
| Restaurant (meat price) | €6k lost in 4 months unnoticed | Cost Radar rationale |
| Pizzeria | 23% flour price increase undetected | Cost Radar rationale |

---

## Stress test results (validated scenarios)

| Scenario | Gross savings | % of revenue | Verdict |
|----------|--------------|--------------|---------|
| UK FSR £55k/mo, 30% FC, no Radar | £6,270/yr | 0.95% | ✓ Conservative, honest |
| UK FSR £55k/mo, 30% FC, + Radar | £9,240/yr | 1.4% | ✓ Solid |
| UK FSR £150k/mo, 33% FC, + Radar | £39,960/yr | 2.2% | ✓ Defensible, case-study backed |
| SK FSR €30k/mo, 33% FC, + Radar | €8,982/yr | 2.5% | ✓ Realistic, stress-tested |
| UK Bar £30k/mo, 22% pour, no Radar | £2,448/yr | 0.68% | ✓ Modest, honest for well-run bar |
