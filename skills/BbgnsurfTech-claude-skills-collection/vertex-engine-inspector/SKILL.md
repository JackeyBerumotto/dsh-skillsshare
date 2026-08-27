---
name: vertex-engine-inspector
description: "检查并验证 Vertex AI Agent Engine 部署，包括 Code Execution Sandbox、Memory Bank、A2A 协议合规性和安全姿态，并生成生产就绪评分。当被要求「inspect agent engine」或「validate deployment」时使用。 | Inspect and validate Vertex AI Agent Engine deployments including Code Execution Sandbox, Memory Bank, A2A protocol compliance, and security posture. Generates production readiness scores. Use when asked to \"inspect agent engine\" or \"validate depl..."
allowed-tools: Read, Grep, Glob, Bash
license: MIT
---
## What This Skill Does

Expert inspector for the Vertex AI Agent Engine managed runtime. Performs comprehensive validation of deployed agents including runtime configuration, security posture, performance settings, A2A protocol compliance, and production readiness scoring.

## When This Skill Activates

### Trigger Phrases
- "Inspect Vertex AI Engine agent"
- "Validate Agent Engine deployment"
- "Check Code Execution Sandbox configuration"
- "Verify Memory Bank settings"
- "Monitor agent health"
- "Agent Engine production readiness"
- "A2A protocol compliance check"
- "Agent Engine security audit"

### Use Cases
- Pre-production deployment validation
- Post-deployment health monitoring
- Security compliance audits
- Performance optimization reviews
- Troubleshooting agent issues
- Configuration drift detection

## Inspection Categories

### 1. Runtime Configuration ✅
- Model selection (Gemini 2.5 Pro/Flash)
- Tools enabled (Code Execution, Memory Bank, custom)
- VPC configuration
- Resource allocation
- Scaling policies

### 2. Code Execution Sandbox 🔒
- **Security**: Isolated environment, no external network access
- **State Persistence**: TTL validation (1-14 days)
- **IAM**: Least privilege permissions
- **Performance**: Timeout and resource limits
- **Concurrent Executions**: Max concurrent code runs

**Critical Checks**:
```
✅ State TTL between 7-14 days (optimal for production)
✅ Sandbox type is SECURE_ISOLATED
✅ IAM permissions limited to required GCP services only
✅ Timeout configured appropriately
⚠️ State TTL < 7 days may cause premature session loss
❌ State TTL > 14 days not allowed by Agent Engine
```

### 3. Memory Bank Configuration 🧠
- **Enabled Status**: Persistent memory active
- **Retention Policy**: Max memories, retention days
- **Storage Backend**: Firestore encryption & region
- **Query Performance**: Indexing, caching, latency
- **Auto-Cleanup**: Quota management

**Critical Checks**:
```
✅ Max memories >= 100 (prevents conversation truncation)
✅ Indexing enabled (fast query performance)
✅ Auto-cleanup enabled (prevents quota exhaustion)
✅ Encrypted at rest (Firestore default)
⚠️ Low memory limit may truncate long conversations
```

### 4. A2A Protocol Compliance 🔗
- **AgentCard**: Available at `/.well-known/agent-card`
- **Task API**: `POST /v1/tasks:send` responds correctly
- **Status API**: `GET /v1/tasks/{task_id}` accessible
- **Protocol Version**: 1.0 compliance
- **Required Fields**: name, description, tools, version

**Compliance Report**:
```
✅ AgentCard accessible and valid
✅ Task submission API functional
✅ Status polling API functional
✅ Protocol version 1.0
❌ Missing AgentCard fields: [...]
❌ Task API not responding (check IAM/networking)
```

### 5. Security Posture 🛡️
- **IAM Roles**: Least privilege validation
- **VPC Service Controls**: Perimeter protection
- **Model Armor**: Prompt injection protection
- **Encryption**: At-rest and in-transit
- **Service Account**: Proper configuration
- **Secret Management**: No hardcoded credentials

**Security Score**:
```
🟢 SECURE (90-100%): Production ready
🟡 NEEDS ATTENTION (70-89%): Address issues before prod
🔴 INSECURE (<70%): Do not deploy to production
```

### 6. Performance Metrics 📊
- **Auto-Scaling**: Min/max instances configured
- **Resource Limits**: CPU, memory appropriate
- **Latency**: P50, P95, P99 within SLOs
- **Throughput**: Requests per second
- **Token Usage**: Cost tracking
- **Error Rate**: < 5% target

**Health Status**:
```
🟢 HEALTHY: Error rate < 5%, latency < 3s (p95)
🟡 DEGRADED: Error rate 5-10% or latency 3-5s
🔴 UNHEALTHY: Error rate > 10% or latency > 5s
```

### 7. Monitoring & Observability 📈
- **Cloud Monitoring**: Dashboards configured
- **Alerting**: Policies for errors, latency, costs
- **Logging**: Structured logs aggregated
- **Tracing**: OpenTelemetry enabled
- **Error Tracking**: Cloud Error Reporting

**Observability Score**:
```
✅ All 5 pillars configured: Metrics, Logs, Traces, Alerts, Dashboards
⚠️ Missing alerts for critical scenarios
❌ No monitoring configured (production blocker)
```

## Production Readiness Scoring

### Scoring Matrix

| Category | Weight | Checks |
|----------|--------|--------|
| Security | 30% | 6 checks (IAM, VPC-SC, encryption, etc.) |
| Performance | 25% | 6 checks (scaling, limits, SLOs, etc.) |
| Monitoring | 20% | 6 checks (dashboards, alerts, logs, etc.) |
| Compliance | 15% | 5 checks (audit logs, DR, privacy, etc.) |
| Reliability | 10% | 5 checks (multi-region, failover, etc.) |

### Overall Readiness Status

```
🟢 PRODUCTION READY (85-100%)
   - All critical checks passed
   - Minor optimizations recommended
   - Safe to deploy

🟡 NEEDS IMPROVEMENT (70-84%)
   - Some important checks failed
   - Address issues before production
   - Staging deployment acceptable

🔴 NOT READY (<70%)
   - Critical failures present
   - Do not deploy to production
   - Fix blocking issues first
```

## Inspection Workflow

### Phase 1: Configuration Analysis
```
1. Connect to Agent Engine
2. Retrieve agent metadata
3. Parse runtime configuration
4. Extract Code Execution settings
5. Extract Memory Bank settings
6. Document VPC configuration
```

### Phase 2: Protocol Validation
```
1. Test AgentCard endpoint
2. Validate AgentCard structure
3. Test Task API (POST /v1/tasks:send)
4. Test Status API (GET /v1/tasks/{id})
5. Verify A2A protocol version
```

### Phase 3: Security Audit
```
1. Review IAM roles and permissions
2. Check VPC Service Controls
3. Validate encryption settings
4. Scan for hardcoded secrets
5. Verify Model Armor enabled
6. Assess service account security
```

### Phase 4: Performance Analysis
```
1. Query Cloud Monitoring metrics
2. Calculate error rate (last 24h)
3. Analyze latency percentiles
4. Review token usage and costs
5. Check auto-scaling behavior
6. Validate resource limits
```

### Phase 5: Production Readiness
```
1. Run all checklist items (28 checks)
2. Calculate category scores
3. Calculate overall score
4. Determine readiness status
5. Generate recommendations
6. Create action plan
```

## Tool Permissions

**Read-only inspection** - Cannot modify configurations:
- **Read**: Analyze agent configuration files
- **Grep**: Search for security issues
- **Glob**: Find related configuration
- **Bash**: Query GCP APIs (read-only)

## Example Inspection Report

```yaml
Agent ID: gcp-deployer-agent
Deployment Status: RUNNING
Inspection Date: 2025-12-09

Runtime Configuration:
  Model: gemini-2.5-flash
  Code Execution: ✅ Enabled (TTL: 14 days)
  Memory Bank: ✅ Enabled (retention: 90 days)
  VPC: ✅ Configured (private-vpc-prod)

A2A Protocol Compliance:
  AgentCard: ✅ Valid
  Task API: ✅ Functional
  Status API: ✅ Functional
  Protocol Version: 1.0

Security Posture:
  IAM: ✅ Least privilege (score: 95%)
  VPC-SC: ✅ Enabled
  Model Armor: ✅ Enabled
  Encryption: ✅ At-rest & in-transit
  Overall: 🟢 SECURE (92%)

Performance Metrics (24h):
  Request Count: 12,450
  Error Rate: 2.3% 🟢
  Latency (p95): 1,850ms 🟢
  Token Usage: 450K tokens
  Cost Estimate: $12.50/day

Production Readiness:
  Security: 92% (28/30 points)
  Performance: 88% (22/25 points)
  Monitoring: 95% (19/20 points)
  Compliance: 80% (12/15 points)
  Reliability: 70% (7/10 points)

  Overall Score: 87% 🟢 PRODUCTION READY

Recommendations:
  1. Enable multi-region deployment (reliability +10%)
  2. Configure automated backups (compliance +5%)
  3. Add circuit breaker pattern (reliability +5%)
  4. Optimize memory bank indexing (performance +3%)
```

## Integration with Other Plugins

### Works with jeremy-adk-orchestrator
- Orchestrator deploys agents
- Inspector validates deployments
- Feedback loop for optimization

### Works with jeremy-vertex-validator
- Validator checks code before deployment
- Inspector validates runtime after deployment
- Complementary pre/post checks

### Works with jeremy-adk-terraform
- Terraform provisions infrastructure
- Inspector validates provisioned agents
- Ensures IaC matches runtime

## Troubleshooting Guide

### Issue: Agent not responding
**Inspector checks**:
- VPC configuration allows traffic
- IAM permissions correct
- Agent Engine status is RUNNING
- No quota limits exceeded

### Issue: High error rate
**Inspector checks**:
- Model configuration appropriate
- Resource limits not exceeded
- Code Execution sandbox not timing out
- Memory Bank not quota-exhausted

### Issue: Slow response times
**Inspector checks**:
- Auto-scaling configured
- Code Execution TTL appropriate
- Memory Bank indexing enabled
- Caching strategy implemented

## Version History

- **1.0.0** (2025): Initial release with Agent Engine GA support, Code Execution Sandbox, Memory Bank, A2A protocol validation

## References

- Agent Engine: https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/overview
- Code Execution: https://cloud.google.com/agent-builder/agent-engine/code-execution/overview
- Memory Bank: https://cloud.google.com/vertex-ai/generative-ai/docs/agent-engine/memory-bank/overview
- A2A Protocol: https://google.github.io/adk-docs/a2a/
