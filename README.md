# Nexus Global Network - MLM Platform

A comprehensive multi-level marketing (MLM) platform built with modern microservices architecture, featuring user management, product sales, payment processing, point systems, and commission calculations.

## 🏗️ Architecture Overview

**Microservices Architecture** with NATS messaging, where each service owns its data and communicates through a unified message broker.

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
│   (MongoDB)     │   (Stateless)   │   (PostgreSQL)  │ (PostgreSQL)│
├─────────────────┼─────────────────┼─────────────────┼───────────┤
│   Membership    │   Point         │   Unilevel      │Integration│
│   (PostgreSQL)  │   (PostgreSQL)  │   (PostgreSQL)  │   (AWS)   │
└─────────────────┴─────────────────┴─────────────────┴───────────┘
```

## 🚀 Quick Start

### Development Mode (External Databases)

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

### Local Mode (Local Databases)

```bash
# Start with local PostgreSQL and MongoDB
.\local-docker.ps1 up

# Other commands same as dev-docker.ps1
.\local-docker.ps1 logs
.\local-docker.ps1 down
```

### Hot Reload Development (Alternative)

```bash
# Configure once
.\dev-local.ps1 setup

# Start everything (opens 3 terminals automatically)
.\dev-local.ps1 all
```

## 🛠️ Technology Stack

### Backend
- **Framework**: NestJS with TypeScript
- **Message Broker**: NATS for inter-service communication
- **Databases**: PostgreSQL (most services), MongoDB (users)
- **Authentication**: JWT with bcrypt password hashing
- **Validation**: class-validator and class-transformer
- **ORM**: TypeORM for PostgreSQL services

### Frontend
- **Framework**: Next.js 15 with React 19
- **Routing**: App Router with nested layouts
- **Styling**: Tailwind CSS with custom design system
- **Forms**: React Hook Form with Zod validation
- **Data Fetching**: TanStack Query with server actions
- **UI Components**: Radix UI primitives

### Infrastructure
- **Containerization**: Docker with multi-stage builds
- **Development**: Hot reload with volume mounts
- **Logging**: Dozzle for container log aggregation
- **Package Management**: pnpm (backend), bun (frontend)

## 📦 Services

### Core Services
- **API Gateway** (`ms-nexus-gateway`): Single entry point with authentication
- **Users Service** (`ms-nexus-user`): User profiles, team trees, roles
- **Auth Service** (`ms-nexus-auth`): JWT token management
- **Payment Service** (`ms-nexus-payment`): Culqi integration, withdrawals
- **Membership Service** (`ms-nexus-membership`): Subscription plans
- **Point Service** (`ms-nexus-point`): MLM points and commissions
- **Order Service** (`ms-nexus-order`): Products and inventory
- **Unilevel Service** (`ms-nexus-unilevel`): MLM tree calculations
- **Integration Service** (`ms-nexus-integration`): External APIs (AWS, SES)

### Frontend
- **Nexus App** (`frontend-nexus-app`): Main user interface

### Tools
- **Migration Tool** (`py-migration-nexus`): Data migration utility

## 🔧 Development Commands

### Individual Service Development

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

## 🌐 Service Access

During development, services are available at:

- **Frontend**: http://localhost:3000 (if running separately)
- **API Gateway**: http://localhost:8000
- **NATS Monitor**: http://localhost:8222
- **Dozzle Logs**: http://localhost:9999 (dev mode only)

## 💼 MLM Business Logic

### Point System
- User point balances tracking
- Weekly team volume calculations
- Left/Right binary tree structure
- Automated commission processing

### Membership System
- Multiple membership tiers
- Recurring subscription payments
- Member plan upgrades
- Membership renewal processing

### Payment Processing
- Culqi credit card integration
- Member withdrawal system
- Admin approval workflows
- Complete transaction audit trail

### User Hierarchy
- Multi-level sponsor relationships
- Binary tree for volume calculations
- Role-based access control
- Downline team management

## 📁 Project Structure

```
microservices/
├── ms-nexus-gateway/          # API Gateway service
├── ms-nexus-user/             # Users service
├── ms-nexus-auth/             # Authentication service
├── ms-nexus-payment/          # Payment processing
├── ms-nexus-membership/       # Membership management
├── ms-nexus-point/            # Point system
├── ms-nexus-order/            # Order management
├── ms-nexus-unilevel/         # MLM tree calculations
├── ms-nexus-integration/      # External integrations
├── frontend-nexus-app/        # Frontend application
├── py-migration-nexus/        # Data migration tool
├── dev-docker.ps1             # Development Docker script
├── local-docker.ps1           # Local Docker script
└── CLAUDE.md                  # Development guidelines
```

## 🔐 Environment Configuration

### Development Environments
- **`.env.dev`**: External databases (development servers)
- **`.env.local`**: Local databases (Docker containers)
- **`.env.test`**: Testing environment

Each microservice has its own `.env` and `.env.example` files with database connections, NATS configuration, and external API keys.

## 🐛 Debugging

### Container Logs
```bash
# All services
.\dev-docker.ps1 logs

# Specific service
.\dev-docker.ps1 logs nexus-gateway

# Web interface (dev mode)
# http://localhost:9999
```

### Service Shell Access
```bash
# Access any service container
.\dev-docker.ps1 shell nexus-gateway
.\dev-docker.ps1 shell ms-users
```

### Health Monitoring
```bash
# Check all service health
.\dev-docker.ps1 test

# Individual service status
.\dev-docker.ps1 status
```

## 📚 Additional Resources

For detailed development guidelines, service communication patterns, and best practices, see [CLAUDE.md](./CLAUDE.md).

---

Built with ❤️ using modern microservices architecture for scalable MLM platform management.