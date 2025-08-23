# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Docker Development Environment

#### Development Mode (External Databases)
```bash
# Build development images (first time only)
.\dev-docker.ps1 build

# Start all services with hot reload
.\dev-docker.ps1 up

# View logs (all services or specific)
.\dev-docker.ps1 logs
.\dev-docker.ps1 logs nexus-gateway

# Restart specific service
.\dev-docker.ps1 restart nexus-gateway

# Access service shell
.\dev-docker.ps1 shell nexus-gateway

# Stop all services
.\dev-docker.ps1 down

# Health checks
.\dev-docker.ps1 test
```

#### Local Mode (Local Databases)
```bash
# Start with local PostgreSQL and MongoDB
.\local-docker.ps1 up

# Other commands same as dev-docker.ps1
.\local-docker.ps1 logs
.\local-docker.ps1 down
```

### Individual Service Development

Each microservice uses similar commands:
```bash
# In any ms-nexus-* directory
pnpm install           # Install dependencies
pnpm run start:dev     # Development with hot reload
pnpm run build         # Production build
pnpm run lint          # ESLint with auto-fix
pnpm run test          # Unit tests
pnpm run test:e2e      # End-to-end tests
```

### Frontend Development
```bash
# In frontend-nexus-app directory
bun install           # Install dependencies
bun run dev           # Development server with turbopack
bun run build         # Production build
bun run lint          # ESLint
```

### Migration Tool
```bash
# In py-migration-nexus directory
pip install -r requirements.txt
python app.py         # Interactive migration tool
```

## Architecture Overview

**Nexus Global Network** is a comprehensive multi-level marketing (MLM) platform built with a modern microservices architecture. The system handles user management, product sales, payment processing, point systems, and commission calculations.

### Core Architecture Patterns

**Microservices with NATS Messaging**: All backend services communicate through NATS message broker using request-response patterns. The API Gateway acts as the single entry point, routing requests to appropriate microservices.

**Database per Service**: Each microservice owns its data:
- **Users Service**: MongoDB for user data, roles, and tree structures
- **Auth Service**: Stateless JWT authentication with microservice delegation
- **Payment Service**: PostgreSQL for payment processing and Culqi integration
- **Membership Service**: PostgreSQL for subscription plans and management
- **Point Service**: PostgreSQL for points, volumes, and commission tracking
- **Order Service**: PostgreSQL for products, inventory, and order management
- **Unilevel Service**: PostgreSQL for MLM tree calculations and sales
- **Integration Service**: External service integrations (AWS S3, SES, document validation)

### Service Communication Map

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │────│   API Gateway    │────│   NATS Broker   │
│  (Next.js 15)   │    │  (ms-nexus-*)    │    │   (Message)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                │                        │
┌─────────────────────────────────────────────────────────────────┐
│                    Microservices Layer                           │
├─────────────────┬─────────────────┬─────────────────┬───────────┤
│   Users         │   Auth          │   Payment       │   Order   │
│   (MongoDB)     │   (Stateless)   │   (PostgreSQL)  │   (Postgres)│
├─────────────────┼─────────────────┼─────────────────┼───────────┤
│   Membership    │   Point         │   Unilevel      │Integration│
│   (PostgreSQL)  │   (PostgreSQL)  │   (PostgreSQL)  │   (AWS)   │
└─────────────────┴─────────────────┴─────────────────┴───────────┘
```

### Key Components

#### Frontend (frontend-nexus-app)
- **Next.js 15** with App Router and React 19
- **Feature-based architecture** for MLM platform
- **Role-based access**: cliente, admin, facturacion
- **Authentication**: NextAuth.js with JWT and refresh tokens
- **UI**: Radix UI components with Tailwind CSS
- **State**: TanStack Query for server state, Zustand for client state

#### API Gateway (ms-nexus-gateway)
- **Single entry point** for all client requests
- **Authentication middleware** with JWT validation
- **Role-based authorization** with guards
- **Request routing** to appropriate microservices via NATS
- **Standardized responses** with consistent error handling

#### Microservices
- **Users**: User profiles, team trees, roles, and permissions
- **Auth**: JWT token management and validation
- **Payment**: Culqi payment gateway, withdrawals, admin approvals
- **Membership**: Subscription plans and membership management
- **Point**: MLM point system, volumes, and commission calculations
- **Order**: Product catalog, inventory, and order processing
- **Unilevel**: MLM tree structure and sales management
- **Integration**: External services (AWS S3, SES, document validation)

### Environment Configuration

#### Development Environments
- **`.env.dev`**: External databases (development servers)
- **`.env.local`**: Local databases (Docker containers)
- **`.env.test`**: Testing environment

#### Service-specific Environment Files
Each microservice has its own `.env` and `.env.example` files with:
- Database connection strings
- NATS server configuration
- External API keys and secrets
- Service-specific settings

### Technology Stack

#### Backend
- **Framework**: NestJS with TypeScript
- **Message Broker**: NATS for inter-service communication
- **Databases**: PostgreSQL (most services), MongoDB (users)
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: class-validator and class-transformer
- **ORM**: TypeORM for PostgreSQL services

#### Frontend
- **Framework**: Next.js 15 with React 19
- **Routing**: App Router with nested layouts
- **Styling**: Tailwind CSS with custom design system
- **Forms**: React Hook Form with Zod validation
- **Data Fetching**: TanStack Query with server actions
- **UI Components**: Radix UI primitives

#### Infrastructure
- **Containerization**: Docker with multi-stage builds
- **Development**: Hot reload with volume mounts
- **Logging**: Dozzle for container log aggregation
- **Package Management**: pnpm (backend), bun (frontend)

## Development Workflow

### Starting Development

1. **Clone and Setup**:
   ```bash
   # Configure environment
   cp .env.example .env.dev
   # Edit .env.dev with your database URLs
   ```

2. **Choose Development Mode**:
   - **External DBs**: `.\dev-docker.ps1 build && .\dev-docker.ps1 up`
   - **Local DBs**: `.\local-docker.ps1 build && .\local-docker.ps1 up`

3. **Access Services**:
   - Frontend: http://localhost:3000 (if running separately)
   - API Gateway: http://localhost:8000
   - NATS Monitor: http://localhost:8222
   - Dozzle Logs: http://localhost:9999 (dev mode only)

### Adding New Features

1. **Backend Changes**:
   - Update DTOs with proper validation
   - Add controller endpoints with guards (@Roles(), @Public())
   - Implement service logic with NATS communication
   - Add database entities if needed
   - Run `pnpm run lint` to ensure code quality

2. **Frontend Changes**:
   - Follow feature-based architecture in `src/features/`
   - Use server actions for mutations
   - Implement proper TypeScript typing
   - Run `bun run lint` to ensure code quality

3. **Testing**:
   - Unit tests: `pnpm run test` (backend)
   - E2E tests: `pnpm run test:e2e` (backend)
   - Health checks: `.\dev-docker.ps1 test`

### Data Migration

Use the Python migration tool for moving data between environments:
```bash
cd py-migration-nexus
python app.py
```

Follow the migration order: users → payments → membership → points

### Hot Reload Development

All services support hot reload during development:
- **Backend**: NestJS watch mode with volume mounts
- **Frontend**: Next.js with turbopack
- **Configuration**: Live reload for most config changes

### Debugging

#### Container Logs
```bash
# All services
.\dev-docker.ps1 logs

# Specific service
.\dev-docker.ps1 logs nexus-gateway

# Dozzle web interface (dev mode)
# http://localhost:9999
```

#### Service Shell Access
```bash
# Access any service container
.\dev-docker.ps1 shell nexus-gateway
.\dev-docker.ps1 shell ms-users
```

#### Health Monitoring
```bash
# Check all service health
.\dev-docker.ps1 test

# Individual service status
.\dev-docker.ps1 status
```

## MLM Business Logic

### Point System
- **User Points**: Track individual point balances
- **Weekly Volumes**: Calculate team volumes per week
- **Volume Sides**: Left/Right binary tree structure
- **Commission Processing**: Automated commission calculations

### Membership System
- **Plans**: Multiple membership tiers with benefits
- **Subscriptions**: Recurring membership payments
- **Upgrades**: Member plan advancement logic
- **Reconsumption**: Membership renewal processing

### Payment Processing
- **Culqi Integration**: Credit card payment gateway
- **Withdrawal System**: Member earning withdrawals
- **Admin Approvals**: Manual payment verification
- **Transaction History**: Complete audit trail

### User Hierarchy
- **Unilevel Tree**: Multi-level sponsor relationships
- **Binary Tree**: Left/right placement for volume calculations
- **Role Management**: Admin, client, billing user types
- **Team Management**: Downline member oversight

This architecture supports a complex MLM platform with clear separation of concerns, scalability through microservices, and maintainable code patterns.