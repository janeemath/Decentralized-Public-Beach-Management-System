# Decentralized Public Beach Management System

A comprehensive blockchain-based solution for managing public beach operations, built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system provides decentralized management for five critical aspects of public beach operations:

1. **Lifeguard Scheduling** - Assigns certified staff to beach patrol duties
2. **Parking Fee Collection** - Handles beach access and parking payments
3. **Permit Management** - Issues permits for beach events and vendors
4. **Water Quality Testing** - Monitors swimming safety and pollution levels
5. **Maintenance Coordination** - Manages beach cleaning and facility upkeep

## Architecture

The system consists of five independent smart contracts that manage different aspects of beach operations:

### Lifeguard Scheduling Contract
- Manages lifeguard certifications and assignments
- Tracks shift schedules and coverage
- Handles emergency staffing requirements
- Maintains lifeguard performance records

### Parking Fee Collection Contract
- Processes parking payments in STX tokens
- Issues digital parking passes
- Manages daily/weekly/monthly rates
- Tracks revenue and usage statistics

### Permit Management Contract
- Issues permits for beach events and vendor activities
- Manages permit applications and approvals
- Tracks permit compliance and violations
- Handles permit renewals and cancellations

### Water Quality Testing Contract
- Records water quality test results
- Manages testing schedules and protocols
- Issues swimming safety advisories
- Tracks pollution incidents and remediation

### Maintenance Coordination Contract
- Schedules beach cleaning and maintenance tasks
- Manages equipment and supply inventory
- Tracks maintenance completion and quality
- Coordinates emergency repairs

## Features

- **Decentralized Governance**: Community-driven decision making
- **Transparent Operations**: All activities recorded on blockchain
- **Automated Payments**: Smart contract-based fee collection
- **Real-time Monitoring**: Live status updates for all beach services
- **Compliance Tracking**: Automated permit and safety compliance
- **Emergency Response**: Rapid coordination for safety incidents

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation

\`\`\`bash
git clone <repository-url>
cd beach-management-system
npm install
\`\`\`

### Testing

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm run test:lifeguard
npm run test:parking
npm run test:permits
npm run test:water-quality
npm run test:maintenance
\`\`\`

### Deployment

\`\`\`bash
# Deploy to testnet
clarinet deployments apply --testnet

# Deploy to mainnet
clarinet deployments apply --mainnet
\`\`\`

## Contract Interactions

### Lifeguard Operations
\`\`\`clarity
;; Register a new lifeguard
(contract-call? .lifeguard-scheduling register-lifeguard u123 "John Doe" u1234567890)

;; Schedule a shift
(contract-call? .lifeguard-scheduling schedule-shift u123 u1640995200 u1641081600)
\`\`\`

### Parking Payments
\`\`\`clarity
;; Purchase daily parking pass
(contract-call? .parking-fees purchase-pass u1 u1640995200)

;; Check parking status
(contract-call? .parking-fees get-pass-status u1 tx-sender)
\`\`\`

### Permit Applications
\`\`\`clarity
;; Apply for event permit
(contract-call? .permit-management apply-permit "Beach Wedding" u1640995200 u1641081600)

;; Approve permit (admin only)
(contract-call? .permit-management approve-permit u1)
\`\`\`

### Water Quality Monitoring
\`\`\`clarity
;; Submit test results
(contract-call? .water-quality submit-test-result u85 u7 u12 u1640995200)

;; Check swimming safety
(contract-call? .water-quality get-safety-status)
\`\`\`

### Maintenance Scheduling
\`\`\`clarity
;; Schedule maintenance task
(contract-call? .maintenance schedule-task "Beach Cleaning" u1640995200 u2)

;; Complete maintenance task
(contract-call? .maintenance complete-task u1 "Task completed successfully")
\`\`\`

## Error Codes

Each contract uses specific error codes for different failure conditions:

- **ERR-NOT-AUTHORIZED (u100)**: Caller lacks required permissions
- **ERR-INVALID-INPUT (u101)**: Invalid parameter values
- **ERR-NOT-FOUND (u102)**: Requested resource doesn't exist
- **ERR-ALREADY-EXISTS (u103)**: Resource already exists
- **ERR-INSUFFICIENT-FUNDS (u104)**: Insufficient STX balance
- **ERR-EXPIRED (u105)**: Resource has expired
- **ERR-NOT-ACTIVE (u106)**: Resource is not currently active

## Security Considerations

- All contracts implement proper access controls
- Input validation prevents malicious data
- Emergency pause functionality for critical situations
- Multi-signature requirements for administrative functions
- Regular security audits recommended

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For technical support or questions:
- Create an issue on GitHub
- Join our Discord community
- Email: support@beachmanagement.dev
