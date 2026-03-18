# CONTEXT_GUIDE.md
# How to fill in your PRODUCT_CONTEXT.md

This guide explains what to write in each section and how specific to be.
The golden rule: **Claude's output quality directly mirrors your input quality.**

---

## Section 1 — Company Overview

**Value prop formula:** "[Company] helps [WHO — be specific] to [OUTCOME] by [MECHANISM]."

Good example:
> "Acme Observe helps Platform Engineering teams at mid-market SaaS companies
> reduce incident MTTR by automatically correlating logs, traces, and deployment
> events in a single timeline."

Bad example:
> "Acme Observe helps companies with observability."

**ICP tip:** Name a company size range AND a motion (product-led vs. sales-led
matters because it changes which persona is the champion).

---

## Section 2 — Modules & Features

For each module, the most important field is **Key Differentiator**.
This is what Claude uses to distinguish your product from competitors.

**Differentiator tip:** Don't say "easy to use" or "powerful." Say something
structurally different:
> "Unlike Datadog, we don't require agents on every host — we ingest from
>  CloudWatch and existing Prometheus exporters, so there's zero instrumentation."

---

## Section 3 — Integrations

This section is what enables Claude to say "here's exactly how it connects
to your Kafka + GKE + Terraform stack" rather than giving generic advice.

**Be exhaustive here.** Even list integrations that are partial or in beta —
just note them as such. Omitting an integration means Claude won't surface it.

Format tip: Use the exact product names prospects use:
- "AWS EKS" not just "Kubernetes"
- "GitHub Actions" not just "CI/CD"
- "dbt Core + dbt Cloud" not just "dbt"

---

## Section 4 — Pain Points & Use Cases

This is the most important section. Spend the most time here.

**The TRIGGER PHRASE field is critical.** It's the exact words a prospect
uses in a discovery call when they have this pain. Claude uses it to match
your use cases to what a prospect says.

Example trigger phrases:
- "We only find out about data pipeline failures when a dashboard is wrong"
- "Our on-call rotation is killing morale"
- "We're spending more time maintaining our monitoring setup than building product"

**Adding new use cases over time:**
After every deal — won or lost — ask yourself: "What was the real pain?"
Add it here in the PAIN → OUTCOME format. Over 6 months, this section
becomes incredibly powerful.

---

## Section 5 — Pricing

**Don't skip this.** Claude needs pricing context to help AEs qualify
prospects into the right tier and build ROI narratives.

If you can't share exact pricing in this file, write the *signals* instead:
> "Enterprise qualification signal: mentions SSO requirement, >500 employees,
>  or references a regulated industry (finance, healthcare, government)."

---

## Section 6 — Competitive

**Be honest about where competitors win.** A battle card that pretends
your product is better in every scenario is useless. Claude will give
better advice if you're truthful about trade-offs.

---

## Section 7 — Reference Architectures

Write these as if explaining to a new SE what a typical customer's
environment looks like. Use real tool names, not categories.

Good:
> "Typical mid-market stack: AWS EKS + GitHub Actions + Terraform +
>  PostgreSQL (RDS) + Datadog (current monitoring). Our product deploys
>  as a Helm chart to their existing cluster and scrapes Prometheus metrics
>  from their existing exporters."

This is what allows Claude to generate integration steps with actual
`helm install` commands and config snippets.

---

## Section 8 — Objection Handling

Source these from real calls. Ask your top SE: "What's the hardest
objection you handle?" Add those verbatim.

---

## Section 9 — Proof Points

Even anonymized proof points ("a Fortune 500 financial services company")
dramatically improve Claude's output quality. Specific numbers beat
directional claims every time.

---

## Maintenance Tips

- **Monthly review:** Block 30 minutes at the start of each month.
- **After every major win:** Add the use case and outcome to Section 4 and 9.
- **After every major loss:** Add the objection and handling to Section 8.
- **After every product release:** Update Sections 2 and 3 immediately.
- **Version control:** Every meaningful update should be a Git commit with
  a descriptive message so teammates know what changed.

---

## File size guidance

| Context file size | Performance |
|-------------------|-------------|
| < 2,000 words | Too thin — Claude gives generic answers |
| 2,000–6,000 words | Good for most SE workflows |
| 6,000–15,000 words | Excellent — detailed and specific |
| > 15,000 words | Consider splitting by product line |
