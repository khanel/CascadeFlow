# System Patterns: CascadeFlow

## Architecture Overview

CascadeFlow follows a **feature-sliced architecture** with clear separation of concerns across multiple layers. The system is organized into packages that can be developed, tested, and deployed independently.

## Package Structure

### Core Package (`packages/core/`)
- **Purpose**: Shared domain models, events, and utilities
- **Contents**:
  - Domain events (`DomainEvent`)
  - Failure types (`Failure`)
  - Result types (`Result<T>`)
  - Value objects (`EntityId`)
- **Dependencies**: Pure Dart, no Flutter dependencies

### Infrastructure Package (`packages/infrastructure/`)
- **Purpose**: Platform integrations and external service abstractions
- **Contents**:
  - Storage providers (Hive, secure storage)
  - Logging infrastructure
  - Notification scheduling
  - In-memory stubs for testing
- **Pattern**: Provider-based dependency injection

### Feature Packages (`features/*/`)
- **Purpose**: Self-contained business features
- **Structure** (per feature):
  ```
  features/{feature}/
  ├── lib/
  │   ├── {feature}.dart          # Public API
  │   ├── data/                   # Data access layer
  │   ├── domain/                 # Business logic
  │   └── presentation/           # UI layer
  └── test/                       # Feature tests
  ```
- **Isolation**: Each feature is independently deployable

### App Package (`app/`)
- **Purpose**: Application composition and bootstrap
- **Contents**:
  - Main application entry point
  - Provider scope setup
  - Navigation configuration
  - Platform-specific code

## Layer Responsibilities

### Domain Layer
- **Business Logic**: Pure functions implementing feature rules
- **Models**: Data structures representing business concepts
- **Services**: Business operations (use cases)
- **Validation**: Business rule enforcement
- **Pattern**: Functional programming with `fpdart` (TaskEither, Option)

### Data Layer
- **Repositories**: Abstract data access interfaces
- **Data Sources**: Concrete implementations (Hive, network, etc.)
- **DTOs**: Data transfer objects for serialization
- **Adapters**: Type conversion between domain and storage models
- **Pattern**: Repository pattern with dependency injection

### Presentation Layer
- **Controllers**: State management coordination
- **Providers**: Riverpod providers for state access
- **Widgets**: Flutter UI components
- **Screens**: Page-level compositions
- **Pattern**: Provider-based state management with code generation

### Infrastructure Layer
- **Storage**: Persistent data management
- **Networking**: External API communication
- **Notifications**: Platform notification services
- **Logging**: Structured logging infrastructure
- **Pattern**: Adapter pattern for platform abstractions

## Key Design Patterns

### Functional Core, Imperative Shell
- **Core**: Pure functions in domain layer
- **Shell**: Side effects in infrastructure/presentation layers
- **Benefits**: Testability, predictability, separation of concerns

### Dependency Injection with Riverpod
- **Providers**: Declarative dependency registration
- **Overrides**: Test-specific implementations
- **Code Generation**: Type-safe provider access
- **Scoping**: Hierarchical provider lifetimes

### Repository Pattern
- **Abstraction**: Domain defines interfaces
- **Implementation**: Infrastructure provides concrete types
- **Testing**: In-memory implementations for unit tests
- **Benefits**: Technology-agnostic data access

### Event-Driven Architecture
- **Domain Events**: Business-significant occurrences
- **Event Sourcing**: Optional audit trail capability
- **Loose Coupling**: Features communicate via events
- **Extensibility**: New features can react to existing events

### Feature Isolation
- **Boundaries**: Clear ownership per feature
- **Contracts**: Well-defined public APIs
- **Independence**: Features can evolve separately
- **Composition**: App layer combines features

## Communication Patterns

### Within Feature
- **Domain → Data**: Direct interface calls
- **Presentation → Domain**: Controller orchestration
- **Data → Infrastructure**: Provider resolution

### Between Features
- **Events**: Domain events for cross-feature communication
- **Shared Core**: Common types from core package
- **Navigation**: Router-based feature transitions

### External Systems
- **APIs**: REST/GraphQL clients in infrastructure
- **Storage**: Platform-specific implementations
- **Notifications**: Platform channel communication

## State Management Strategy

### Riverpod Provider Hierarchy
```
ProviderScope (App)
├── Infrastructure Providers
│   ├── hiveInitializerProvider
│   ├── secureStorageProvider
│   └── loggerProvider
├── Feature Providers
│   ├── captureControllerProvider
│   ├── focusSessionProvider
│   └── reviewSchedulerProvider
└── UI Providers
    ├── themeProvider
    └── navigationProvider
```

### State Flow
1. **User Interaction** → Widget events
2. **Controller** → Business logic execution
3. **Repository** → Data persistence
4. **Provider Update** → UI re-render

### Error Handling
- **Domain**: `TaskEither<Failure, Result>`
- **Presentation**: Provider state with error handling
- **Infrastructure**: Platform-specific error translation

## Testing Strategy

#### Test-Driven Development (TDD)
- **Red-Green-Refactor Cycle**: Write failing tests first, implement minimal code to pass, then refactor
- **Domain-First Testing**: Start with domain logic tests before infrastructure or UI
- **Incremental Development**: Small, testable increments with immediate feedback
- **Regression Prevention**: Comprehensive test suite prevents breaking changes

### Unit Tests
- **Domain Logic**: Pure function testing with TDD approach
- **Providers**: Riverpod testing utilities with generated mocks
- **Business Rules**: Test-driven validation and transformation logic
- **Error Handling**: Failure case testing with TaskEither patterns

### Integration Tests
- **Feature Workflows**: End-to-end feature testing
- **Storage**: Real Hive implementations with TDD for data operations
- **Navigation**: Router testing with state preservation validation

### Widget Tests
- **UI Components**: Flutter widget testing with behavior-driven tests
- **State Changes**: Provider integration testing
- **User Interactions**: Gesture and input simulation
- **Accessibility**: Screen reader and keyboard navigation testing

## Build and Deployment

### Code Generation
- **Riverpod**: `@riverpod` annotations
- **Hive**: TypeAdapter generation
- **Build Runner**: Continuous watching during development

### Platform Builds
- **Android**: Gradle-based APK/AAB
- **iOS**: Xcode-based IPA
- **Desktop**: Platform-specific executables

### CI/CD Pipeline
- **Linting**: `flutter analyze`
- **Testing**: `flutter test`
- **Building**: Platform-specific build commands
- **Distribution**: Store submissions and releases