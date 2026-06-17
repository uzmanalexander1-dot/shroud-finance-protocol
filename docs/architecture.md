# Architecture

ShroudChain is the settlement layer behind Shroud Finance. It observes fixed LP addresses on supported source chains, matches deposits to pending orders, computes XMR output, and records deterministic order state.

## Components

- Chain watchers: persistent per-chain workers that monitor LP addresses.
- Match engine: matches observed deposits to pending orders within a tolerance window.
- Rate engine: computes output using live USD rates, 0.3% protocol fee, and slippage configuration.
- XMR router: constructs and broadcasts Monero payouts from output liquidity.
- Settlement recorder: stores order status, commitment hash, route ID, and settlement metadata.

## Inbound Vault Model

EVM deposits may use `ShroudInboundVault` where a standard native or ERC-20 transfer emits a deposit event. Non-EVM chains use fixed LP addresses watched by ShroudChain.

```
user -> fixed LP address -> watcher -> match engine -> XMR router -> recipient wallet
```

## Settlement Status

- `pending`: order created and waiting for deposit.
- `detected`: chain watcher found a matching transfer.
- `sending`: output route is being prepared.
- `complete`: XMR transaction was broadcast and recorded.
- `failed`: settlement could not complete automatically.

## Order IDs

Shroud TX IDs use the public format:

```
SHROUD-XXXXXXXX-XXXXXXXX
```

The settlement event contract stores compact `bytes32` identifiers derived from the public ID and commitment metadata.

