# Settlement Agents

ShroudChain agents are deterministic services. The term "agent" refers to autonomous workers, not an LLM in the settlement path.

## Agent Responsibilities

| Agent | Responsibility |
| --- | --- |
| Chain Watcher | Poll supported chains for deposits to LP addresses. |
| Match Engine | Match detected deposits to pending orders. |
| Rate Engine | Calculate output based on live market rates and fee rules. |
| XMR Router | Select liquidity path and construct Monero payout. |
| Settlement Agent | Broadcast transaction, confirm, and update order status. |

## Approval Criteria

- Pending order exists.
- Deposit is on the expected source chain.
- Token matches the order route.
- Amount is within the accepted tolerance.
- Output XMR address passes syntactic validation.

