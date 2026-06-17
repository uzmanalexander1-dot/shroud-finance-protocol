# Shroud Finance Protocol

Technical reference repository for Shroud Finance contracts, settlement flow, chain metadata, and backend API surfaces.

This repository intentionally excludes the website, UI, static HTML, styles, and marketing assets. It is limited to protocol-facing materials.

## Contents

- `contracts/` Solidity templates for EVM inbound LP vaults and settlement event publishing.
- `deployments/lp-addresses.json` published LP/deposit address metadata.
- `api/openapi.yaml` order, claim, and status endpoints used by ShroudChain services.
- `docs/` architecture, swap flow, security model, and agent specifications.

## Protocol Summary

Shroud Finance accepts source-chain deposits into fixed protocol LP addresses. ShroudChain settlement services observe those deposits, match them to pending orders within tolerance, compute XMR output using live rates, and dispatch Monero from the output liquidity layer.

The on-chain footprint for EVM chains is a standard transfer into an inbound vault. The settlement layer records event metadata and emits deterministic order state transitions.

## Repository Scope

Included:

- Contract templates
- Interface definitions
- Deployment metadata
- API schemas
- Protocol docs
- Agent logic specifications

Excluded:

- HTML/CSS/JS website files
- UI assets
- Hosted frontend code
- Private keys, RPC credentials, database URLs, or production secrets

## Status

Reference implementation and public technical disclosure. Verify live deployment addresses, admin settings, and audit status before relying on any route.

