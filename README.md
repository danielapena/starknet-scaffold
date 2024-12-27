# Basecamp Scaffold Tutorial

Welcome to the Basecamp Scaffold Tutorial! This project provides a step-by-step guide to building decentralized applications on Starknet using Scaffold-Stark. Through a series of progressive steps, you'll learn how to create, deploy, and enhance smart contracts while building a production-ready frontend.

## What You'll Build

This tutorial guides you through building a decentralized application in three progressive steps:

1. **Step 1: Basic ETH Integration**
   - Simple greeting contract with ETH payments
   - Basic contract status display
   - Transaction history tracking

2. **Step 2: Multi-Token Support**
   - Enhanced contract with ETH and STRK support
   - Token selection interface
   - Multi-token balance tracking

3. **Step 3: Full zklend Integration**
   - Complete DeFi integration with zklend
   - Yield generation capabilities
   - Advanced token management

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
git clone git@github.com:Scaffold-Stark/basecamp.git basecamp-temp && cd basecamp-temp && git checkout base && mkdir temp_scaffold && cd temp_scaffold && git clone git@github.com:Scaffold-Stark/scaffold-stark-2.git . && rm -rf .git .github README.md && cp -r * ../ && cd .. && rm -rf temp_scaffold && git add . && git commit -m "Update framework to latest version"
```

This command will:
1. Clone the tutorial repository
2. Switch to the base branch
3. Download the latest Scaffold-Stark framework
4. Update the necessary files while preserving tutorial-specific content
5. Stage and commit the changes directly to base
