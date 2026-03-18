# PROMPT: Post-Discovery Integration Plan

Using the product context above and the discovery notes provided, generate a
technical integration plan tailored to this prospect's specific stack.

## 1. Integration Overview
- Where our product sits in their architecture (describe with labeled components)
- Data flow: what goes in, what comes out, where it lives
- Deployment model: SaaS / agent / hybrid — and why this fits their setup

## 2. Prerequisites
List everything they need to have in place before starting:
- Access requirements (API tokens, admin permissions, etc.)
- Infrastructure requirements (e.g., Kubernetes version, network access)
- Any configuration changes to existing tools

## 3. Step-by-Step Deployment
Number each step. For technical steps, include the actual command, config,
or code snippet using their specific tools and language.

Example format:
```
Step 1 — [Action]
[Plain English explanation]
[Code or command block if applicable]
```

## 4. Key Integration Points
For each tool in their stack that we connect to:
- Tool name
- How we connect (native connector / API / agent / webhook)
- What data flows through this connection
- Any known limitations or version requirements

## 5. Sample Code
Provide an initialization snippet in their primary language showing:
- Authentication / connection setup
- A basic first API call or configuration
- Any environment variables they'll need to set

## 6. Timeline & Complexity Estimate
- Estimated time to first value (hours / days)
- Full production deployment estimate
- Who on their team needs to be involved (DevOps, Security, Engineering)
- Complexity rating: Low / Medium / High — with justification

## 7. Potential Friction Points
Be honest. List anything that might slow them down or require extra work,
and how to address each one proactively.
