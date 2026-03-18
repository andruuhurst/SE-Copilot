# SE COPILOT — PRODUCT CONTEXT FILE
# Company: Acme Observe
# Version: 2.3 | Updated: 2026-03-01
# Owner: Jordan Lee, SE Lead
#
# This is a FULLY FILLED example. Use it as a reference when filling
# in your own context/PRODUCT_CONTEXT.md file.

---

## 1. COMPANY OVERVIEW

**Company:** Acme Observe
**Product name(s):** Acme Observe Platform, Acme Observe Edge (lightweight agent)
**Category:** Developer Observability & Incident Intelligence
**One-line value prop:** Acme Observe helps Platform Engineering teams at
mid-market SaaS companies reduce incident MTTR by automatically correlating
logs, traces, and deployment events into a single causal timeline.

**Primary ICP:** B2B SaaS companies, 150–2,000 employees, engineering-led,
running microservices on Kubernetes. Sales-assisted motion above 500 engineers.

**Key personas:**
- Economic Buyer: VP Engineering or CTO
- Champion: Staff Engineer, Platform Lead, or SRE Manager
- End User: On-call engineers and SREs
- Blocker: InfoSec (data residency concerns), FinOps (cost per GB)

---

## 2. PRODUCT MODULES & FEATURES

### Acme Observe Platform (Core)
**What it does:** Ingests logs, traces, and metrics from any source and uses
ML-based correlation to surface probable root causes during incidents — with
links to the specific deployment, config change, or dependency that caused it.

**Key capabilities:**
- Auto-correlation across logs, traces, metrics, and deployment events
- Sub-2-minute alert-to-root-cause latency
- Natural language incident summaries (plain English, not raw log dumps)
- Deployment fingerprinting — links every alert to the code change that preceded it
- SLA tracking per service with automated weekly digest

**Who cares about this:** Staff Engineers and SRE Managers (champion persona)
**Key differentiator:** Unlike Datadog, we don't require instrumentation changes.
We ingest from existing CloudWatch, Prometheus, and OpenTelemetry exporters.
Zero agent installation required for observability coverage.

---

### Acme Observe Edge (Lightweight Agent)
**What it does:** A 4MB binary that runs as a sidecar or DaemonSet and adds
deep trace-level context without requiring code changes from the dev team.

**Key capabilities:**
- eBPF-based tracing (no SDK changes required)
- Auto-discovery of services in a Kubernetes namespace
- Works alongside existing Datadog or Prometheus — does not replace them

**Who cares about this:** Platform teams who can't mandate SDK changes to
product engineering teams.
**Key differentiator:** eBPF approach means zero developer friction —
Platform team deploys it once, all services get coverage.

---

## 3. INTEGRATIONS & TECH STACK SUPPORT

### Cloud Providers
- AWS: CloudWatch (logs + metrics), X-Ray (traces), EKS, EC2, Lambda, RDS,
  SQS, SNS, EventBridge
- GCP: Cloud Logging, Cloud Monitoring, GKE, Cloud Run, Pub/Sub
- Azure: Azure Monitor, AKS, Azure Functions, Application Insights
- Multi-cloud: supported — single pane across providers

### CI/CD & Deployment
- GitHub Actions (native integration — deployment events auto-captured)
- GitLab CI (webhook-based)
- ArgoCD (GitOps deployment events)
- Jenkins (plugin available)
- Spinnaker (webhook)
- Terraform (state change tracking via provider plugin)

### Observability (existing tools we sit alongside)
- Datadog (ingest from Datadog API — no migration required)
- Prometheus + Grafana (native scrape)
- OpenTelemetry (OTLP endpoint — drop-in)
- Jaeger, Zipkin (trace ingest)
- PagerDuty (bi-directional: receive alerts, close incidents)
- OpsGenie (bi-directional alert sync)

### Data & Streaming
- Kafka (consumer lag monitoring + event correlation)
- AWS Kinesis
- Databricks (job failure correlation)
- Snowflake (query performance anomaly detection)

### Auth & Identity
- Okta (SAML 2.0 + SCIM provisioning)
- Azure AD (SAML 2.0)
- Google Workspace (OAuth)
- GitHub SSO

### Languages & SDKs
- Native SDKs: Python, Go, Node.js/TypeScript, Java, Ruby, .NET, Rust
- REST API: Yes (full API parity with UI)
- Webhooks: Yes (outbound on any alert condition)
- GraphQL: No
- OpenTelemetry SDK: preferred instrumentation path for new services

### Notification & Collaboration
- Slack (bot — incident alerts + natural language query)
- Microsoft Teams (connector)
- PagerDuty / OpsGenie (see above)
- Jira (auto-create incident tickets with correlated context)

---

## 4. PAIN POINT → USE CASE LIBRARY

### 4a. Platform / SRE Teams

PAIN: Engineers are paged at 2am with a raw alert and no context — they spend
the first 30–60 minutes just figuring out what changed.
SOLUTION: Auto-correlation engine (Core Platform)
HOW: When an alert fires, Acme Observe surfaces the deployment that preceded it,
the services whose error rate spiked, and a plain-English summary — all within
90 seconds of alert creation.
OUTCOME: A Series C FinTech (300 engineers) reduced average MTTR from 47 min
to 14 min within 60 days. On-call page volume dropped 38%.
TRIGGER PHRASE: "We spend more time figuring out what happened than fixing it"

---

PAIN: Every new microservice is a blind spot — dev teams ship without adding
instrumentation, so Platform has no visibility until something breaks.
SOLUTION: Acme Observe Edge (eBPF agent)
HOW: Platform deploys a single DaemonSet — all services in the namespace get
automatic trace coverage with zero SDK changes. No PR required from product teams.
OUTCOME: A B2B SaaS company (120 engineers) went from 40% service coverage to
95% coverage in one afternoon without touching a single application.
TRIGGER PHRASE: "We can't get dev teams to add instrumentation"

---

PAIN: The on-call rotation is burning people out — same engineers paged
repeatedly, alerts are noisy and often not actionable.
SOLUTION: Alert correlation + noise reduction (Core Platform)
HOW: Groups related alerts into a single incident, suppresses flapping alerts,
and only pages when the correlated root cause is confirmed. Reduces alert volume
by grouping downstream symptoms under the root cause event.
OUTCOME: Median alert-to-page ratio improved from 18:1 to 3:1 for a DevOps
tools company (180 engineers). On-call morale surveys improved measurably.
TRIGGER PHRASE: "Our on-call rotation is killing morale" / "Alert fatigue"

---

### 4b. Engineering Leadership (VP Eng / CTO)

PAIN: No visibility into which services are causing the most engineering toil —
incidents feel random and reactive, not measurable.
SOLUTION: SLA tracking + weekly digest (Core Platform)
HOW: Tracks error budget burn, incident frequency, and MTTR per service.
Weekly digest surfaces the top 3 "reliability debt" services with trend lines.
OUTCOME: VPs use this to prioritize reliability work in quarterly planning.
One customer redirected a 2-engineer sprint to fix their top toil generator
after seeing the data — incident volume dropped 60% the following quarter.
TRIGGER PHRASE: "I have no idea which services are our biggest reliability risk"

---

PAIN: New SREs and on-call engineers take 6+ months to become effective —
tribal knowledge about the system is locked in senior engineers' heads.
SOLUTION: Natural language incident summaries + historical context (Core Platform)
HOW: Every incident generates a plain-English summary with links to similar
past incidents, runbooks matched by similarity, and the on-call actions taken.
New engineers can effectively triage from day 1.
OUTCOME: A company that onboarded 8 engineers at once reported that new hires
were handling incidents independently within 3 weeks instead of 3 months.
TRIGGER PHRASE: "We're scaling the team but incident quality is suffering"

---

### 4c. By Industry Vertical

**FinTech / Payments:**
- Common pain: Real-time transaction pipelines — any latency spike has direct
  revenue impact. Plus compliance requires audit trail of all incidents.
- Relevant features: Sub-2-min correlation, Kafka consumer lag monitoring,
  auto-generated incident audit log (SOC2 friendly)
- Compliance angle: Incident audit log exports directly to SOC2 evidence folders
- Common stack: AWS + Kafka + Go/Python + Datadog (existing)

**Healthcare SaaS:**
- Common pain: HIPAA-compliant logging — can't send PHI to third-party tools.
  Need observability without data leaving their VPC.
- Relevant features: On-premise deployment option (Enterprise tier),
  VPC-isolated log ingestion, zero PHI in Acme Observe data plane
- Key talking point: Logs stay in customer's environment; only metadata
  (timestamps, service names, error codes) leaves the VPC.

**E-commerce / Retail:**
- Common pain: Peak traffic events (Black Friday, launches) — need confidence
  that the system will hold, and fast recovery if it doesn't.
- Relevant features: Deployment fingerprinting (know exactly what changed
  before the peak), traffic anomaly detection, auto-scaling event correlation
- Seasonal angle: "Most customers deploy a freeze + enhanced monitoring
  playbook 2 weeks before peak. We can help you build that."

**Developer Tools / API Platform Companies:**
- Common pain: Multi-tenant reliability — one noisy customer can degrade
  service for all tenants, and it's hard to isolate the source.
- Relevant features: Per-tenant SLA tracking, Kafka partition lag per
  consumer group, service-to-service dependency mapping
- Key differentiator: We can attribute infrastructure cost AND reliability
  impact down to a tenant ID if they pass it through their trace context.

---

## 5. PRICING & PACKAGING

### Starter (Free)
- Up to 5 users, 3 services monitored
- 3-day log retention
- No SSO, no integrations (manual log upload only)
- Best for: Individual engineers evaluating the product

### Growth ($800/month)
- Up to 25 users, unlimited services
- 30-day retention
- All cloud integrations (AWS, GCP, Azure)
- GitHub Actions + GitLab + ArgoCD deployment events
- Slack + PagerDuty integration
- Best for: Startups and mid-market with 20–200 engineers
- Qualification signal: Running Kubernetes, has an SRE function or on-call rotation

### Enterprise (Custom — starts ~$3,000/month)
- Unlimited users
- 90-day retention (up to 1 year with add-on)
- SSO (Okta, Azure AD, Google)
- SCIM provisioning
- On-premise / VPC deployment option
- Dedicated CSM + 4-hour SLA
- Custom data retention, audit logs, SOC2 evidence export
- Qualification signal: >200 engineers OR regulated industry (FinTech, Healthcare)
  OR multi-region / on-prem requirement OR security review needed

**Expansion motion:**
Land on Growth with the Platform team (SRE / on-call use case) →
expand to Enterprise when: headcount passes 200, they mention SSO requirement,
or they're undergoing SOC2 audit.

---

## 6. COMPETITIVE LANDSCAPE

### vs. Datadog
WE WIN WHEN: Prospect is drowning in Datadog alerts with no correlation;
has alert fatigue; or is shocked by Datadog's per-host pricing at scale.
THEY WIN WHEN: Prospect needs APM depth, custom metrics dashboarding,
or already has significant Datadog investment and isn't in pain.
KEY DIFFERENTIATOR: We correlate; Datadog aggregates. We don't require
instrumentation changes. We complement Datadog rather than replacing it.
OBJECTION HANDLING: "We already use Datadog" →
  "We hear that a lot — most of our customers keep Datadog for dashboards
   and metrics. We sit on top of it and add the correlation layer that
   tells you WHY an alert fired, not just that it fired. Setup takes
   about 20 minutes — want to try it against your last 3 incidents?"

### vs. Honeycomb
WE WIN WHEN: Prospect can't mandate OpenTelemetry instrumentation across
all their services; wants automatic coverage; or needs deployment correlation.
THEY WIN WHEN: Prospect has greenfield services, strong engineering culture
around instrumentation, and wants deep query flexibility over raw trace data.
KEY DIFFERENTIATOR: Honeycomb requires structured events sent by the app.
We work with what they already have — no instrumentation prerequisite.
OBJECTION HANDLING: "We're evaluating Honeycomb too" →
  "Honeycomb is excellent if your team will instrument everything.
   The question is: how much of your fleet is actually instrumented today?
   If the answer is less than 80%, we'll give you coverage faster."

### vs. Grafana Stack (self-hosted)
WE WIN WHEN: Prospect is spending engineering time maintaining their
Grafana + Loki + Tempo stack and wants to stop.
THEY WIN WHEN: Prospect has strong infrastructure team, wants full control,
and is cost-sensitive at scale.
KEY DIFFERENTIATOR: Total cost of ownership. Self-hosted Grafana stacks
have hidden maintenance costs — we make that concrete.
OBJECTION HANDLING: "We'll just use Grafana" →
  "Totally valid — a lot of companies start there. The question we always
   ask is: how many engineer-hours/month does your team spend maintaining
   the stack? At 200+ engineers, that typically runs 0.5–1 FTE. Want to
   put a number on it for your team?"

### vs. Build In-House
Common objection: "We'll just build a correlation layer ourselves."
Response talking points:
  "We built what you're describing. It took us 18 months, 4 engineers,
   and we're still iterating. The first version took 3 months and covered
   40% of incidents. The hard part isn't the MVP — it's handling edge cases,
   maintaining it as your stack changes, and keeping it fast at scale.
   We'd rather you use those 4 engineers to build your product."

---

## 7. REFERENCE ARCHITECTURES

### Small / Startup (20–100 engineers)
**Typical stack:** AWS EKS + GitHub Actions + PostgreSQL (RDS) +
Node.js or Python microservices + existing Datadog or no observability
**Our deployment:** SaaS. 20-minute setup.
1. Connect AWS CloudWatch via IAM role (read-only)
2. Install GitHub Actions integration (OAuth)
3. Optionally deploy Edge agent as DaemonSet (if deeper tracing needed)
**What they keep:** Datadog for dashboards. We add correlation on top.
**Setup time:** 20–45 minutes to first correlated incident

---

### Mid-Market (100–500 engineers)
**Typical stack:** AWS or GCP + Kubernetes + Kafka + Python/Go/Java mix +
Terraform + Datadog or Prometheus + PagerDuty
**Our deployment:** SaaS + Edge agent.
1. CloudWatch or Prometheus scrape config (15 min)
2. GitHub Actions / ArgoCD deployment events (20 min)
3. Edge agent DaemonSet deployment (30 min with Helm)
4. PagerDuty bi-directional sync (10 min)
5. Slack bot (5 min)
**What they keep:** All existing tools. We are additive.
**Integration points:** Prometheus (metrics), GitHub (deploys), PagerDuty (alerts)
**Setup time:** Half-day for full production rollout

---

### Enterprise (500+ engineers)
**Typical stack:** Multi-cloud + service mesh (Istio/Linkerd) + Kafka +
Snowflake or Databricks + Okta SSO + dedicated security review required
**Our deployment:** VPC-isolated or on-premise option.
1. Security review (we provide SOC2 Type II report + architecture diagram)
2. SSO via Okta (SAML 2.0 + SCIM provisioning)
3. VPC peering or on-prem agent deployment
4. Multi-cloud log ingestion configuration
5. Salesforce / Jira integration for incident ticketing
**Who needs to be involved:** DevOps/Platform team, InfoSec, IT (SSO)
**Setup time:** 3–5 days with dedicated onboarding CSM

---

## 8. OBJECTION HANDLING

| Objection | Response |
|-----------|----------|
| "No budget right now" | "Understood — when does your next budget cycle open? Most customers start with our Growth trial and build the ROI case with real incident data before going to finance." |
| "We already use Datadog" | "We complement Datadog — most of our customers keep it. We add the 'why did this alert fire' layer on top. 20-minute setup. Want to try it against your last incident?" |
| "Security won't approve a SaaS tool" | "We have SOC2 Type II and an Enterprise on-prem option where logs never leave your VPC. Happy to do a security review call with your InfoSec team." |
| "We'll build this ourselves" | "Totally possible. We'd estimate 3–6 months for a working MVP. What's the opportunity cost of that engineering time on your roadmap?" |
| "We don't have an SRE team" | "That's actually a common reason customers come to us — when everyone's on-call and no one owns reliability tooling, we give them coverage without the headcount." |
| "We're too small for this" | "If you have an on-call rotation and more than 10 services, you'll get ROI. Our Growth plan is $800/month — one fewer incident per month pays for it." |
| "Datadog already does this" | "Datadog aggregates and alerts. We correlate across logs, traces, and deploys to tell you the cause. Different layer — most customers run both." |

---

## 9. PROOF POINTS

### FinTech (Series C, 300 engineers, AWS + Kafka + Go)
Pain: 3 major payment processing incidents per quarter, avg 47-min MTTR,
regulatory pressure to demonstrate incident response controls.
Deployed: Core Platform + GitHub Actions integration
Result: MTTR reduced to 14 min (70% improvement). On-call pages down 38%.
SOC2 auditor accepted Acme Observe incident log exports as evidence.

### Healthcare SaaS (250 employees, HIPAA environment, AWS VPC-isolated)
Pain: Needed observability without PHI leaving their environment.
All third-party tools blocked by InfoSec.
Deployed: Enterprise on-prem deployment inside their VPC.
Result: First observability coverage across all services. No PHI leaves
the customer environment — only metadata ingested by Acme Observe.
Zero InfoSec findings.

### Developer Tools Company (120 engineers, GCP + Python + self-hosted Grafana)
Pain: 1 SRE spending 40% of time maintaining Grafana/Loki stack.
Deployed: Core Platform replacing self-hosted stack.
Result: SRE reclaimed ~16 hours/week. Stack maintenance eliminated.
Incident correlation reduced average time-to-diagnose from 35 min to 8 min.

---

## 10. DEMO GUIDANCE

**Best first demo flow:**
1. Show a pre-built incident timeline (don't start with setup/config)
2. Click into the correlated root cause — show the deployment link
3. Show the natural language summary
4. Show how to set up a new alert in under 60 seconds
5. Show the Slack bot in action

**"Aha moment":** When they see a real incident correlated to the
exact deployment commit that caused it — especially if it matches
something they've actually experienced.

**POC success criteria (30 days):**
- At least 1 real production incident correlated by Acme Observe
- On-call team members use it independently (not just the champion)
- MTTR for that incident is measurably lower than their baseline

**Time to first value:** 20 minutes (first correlated alert)

**Common demo pitfalls:**
- Don't start with the dashboard — start with the incident timeline
- Don't show the configuration UI early — SREs want to see outcomes first
- Don't demo in a blank environment — use the pre-loaded demo tenant
  with realistic incident data
