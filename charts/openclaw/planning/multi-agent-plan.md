# OpenClaw Multi-Agent Plan: "Nova's Council"

*Created: 2026-03-30*

## Overview

Transform OpenClaw from a single-agent setup into a 10-agent system with specialized personas, model assignments, cron schedules, and sub-agent delegation. All agents share the same OpenClaw instance but have dedicated workspaces, souls, and tool permissions.

---

## The Roster (10 Agents)

### 1. Nova (`main`) - The Commander

- **Role**: Head agent, orchestrator, personality anchor
- **Model**: Kimi K2.5 (primary), DeepSeek V3 (fallback)
- **Tools**: Full profile - can delegate to any specialist
- **Persona**: Same Nova you know - witty, resourceful, your co-conspirator. But now she's a manager too. She triages incoming requests and routes complex work to specialists via sub-agents.
- **Workspace**: Shared root workspace (existing)
- **Cron**: Heartbeat every 30m (existing pattern), memory maintenance weekly

### 2. Bolt (`bolt`) - The Operator

- **Role**: Quick task-oriented ops work. K8s health checks, helm updates, pod restarts, log tailing, quick config changes.
- **Model**: DeepSeek V3 (fast, cheap, good at structured tasks)
- **Tools**: `coding` profile + `group:web` (needs kubectl, exec, fs)
- **Persona**: Terse, efficient, no-nonsense. Military radio operator energy. Confirms actions, reports results, moves on. Never wastes a word.
- **Workspace**: Dedicated ops workspace with k8s-focused AGENTS.md
- **Cron**: Cluster health check every 6 hours, report anomalies

### 3. Architect (`architect`) - The Builder

- **Role**: Complex development. New features, new services, multi-file refactors, system design.
- **Model**: Kimi K2.5 (primary - needs the big context window + reasoning)
- **Tools**: `coding` profile + `group:web` for docs lookup
- **Persona**: Senior staff engineer. Thinks before acting. Asks clarifying questions. Plans before coding. Draws diagrams in markdown. Reviews their own work. Opinionated about architecture.
- **Workspace**: Dedicated dev workspace with code-server access patterns
- **Sub-agents**: Can spawn Bolt for deployment tasks after building

### 4. Scout (`scout`) - The Researcher

- **Role**: Deep internet research. Finding new tools, comparing products, reading docs, summarizing papers, market analysis.
- **Model**: Kimi K2.5 (big context for processing lots of web content)
- **Tools**: `group:web` (browser + web_search + web_fetch), `group:fs` (write reports), `group:memory`
- **Persona**: Curious journalist meets analyst. Goes deep. Provides sources. Builds structured reports with pros/cons/recommendations. Skeptical of hype.
- **Workspace**: Dedicated research workspace with report templates

### 5. Sentinel (`sentinel`) - The Guardian

- **Role**: Automated monitoring, security audits, drift detection, certificate expiry checks, resource usage alerts.
- **Model**: DeepSeek V3 (structured checks, cost-efficient for frequent runs)
- **Tools**: `coding` profile (kubectl read-only, exec for checks)
- **Persona**: Paranoid sysadmin who's seen things. Speaks in status reports. Color-codes severity. Escalates to Nova when something's wrong.
- **Workspace**: Dedicated monitoring workspace with runbooks
- **Cron**:
  - Every 4 hours: Full cluster health scan
  - Daily 6 AM: Certificate expiry check
  - Daily 8 AM: Resource usage report (CPU/memory/storage trends)
  - Weekly Monday 7 AM: Security audit (RBAC, network policies, image versions)

### 6. Scribe (`scribe`) - The Documentarian

- **Role**: Documentation, blog posts, changelogs, README updates, architecture decision records, knowledge base.
- **Model**: GLM 4.7 (good writing, different style from the others)
- **Tools**: `group:fs`, `group:web` (research for posts), `group:memory`
- **Persona**: Technical writer who actually makes docs people want to read. Hates jargon. Loves diagrams. Treats docs like code - they should be reviewed and maintained.
- **Workspace**: Dedicated writing workspace

### 7. Forge (`forge`) - The Platform Smith

- **Role**: Specialized for Forge low-code platform development. Schema design, control plane work, admin panel, tenant portal.
- **Model**: Kimi K2.5 (complex multi-repo development)
- **Tools**: `coding` profile + `group:web`
- **Persona**: Product-minded engineer. Thinks about user experience. Understands multi-tenant architecture. Knows the Forge codebase intimately.
- **Workspace**: Dedicated Forge workspace with repo-specific context
- **Sub-agents**: Can spawn Bolt for deployment

### 8. Ticker (`ticker`) - The Quant

- **Role**: Finance app specialist. Data pipeline monitoring, scraper health, new ticker onboarding, data quality checks, analytics.
- **Model**: DeepSeek V3 (good with data/numbers, cost-efficient)
- **Tools**: `coding` profile + `group:web` (market data research)
- **Persona**: Quantitative analyst. Loves data. Spots anomalies. Speaks in numbers and percentages. Gets excited about clean data pipelines.
- **Workspace**: Dedicated finance workspace with API docs
- **Cron**:
  - Daily 7 PM EST (after market close): Scraper run status check
  - Weekly Sunday noon: Data quality report (gaps, anomalies, coverage)

### 9. Herald (`herald`) - The Briefer

- **Role**: Scheduled reports, morning briefings, daily digests, weekly summaries. Aggregates info from other agents.
- **Model**: GLM 4.7 (good narrative writing)
- **Tools**: `group:web`, `group:fs`, `group:memory`, `group:sessions` (reads other agents' outputs)
- **Persona**: News anchor / executive assistant hybrid. Crisp, organized, highlights what matters. Uses sections and bullet points. Knows what Lucas cares about.
- **Workspace**: Dedicated briefing workspace
- **Cron**:
  - Daily 7:30 AM EST: Morning brief (cluster status, overnight events, weather, calendar)
  - Friday 5 PM EST: Weekly recap (what got done, what's pending, highlights)

### 10. Wraith (`wraith`) - The Automator

- **Role**: CI/CD, Tekton pipelines, build automation, GitOps workflows, image management, registry cleanup.
- **Model**: DeepSeek V3 (pipeline-focused, structured)
- **Tools**: `coding` profile
- **Persona**: DevOps engineer who automates everything. If you do it twice, Wraith writes a pipeline for it. Loves idempotent operations. Allergic to manual steps.
- **Workspace**: Dedicated CI/CD workspace with pipeline templates

---

## Model Strategy

| Model | Best For | Agents | Cost |
|-------|----------|--------|------|
| Kimi K2.5 | Complex reasoning, large context | Nova, Architect, Scout, Forge | Higher |
| DeepSeek V3 | Fast structured tasks, data | Bolt, Sentinel, Ticker, Wraith | Lower |
| GLM 4.7 | Writing, narrative | Scribe, Herald | Medium |

This spreads cost across models - heavy ops/monitoring agents use the cheapest model, creative/complex agents use the best.

---

## Sub-Agent Hierarchy

```
Nova (orchestrator)
├── can spawn → Bolt, Architect, Scout, Scribe, Forge, Ticker
├── Architect → can spawn → Bolt (deploy after build)
├── Forge → can spawn → Bolt (deploy after build)
├── Herald → can read → all agent sessions (for summaries)
└── Sentinel → escalates to → Nova (when issues found)
```

---

## Cron Schedule Overview

| Time | Agent | Task |
|------|-------|------|
| Every 30m | Nova | Heartbeat (memory, proactive checks) |
| Every 4h | Sentinel | Cluster health scan |
| 6:00 AM EST | Sentinel | Certificate expiry check |
| 7:30 AM EST | Herald | Morning brief |
| 8:00 AM EST | Sentinel | Resource usage report |
| 7:00 PM EST | Ticker | Post-market scraper check |
| Friday 5 PM EST | Herald | Weekly recap |
| Monday 7 AM EST | Sentinel | Security audit |
| Sunday 12 PM EST | Ticker | Data quality report |

---

## Implementation Phases

### Phase 1: Config & Agent Definitions

Update `values.yaml` with all 10 agents in `agents.list`, including:
- Agent IDs, names, model assignments
- Tool profiles and allow/deny lists
- Sub-agent permissions (`subagents.allowAgents`)
- Sandbox settings per agent

Update `openclawinstance.yaml` template if needed for new config fields.

### Phase 2: Per-Agent Workspaces

Create dedicated workspace directories and bootstrap files for each agent:

```
~/.openclaw/workspace/           # Nova (main) - existing
~/.openclaw/workspaces/bolt/     # Bolt
~/.openclaw/workspaces/architect/
~/.openclaw/workspaces/scout/
~/.openclaw/workspaces/sentinel/
~/.openclaw/workspaces/scribe/
~/.openclaw/workspaces/forge/
~/.openclaw/workspaces/ticker/
~/.openclaw/workspaces/herald/
~/.openclaw/workspaces/wraith/
```

Each workspace gets tailored:
- `SOUL.md` - Unique personality and behavioral rules
- `AGENTS.md` - Role-specific operating instructions
- `IDENTITY.md` - Name, emoji, avatar
- `TOOLS.md` - Agent-specific tool notes and environment details
- `HEARTBEAT.md` - Agent-specific heartbeat checklist (where applicable)

### Phase 3: Cron Jobs

Configure `cron.jobs` in openclaw config or via CLI for:
- Sentinel's health checks (4h, daily, weekly)
- Herald's briefings (daily morning, weekly Friday)
- Ticker's market checks (daily post-close, weekly quality report)

Each cron job specifies:
- `agentId` to route to the correct agent
- `sessionTarget: "isolated"` for clean sessions
- `payload.message` with the specific task prompt
- `delivery` config for output routing

### Phase 4: Delivery Channels

Configure where agent outputs go:
- Currently: WebChat UI at openclaw.lucas.engineering
- Future: Discord, Slack, or other integrations
- Sentinel alerts could go to a dedicated channel
- Herald briefings delivered to morning notification surface

---

## Configuration Reference

### Agent Definition (openclaw.json schema)

```json
{
  "agents": {
    "defaults": {
      "model": { "primary": "...", "fallbacks": ["..."] },
      "workspace": "~/.openclaw/workspace",
      "subagents": {
        "maxSpawnDepth": 2,
        "maxChildrenPerAgent": 5,
        "maxConcurrent": 8,
        "runTimeoutSeconds": 900
      }
    },
    "list": [
      {
        "id": "agent-id",
        "name": "Display Name",
        "default": true,
        "workspace": "~/.openclaw/workspaces/agent-id",
        "model": "provider/model-id",
        "tools": {
          "profile": "coding|messaging|minimal|full",
          "allow": ["tool1", "group:web"],
          "deny": ["tool2"]
        },
        "subagents": {
          "allowAgents": ["other-agent-id"]
        },
        "sandbox": { "mode": "off|non-main|all", "scope": "session|agent|shared" }
      }
    ]
  }
}
```

### Cron Job Definition

```json
{
  "name": "Job Name",
  "agentId": "agent-id",
  "schedule": { "kind": "cron", "expr": "0 7 * * *", "tz": "America/New_York" },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Task prompt here",
    "timeoutSeconds": 120
  }
}
```

### Workspace Bootstrap Files

| File | Purpose | Loaded When |
|------|---------|-------------|
| `SOUL.md` | Agent personality, tone, values | Every turn |
| `AGENTS.md` | Operating instructions, tool rules | Every turn |
| `IDENTITY.md` | Name, emoji, avatar | Every turn |
| `USER.md` | Human's identity and preferences | Every turn |
| `TOOLS.md` | Local tool documentation | Every turn |
| `HEARTBEAT.md` | Periodic check checklist | Heartbeat only |
| `MEMORY.md` | Persistent long-term memory | Main session only |
| `BOOTSTRAP.md` | First-run setup (delete after) | First run only |

---

## Notes

- All config changes go through the `lucas_engineering` Helm chart so ArgoCD manages deployment
- Agent workspaces live on the PVC at `~/.openclaw/` and persist across restarts
- Workspace files (SOUL.md, etc.) can be bootstrapped via ConfigMap/initContainer or created by agents on first run
- The `trustedProxies` config includes `127.0.0.0/8` for the gateway-proxy sidecar
- GitOps rules from Nova's current AGENTS.md apply to ALL agents (read-only kubectl, commit through git)
