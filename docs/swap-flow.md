# Swap Flow

1. User selects source chain, source token, amount, and XMR output address.
2. Client posts an order to `POST /order`.
3. ShroudChain creates a Shroud TX ID and starts watching the relevant LP address.
4. User sends funds to the displayed fixed LP address.
5. Chain watcher detects an inbound transaction.
6. Match engine checks chain, token, amount, and tolerance.
7. XMR router computes output and creates the Monero transaction.
8. Settlement agent broadcasts the XMR transaction.
9. Order status changes to `complete` and exposes the `xmr_tx_id`.

## Matching Rules

- Deposit amount must be at least 95% of quoted input amount.
- Deposits over the quote settle proportionally when supported by route liquidity.
- Sender address is not used as a matching key.
- Orders are matched by chain, token, amount window, and open order state.

## Quote Formula

```
XMR_out = (input_amount * input_price / XMR_price) * 0.997 * (1 - slippage / 100)
```

The `0.997` multiplier represents the 0.3% protocol fee.

