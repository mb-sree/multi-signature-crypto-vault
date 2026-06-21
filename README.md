# Multi Signature Vault

A lightweight, dependency-free multi-signature Ethereum vault written in Solidity `^0.8.20`.

## Overview

Multi Signature Vault enables collective control over ETH funds. Multiple owners propose, approve,
and execute transactions — nothing moves until the required approval threshold is met.

## How It Works

1. **Deploy** — provide a list of owner addresses and a minimum approval count.
2. **Deposit** — any address can fund the vault via `deposit()`.
3. **Submit** — an owner proposes a transfer (recipient + amount in ETH).
4. **Approve / Revoke** — owners vote on pending transactions at any time before execution.
5. **Execute** — any owner triggers execution once the threshold is reached.

## Key Functionality

| Function | Access | Description |
|---|---|---|
| `deposit()` | Public | Fund the vault with ETH |
| `submit(to, amount)` | Owner | Propose a new transaction |
| `approve(txId)` | Owner | Approve a pending transaction |
| `revoke(txId)` | Owner | Revoke a prior approval |
| `execute(txId)` | Owner | Execute once threshold is met |
| `getTransaction(txId)` | Public | Inspect a transaction's state |
| `getBalance()` | Public | View current vault balance |

## Events

- `Deposit(address sender, uint amount)`
- `Submit(uint txId)`
- `Approve(address owner, uint txId)`
- `Revoke(address owner, uint txId)`
- `Execute(uint txId)`

## Technical Specifications

- **Language:** Solidity `^0.8.20`
- **Dependencies:** None
- **Compatibility:** Any standard EVM-compatible chain

## Security Notes

- Duplicate owners are rejected at deploy time.
- Transactions cannot be re-executed after completion.
- ETH balance is verified both at submission and execution.
- Approvals can be revoked at any point before execution.

## License

MIT
