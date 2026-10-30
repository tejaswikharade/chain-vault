# ChainVault

An intentionally small, auditable ETH time-lock vault. The owner funds it once; a designated beneficiary can release the balance once the unlock timestamp arrives. Before then, the owner may cancel and recover the funds.

## Contract guarantees

- Immutable owner, beneficiary, and unlock time
- A single owner-only ETH deposit, making pre-unlock recovery unambiguous
- Beneficiary-only release after the configured timestamp
- Owner-only cancellation strictly before that timestamp
- Checks-effects-interactions and a reentrancy guard around ETH transfers
- Clear deposit, release, and cancellation events

## Get started

```bash
forge test
forge fmt --check
cd frontend && npm install && npm run dev
```

## Deploy

```bash
forge script script/DeployChainVault.s.sol:DeployChainVault \
  --rpc-url "$RPC_URL" --broadcast \
  --sig "run(address,uint256)" "$BENEFICIARY" "$UNLOCK_TIMESTAMP"
```

This project has not received a security audit. Do not use it to custody production funds.
