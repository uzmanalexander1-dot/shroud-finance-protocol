# Security Model

## Protected Against

- Public input-to-output tracing across source chains and Monero.
- Wallet fingerprinting from required wallet connections.
- Per-user deposit address linkage.
- Manual settlement intervention in the normal path.

## Not Protected Against

- User endpoint compromise.
- Phishing or wrong-address deposits.
- Network-level metadata leakage.
- KYC exchange withdrawal records on the source side.
- Remote Monero node metadata leakage.

## Operational Controls

- Publish route addresses and deployment metadata.
- Verify owner/admin settings before relying on any deployment.
- Keep private keys and RPC credentials outside this repository.
- Monitor vault balances and settlement latency.
- Alert on unmatched deposits, stale orders, and route liquidity pressure.

