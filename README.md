# Basecamp Scaffold Tutorial

Welcome to the Basecamp Scaffold Tutorial!!! This project provides a step-by-step guide to building decentralized applications on Starknet using Scaffold-Stark. Through a series of progressive steps, you'll learn how to create, deploy, and enhance smart contracts while building a production-ready frontend.

## What You'll Build

This tutorial guides you through building a decentralized application in three progressive steps:

0. **Base: Scaffold Stark Base**
   - Starts from zero as a fresh clone of Scaffold-Stark
     
1. **Step 1: Basic Hooks Integration**
   - No updates on contracts
   - use all hooks to execute txs ( follow prompts on code )

2. **Step 2: Multi-Token Support**
   - update contract first to support STRK and ETH deposits ( follow prompts )
   - update ui to support token selection and display ( follow prompts )

3. **Step 3: Full zklend Integration**
   - the only update on ui is we test with `mainnetFork`
   - update contracts to integrate with zklend ( follow prompts )
   - deploy to mainnet
     
4. **Step 4: Final Ste**
   - nothing to do here
   - this is how the project looks after completing step-4

Each step builds upon the previous one, introducing new concepts and features while maintaining a clean, production-ready codebase.

## Tutorial Structure

The tutorial is organized into branches:

- `base`: Starting point with foundational setup
- `step-1`: Basic ETH integration
- `step-2`: Multi-token support
- `step-3`: Full zklend integration

To follow the tutorial, start with the base branch and progress through each step:

## Updating the Framework

This tutorial is built on top of Scaffold-Stark. To update the base framework:

```bash
git clone git@github.com:Scaffold-Stark/basecamp.git basecamp-temp && cd basecamp-temp && git checkout base && mkdir temp_scaffold && cd temp_scaffold && git clone git@github.com:Scaffold-Stark/scaffold-stark-2.git . && rm -rf .git .github README.md && cp -r * ../ && cd .. && rm -rf temp_scaffold && git add . && git commit -m "Update framework to latest version" && git push origin base
```

To update a specific step with the latest base changes:

```bash
git checkout step-1 && git merge base --no-edit && git push origin step-1
```

```bash
git checkout step-2 && git merge base --no-edit && git push origin step-2
```

```bash
git checkout step-3 && git merge base --no-edit && git push origin step-3
```

This process will:
1. Clone the tutorial repository
2. Switch to the base branch
3. Download the latest Scaffold-Stark framework
4. Update the necessary files while preserving tutorial-specific content
5. Stage and commit the changes to base
6. Push changes to the base branch
