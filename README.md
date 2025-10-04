# FundMe Smart Contract Project

A decentralized crowdfunding smart contract built with Solidity and Foundry, featuring Chainlink price feed integration, flexible deployment scripts, and comprehensive tests.

## Features

- **FundMe Contract**: Accepts ETH from users, enforces a minimum USD value per contribution, and allows only the owner to withdraw funds.
- **Chainlink Price Feed**: Ensures real-time ETH/USD conversion for minimum funding enforcement.
- **HelperConfig**: Automatically selects the correct price feed for local, Sepolia, or Mainnet deployments. Deploys mocks for local testing.
- **Deployment Scripts**: Easily deploy contracts to local or public networks using Foundry scripts.
- **Interaction Scripts**: Fund and withdraw from the contract via scripts.
- **Testing**: Unit and integration tests using Foundry’s Forge framework.
- **Makefile**: Streamlines common tasks (build, test, deploy, etc.).

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (for some scripts)
- An Ethereum wallet/private key for deployments / or Foundry Anvil to demo run it.

### Installation

Clone the repo and install dependencies:

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd FundMe
forge install
```

### Configuration

Set up your .env file with the following variables:

```
SEPOLIA_RPC_URL=<your_sepolia_rpc_url>
ETHERSCAN_API_KEY=<your_etherscan_api_key>
PRIVATE_KEY=<your_private_key>
```

#### Build

```
forge build
```

#### Test

```
forge test
```

#### Deploy

local(Anvil)

```
make anvil
make deploy
```

Sepolia

```
make deploy-sepolia
```

#### Interact

Fund or withdraw using scripts:

```
make fund
make withdraw
```

### Project Structure

- src/ — Solidity contracts (FundMe.sol, PriceConverter.sol)
- script/ — Deployment and interaction scripts
- test/ — Unit and integration tests
- lib/ — External dependencies (Chainlink, Foundry std, etc.)
- .env — Environment variables
- Makefile — Task automation

### Security

- Only the contract owner can withdraw funds.
- Minimum funding enforced in USD using Chainlink price feeds.

### License

MIT

## Author

**dev0xjosh**

- [GitHub](https://github.com/JoshBolu)
- [Twitter](https://x.com/dev0xjosh)
