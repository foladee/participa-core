# Participa Core

A proof-of-participation reward engine built on the Stacks blockchain using Clarity.

## Overview

Participa Core is a smart contract that incentivizes user participation through a points-based reward system. Authorized reporters track user participation, and users can claim STX rewards based on accumulated participation points.

## Features

- **Participation Tracking**: Records user participation points from authorized reporters
- **Reporter Authorization**: Contract owner can manage a list of authorized participation reporters
- **Reward Claims**: Users claim STX rewards based on their accumulated participation points
- **Double-Claim Prevention**: Tracks claimed rewards to prevent duplicate claims
- **Access Control**: Owner-only functions for reporter management

## How It Works

### 1. Setup
- Contract owner is set at deployment
- Owner adds authorized reporters via `add-reporter`

### 2. Record Participation
- Authorized reporters call `report-participation` with user principal and participation amount
- Points are accumulated in the user's participation record

### 3. Claim Rewards
- Users call `claim-reward` to convert participation points to STX
- Conversion rate: **1000 participation points = 1 STX**
- Contract transfers STX reward to the user
- Claimed amount is tracked to prevent double-claiming

## Contract Functions

### Owner Functions
- `add-reporter(principal)` - Add an authorized participation reporter
- `remove-reporter(principal)` - Remove a reporter from authorization

### Public Functions
- `report-participation(user, amount)` - Record participation points for a user
- `claim-reward()` - Claim accumulated STX rewards

### Read-Only Functions
- `is-owner?()` - Check if caller is contract owner
- `is-reporter?(principal)` - Check if address is authorized reporter
- `get-points(principal)` - Get participation points and claimed amount for a user

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 40001 | ERR-NOT-OWNER | Caller is not the contract owner |
| 40002 | ERR-NOT-REPORTER | Caller is not an authorized reporter |
| 40003 | ERR-NO-REWARDS | No eligible rewards to claim |
| 40004 | ERR-INSUFFICIENT-FUND | Insufficient funds for transfer |

## Constants

- `REWARD-RATE`: 1000 (participation points per STX reward)
- `contract-owner`: Set at deployment time

## Usage Example

```clarity
;; Add a reporter (as contract owner)
(contract-call? .participa-core add-reporter 'SP2ZRX0K27ZD46SPH5F0615JJFRRAWYKS5XJDEF6)

;; Report participation (as authorized reporter)
(contract-call? .participa-core report-participation 'SPUSER123 u500)

;; Claim rewards (as user)
(contract-call? .participa-core claim-reward)
