# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Code Project Instructions — Point 
# Native POS Foundation

> **Purpose:** Define the engineering rules, architecture boundaries, and implementation conventions for a Point-of-Sale (POS) system built with **native platform-specific applications** while maintaining a single shared foundation sub-project.
>
> **Primary platforms:** iOS, Android, Tablet form factors, and additional device-specific targets as required.
>
> **Core architectural decision:** Do **not** use Flutter, Skia-based application rendering, React Native, Kotlin Multiplatform UI, or another cross-platform application framework. Platform applications must use their native SDKs, UI frameworks, lifecycle models, permissions, drivers, and device APIs. Use MVVM pattern for specific-platform: iOS (SwiftUI), android (Jetpack Compose), windows (WinUI3), and mac (SwiftUI)

---

## What this is

A simple point-of-sale app for iOS — CRUD for an item catalog (with dynamic variants), a sell-transaction form, and stock tracking (stock-in / stock-out / correction / opname) — built with SwiftUI and MVVM. With small monorepo as follow:

- **`ios/`** — the SwiftUI/Core Data iOS app (Xcode project, generated via XcodeGen). See **`iOS/CLAUDE.md`** for the full architecture, build/test commands, and toolchain notes — read that file before working on the app itself.
- **`design/`** — wireframe/Figma design reference for the app's UI, kept outside the iOS project folder since it isn't part of the buildable app.

# 1. Project Mission

The POS system should be designed as a **native multi-platform system** with:

1. A shared **Foundation** sub-project containing platform-independent business infrastructure.
2. Separate native applications for each target platform.
3. Explicit platform adapters for device capabilities.
4. A common protocol/message model for communication between UI, foundation, local services, and backend services.
5. Strong offline-first behavior.
6. Deterministic synchronization and conflict handling.
7. High-performance local data access.
8. Secure access to device information and hardware capabilities.
9. Platform-specific optimization rather than lowest-common-denominator behavior.

The architecture must prioritize:

- Reliability at the point of sale.
- Fast transaction completion.
- Offline operation.
- Data integrity.
- Hardware compatibility.
- Recoverability after crashes, power loss, or network loss.
- Explicit ownership of resources.
- Minimal runtime overhead.
- Clear separation between business logic and platform code.

---

# 2. Non-Negotiable Architecture Rules

## 2.1 Native Application Rule

Each platform must have its own application codebase.

Examples:

```text
/apps
  /ios
  /android
  /tablet-ios
  /tablet-android
  /windows-pos        # optional
  /macos-pos          # optional
```

The implementation must use the native platform technology appropriate to the target.

Examples:

- iOS: Swift + SwiftUI/UIKit + Apple SDKs
- Android: Kotlin + Jetpack Compose/View system + Android SDK
- Windows POS: C#/.NET + WinUI/WPF/Windows SDK where appropriate
- macOS: Swift + SwiftUI/AppKit where appropriate

Do not introduce a cross-platform UI framework to share application rendering.

## 2.2 Cross-Platform Framework Prohibition

Do not use:

- Flutter
- Skia-based application rendering
- React Native
- Xamarin
- .NET MAUI
- Kotlin Multiplatform UI
- Ionic
- Cordova
- Electron for native POS applications
- Qt as a replacement for native application UI
- Any framework whose primary purpose is to make one UI codebase render across multiple platforms

A shared Foundation library is allowed and encouraged.

## 2.3 Shared Foundation Rule

Only platform-independent infrastructure belongs in the Foundation.

The Foundation must not directly depend on:

- UIKit
- SwiftUI
- Android SDK
- Android Views
- Jetpack Compose
- Windows UI APIs
- platform-specific printer APIs
- platform-specific GPS APIs
- platform-specific permission APIs

Platform APIs must be accessed through explicit interfaces and adapters.

---

# 3. Repository Structure

The repository should evolve toward the following structure:

```text
point/
│
├── CLAUDE.md
│
├── foundation/
│   ├── core/
│   ├── memory/
│   ├── storage/
│   ├── sync/
│   ├── messaging/
│   ├── networking/
│   ├── security/
│   ├── device/
│   ├── permissions/
│   ├── telemetry/
│   └── testing/
│
├── apps/
│   ├── ios/
│   │   ├── App/
│   │   ├── UI/
│   │   ├── Platform/
│   │   ├── Device/
│   │   └── Integration/
│   │
│   ├── android/
│   │   ├── App/
│   │   ├── UI/
│   │   ├── Platform/
│   │   ├── Device/
│   │   └── Integration/
│   │
│   ├── tablet-ios/
│   └── tablet-android/
│
├── design/
│
├── contracts/
│   ├── messages/
│   ├── schemas/
│   ├── api/
│   └── events/
│
├── backend/
│   └── ...
│
├── tools/
│   ├── codegen/
│   ├── migration/
│   └── diagnostics/
│
└── docs/
    ├── architecture/
    ├── device/
    ├── synchronization/
    └── operations/
```

The exact directory names may change, but the architectural boundaries must remain.

---

# 4. Foundation Sub-Project

The Foundation is the most important shared component.

It should contain reusable infrastructure that does not require knowledge of the application's UI or a specific operating system.

## 4.1 Foundation Responsibilities

The Foundation should cover:

- Memory/resource management
- Threading/concurrency primitives
- Local storage
- Local file access abstraction
- Database abstraction
- Transaction processing primitives
- Synchronization
- Offline queue
- Message serialization
- Message validation
- Event processing
- Network transport abstraction
- Retry/backoff
- Device capability abstraction
- Permission abstraction
- Secure storage abstraction
- Logging
- Metrics
- Crash recovery
- Configuration
- Feature flags
- Time synchronization
- UUID/identity generation
- Idempotency
- Audit logging
- Data migration
- Schema versioning

## 4.2 Foundation Must Not Own UI

The Foundation must never:

- Render screens.
- Manage navigation.
- Know screen layouts.
- Depend on UI lifecycle events.
- Store UI state unnecessarily.
- Contain platform-specific view objects.

The UI consumes Foundation services.

---

# 5. Memory Management

Memory management must be explicit and observable.

## 5.1 Goals

The system must:

- Avoid unnecessary object duplication.
- Avoid unbounded queues.
- Avoid retaining large transaction payloads indefinitely.
- Release device resources deterministically.
- Stream large files rather than loading them entirely into memory.
- Limit cache size.
- Provide backpressure for high-volume operations.

## 5.2 Rules

Every long-lived component must document:

- Ownership.
- Lifecycle.
- Allocation source.
- Release condition.
- Cache policy.
- Maximum expected memory footprint.

Large datasets must use:

```text
stream -> process -> persist -> release
```

rather than:

```text
load entire dataset -> process -> persist
```

## 5.3 Memory Pressure

Platform applications must respond to platform memory-pressure signals.

The Foundation should expose:

```text
MemoryPressureLevel:
    Normal
    Warning
    Critical
```

Platform adapters translate native memory-pressure events into Foundation events.

---

# 6. Concurrency and Execution Model

POS operations must avoid blocking the UI thread.

Use separate execution domains for:

```text
UI
  ↓
Application orchestration
  ↓
Foundation services
  ├── Database
  ├── Synchronization
  ├── Network
  ├── File system
  ├── Device I/O
  └── Background processing
```

Rules:

- Never perform network requests on the UI thread.
- Never perform large database operations on the UI thread.
- Never perform printer I/O on the UI thread.
- Never perform file encryption/decryption synchronously on the UI thread for large files.
- Avoid global locks.
- Prefer actor/message-based isolation where supported by the platform.
- Use bounded worker pools.
- Define explicit cancellation behavior.

---

# 7. Local Storage

The POS must be **offline-first**.

Local storage should be treated as an operational database, not merely a cache.

## 7.1 Local Data Categories

Separate:

```text
Operational Data
  - Products
  - Prices
  - Inventory
  - Customers
  - Orders
  - Payments
  - Receipts

Synchronization Data
  - Outbox
  - Inbox
  - Sync cursor
  - Conflict records
  - Retry state

Device Data
  - Device identity
  - Registered peripherals
  - Printer configuration
  - Terminal configuration

Audit Data
  - User actions
  - Transaction changes
  - Synchronization events
  - Permission changes
```

## 7.2 Database Rules

The database must support:

- Atomic transactions.
- Crash recovery.
- Versioned migrations.
- Indexing.
- Constraints.
- Idempotency keys.
- Efficient incremental synchronization.

Do not treat local database records as disposable unless explicitly defined as cache data.

---

# 8. Local File Access

File access must be abstracted.

Foundation interface:

```text
FileStore
  read()
  write()
  append()
  delete()
  move()
  copy()
  exists()
  metadata()
  stream()
```

Platform implementations map these operations to the native file system.

Files that may be stored locally include:

- Receipt documents.
- Product images.
- Printer templates.
- Diagnostic logs.
- Synchronization payloads.
- Export files.
- Device configuration.
- Temporary transaction artifacts.

Sensitive files must use platform-secure storage where appropriate.

---

# 9. Message Format

All major internal and network operations should use explicit message contracts.

Recommended structure:

```json
{
  "message_id": "uuid",
  "message_type": "sale.created",
  "schema_version": 1,
  "timestamp": "2026-01-01T00:00:00Z",
  "device_id": "device-id",
  "tenant_id": "tenant-id",
  "correlation_id": "uuid",
  "idempotency_key": "uuid",
  "payload": {}
}
```

## 9.1 Message Requirements

Every important command/event should define:

- Message type.
- Schema version.
- Producer.
- Consumer.
- Correlation ID.
- Idempotency key where required.
- Timestamp.
- Device identity where relevant.
- Payload schema.
- Compatibility rules.

## 9.2 Versioning

Messages must be backward-compatible whenever practical.

Do not silently change field semantics.

Prefer:

```text
schema_version = 2
```

over changing the meaning of:

```text
schema_version = 1
```

---

# 10. Synchronization Strategy

Synchronization must be designed as a first-class subsystem.

## 10.1 Offline-First Model

The normal transaction flow should be:

```text
User
  ↓
Native UI
  ↓
Local transaction
  ↓
Local commit
  ↓
Outbox event
  ↓
Background synchronization
  ↓
Server
```

The POS must not require a live network connection to complete transactions unless the business rule explicitly requires online authorization.

## 10.2 Outbox Pattern

Every synchronized local transaction should generate an outbox record.

Example:

```text
Transaction DB
      │
      ├── transaction
      └── outbox_event
               │
               ↓
        Sync Worker
               │
               ↓
            Server
```

The local transaction and outbox event must be committed atomically.

## 10.3 Retry Strategy

Use:

- Exponential backoff.
- Jitter.
- Maximum retry limits.
- Retry classification.
- Dead-letter/error state.
- Connectivity awareness.

Do not repeatedly retry permanent failures.

## 10.4 Idempotency

Server and client synchronization operations must be idempotent.

A duplicated request must not create duplicated sales, payments, inventory movements, or other financial events.

---

# 11. Conflict Resolution

Conflict resolution must be explicitly defined per entity.

Do not create a universal conflict rule.

Example:

```text
Product Price
  -> server-authoritative

Inventory
  -> event-based reconciliation

Customer Profile
  -> field-level merge or server-authoritative

Completed Sale
  -> immutable

Payment
  -> immutable financial event

Device Configuration
  -> centrally managed
```

Financial records should generally be modeled as immutable events or append-only records rather than overwritten state.

---

# 12. Network Performance

The network layer must optimize for unstable retail environments.

Assume:

- Wi-Fi may disappear.
- Cellular connectivity may fluctuate.
- DNS may fail.
- Server latency may increase.
- Network may reconnect repeatedly.
- Captive portals may exist.
- Bandwidth may be limited.

## 12.1 Rules

Use:

- Connection reuse.
- Request batching where appropriate.
- Compression where beneficial.
- Incremental synchronization.
- Pagination.
- Delta synchronization.
- Request timeouts.
- Response size limits.
- Retry classification.
- Connection health monitoring.

Avoid:

- Re-downloading entire datasets.
- Polling at aggressive intervals.
- Large synchronous requests.
- Repeated authentication handshakes when sessions can be reused.

---

# 13. Device Capability Layer

Hardware must be accessed through a common Foundation interface with platform-specific implementations.

Example:

```text
DeviceCapability
  ├── Camera
  ├── GPS
  ├── WiFi
  ├── Bluetooth
  ├── NFC
  ├── Printer
  ├── BarcodeScanner
  ├── CashDrawer
  ├── Display
  ├── Audio
  ├── USB
  ├── Network
  ├── Storage
  └── BiometricAuthentication
```

The actual availability depends on the physical device and operating system.

## 13.1 Capability Discovery

The application must be able to ask:

```text
isAvailable(capability)
getStatus(capability)
getPermission(capability)
requestPermission(capability)
execute(capability, command)
```

The Foundation must not assume that a capability exists.

---

# 14. Printers

Printers must be treated as asynchronous device resources.

Support should be extensible for:

- Bluetooth printers.
- Network printers.
- USB printers.
- Platform print services.
- ESC/POS-compatible printers.
- Vendor-specific printer SDKs.

Architecture:

```text
Receipt
  ↓
PrintJob
  ↓
PrinterService
  ↓
PlatformPrinterAdapter
  ↓
Native Driver / SDK
```

Printer failures must not corrupt the original transaction.

A failed print should create a recoverable print job rather than forcing a duplicate sale.

---

# 15. Wi-Fi and Network Information

Where the operating system permits access, the application may expose:

- Connection status.
- Network type.
- Reachability.
- Interface information.
- Signal/network metadata available through official APIs.

Do not attempt to bypass platform privacy restrictions.

The system must distinguish:

```text
Internet Available
Local Network Available
Server Reachable
Authenticated
```

These are not equivalent states.

---

# 16. GPS and Location

Location access must be:

- Permission-aware.
- User-transparent.
- Disabled when not required.
- Minimized in frequency.
- Stored only when business requirements justify it.

Possible use cases:

- Store verification.
- Delivery confirmation.
- Device geofencing.
- Field-sales POS.

Do not continuously track location unless explicitly required by the product specification and permitted by platform policies.

---

# 17. Device User Information

The application may need to access device-level information such as:

- Device identifier permitted by the platform.
- Application installation identifier.
- OS version.
- Hardware model.
- Application version.
- Locale.
- Time zone.
- Screen characteristics.
- Network state.
- Battery state where available.

Avoid collecting personally identifying device information unless necessary.

Do not depend on hardware identifiers that the operating system prohibits applications from accessing.

---

# 18. Permissions

Permissions must be treated as capabilities rather than assumptions.

Define:

```text
PermissionState:
    Unknown
    Granted
    Denied
    Restricted
    PermanentlyDenied
    Unsupported
```

The platform layer maps native permission APIs to this model.

Examples:

```text
Camera
Location
Bluetooth
Nearby Devices
Network
Notifications
Files
Contacts
Biometric
USB
Printer
NFC
```

Only request a permission when the user initiates or reaches a feature that requires it, unless platform rules/business requirements justify another approach.

---

# 19. Security

Security must be designed into the Foundation.

Required areas:

- Secure credential storage.
- Key management.
- Device identity.
- Session management.
- TLS.
- Certificate validation.
- Encryption at rest where required.
- Sensitive log redaction.
- Secure deletion where appropriate.
- Token expiration.
- Device registration.
- Audit logging.

Never store secrets in:

- Source code.
- Plain-text configuration.
- Git.
- Application logs.
- Analytics payloads.

Use platform secure storage:

```text
iOS:
  Keychain / Secure Enclave where appropriate

Android:
  Android Keystore / hardware-backed security where available
```

---

# 20. Transaction Integrity

POS transactions are financial operations.

The architecture must protect:

- Sale amount.
- Tax.
- Discount.
- Payment amount.
- Change.
- Inventory movement.
- Receipt number.
- Transaction sequence.
- User identity.
- Device identity.
- Timestamp.

A transaction must have a clear state machine.

Example:

```text
CREATED
  ↓
VALIDATED
  ↓
COMMITTED
  ↓
PAYMENT_CONFIRMED
  ↓
COMPLETED
  ↓
SYNCED
```

Failure states must be explicit.

Never infer transaction completion solely from UI state.

---

# 21. Event Model

Use events for important state transitions.

Examples:

```text
sale.created
sale.completed
payment.authorized
payment.failed
inventory.adjusted
receipt.created
print.requested
print.completed
print.failed
sync.started
sync.completed
sync.failed
device.registered
permission.changed
```

Events should be:

- Immutable.
- Versioned.
- Traceable.
- Idempotent where consumed externally.

---

# 22. Native Platform Boundary

Each native application should contain an adapter layer.

Example:

```text
Native App
│
├── UI
├── Application Services
├── Platform Adapter
│     ├── PermissionAdapter
│     ├── PrinterAdapter
│     ├── LocationAdapter
│     ├── BluetoothAdapter
│     ├── NetworkAdapter
│     └── StorageAdapter
│
└── Foundation
```

The adapter is responsible for translating:

```text
Native API
    ↓
Foundation Contract
```

and:

```text
Foundation Command
    ↓
Native API
```

---

# 23. UI Architecture

UI architecture may differ by platform.

Do not force identical implementation patterns.

The business behavior should remain consistent, while UI implementation may be optimized for:

- iPhone.
- Android phone.
- iPad.
- Android tablet.
- POS terminal.
- Landscape display.
- External display.

Platform UI can diverge where platform conventions or hardware require it.

---

# 24. Device-Specific POS Mode

For dedicated POS devices, support where available:

- Kiosk mode.
- Screen pinning.
- Guided access.
- Device management.
- Auto-launch.
- Peripheral initialization.
- Offline operation.
- Background synchronization.
- Automatic recovery.

Device management must remain platform-specific.

---

# 25. Application Lifecycle

Foundation services must survive or recover from:

- Application termination.
- Background suspension.
- Process restart.
- Device reboot.
- Network loss.
- Low-memory termination.
- Power loss.

Never assume an in-memory operation will complete.

Important state must be persisted before acknowledging successful completion.

---

# 26. Crash Recovery

After startup:

```text
Application Start
  ↓
Load Device Identity
  ↓
Validate Local Database
  ↓
Recover Incomplete Transactions
  ↓
Recover Outbox
  ↓
Recover Print Queue
  ↓
Recover Sync State
  ↓
Initialize Device Capabilities
  ↓
Start Background Services
  ↓
Ready
```

Startup recovery must be deterministic and idempotent.

---

# 27. Observability

Foundation must provide:

- Structured logging.
- Metrics.
- Performance measurements.
- Network timing.
- Database timing.
- Synchronization statistics.
- Printer diagnostics.
- Device diagnostics.
- Crash context.
- Correlation IDs.

Example log:

```json
{
  "level": "INFO",
  "event": "sync.completed",
  "device_id": "...",
  "correlation_id": "...",
  "duration_ms": 420,
  "records_uploaded": 18,
  "records_downloaded": 7
}
```

Never log:

- Passwords.
- Authentication tokens.
- Payment credentials.
- Full sensitive customer data.
- Encryption keys.

---

# 28. Testing Strategy

Testing must be separated into layers.

## 28.1 Foundation Tests

Test without a real device:

- Database.
- Serialization.
- Message validation.
- Synchronization.
- Conflict handling.
- Retry logic.
- State machines.
- Idempotency.
- File abstractions.
- Security primitives.

## 28.2 Platform Tests

Run on actual platforms:

- Permissions.
- Printer integration.
- Bluetooth.
- Wi-Fi.
- GPS.
- Camera.
- NFC.
- Background execution.
- Lifecycle behavior.
- Hardware acceleration where applicable.
- Device-specific drivers.

## 28.3 Hardware Matrix

Maintain a hardware compatibility matrix.

Example:

```text
Device
OS Version
Screen
Printer
Barcode Scanner
Cash Drawer
Bluetooth
WiFi
NFC
GPS
USB
Status
```

---

# 29. Performance Requirements

Performance must be measured on real target hardware.

Important metrics:

```text
Cold startup time
Warm startup time
UI interaction latency
Sale creation latency
Payment confirmation latency
Database transaction latency
Print job submission latency
Synchronization throughput
Memory usage
CPU usage
Battery usage
Network bandwidth
```

Avoid premature optimization, but do not introduce abstractions that create measurable latency in critical transaction paths.

---

# 30. API and Backend Contract

The client should communicate through explicit API contracts.

Recommended separation:

```text
Command API
  - create sale
  - authorize payment
  - adjust inventory

Query API
  - products
  - prices
  - customers
  - reports

Synchronization API
  - upload events
  - download changes
  - acknowledge events
```

Do not use one generic endpoint for all POS behavior.

---

# 31. Schema and Contract Management

All shared contracts must be version-controlled.

Recommended:

```text
/contracts
  /messages
  /events
  /schemas
  /api
```

Changes must document:

```text
Old Version
New Version
Compatibility
Migration
Rollback
```

Breaking changes require explicit migration planning.

---

# 32. Configuration

Configuration must be separated into:

```text
Build Configuration
Environment Configuration
Tenant Configuration
Store Configuration
Device Configuration
User Configuration
Feature Flags
```

Never hard-code store/device-specific behavior into business logic.

---

# 33. Dependency Management

Dependencies must be minimized.

Before adding a dependency, evaluate:

1. Why is it required?
2. Is the functionality available natively?
3. Does it introduce a cross-platform runtime?
4. Does it increase startup/memory footprint?
5. Does it introduce security risk?
6. Is it actively maintained?
7. Can it be isolated behind an adapter?

A dependency must not be introduced merely to avoid writing a small native adapter.

---

# 34. Code Generation

Generated code may be used for:

- Message serialization.
- API models.
- Database models.
- Contract validation.
- Platform binding declarations.

Generated code must be clearly separated from handwritten code.

Never manually edit generated files unless the generation process explicitly supports it.

---

# 35. Development Workflow

For every feature:

```text
1. Define business behavior
2. Define Foundation contract
3. Define message/event schema
4. Implement Foundation behavior
5. Implement platform adapter
6. Implement native UI
7. Add unit tests
8. Add platform tests
9. Test offline behavior
10. Test synchronization
11. Test failure recovery
12. Test real hardware
```

Do not start by implementing UI and then discovering the required Foundation contract afterward.

---

# 36. Change Management

This document is intentionally modular.

When changing architecture, update only the relevant section first.

For significant changes, update:

```text
# 2 Non-Negotiable Architecture Rules
# 3 Repository Structure
# relevant subsystem section
# 35 Development Workflow
```

Do not rewrite unrelated sections.

Every architectural change should include:

```text
Decision
Reason
Impact
Migration
Rollback
```

---

# 37. Architecture Decision Records

Create an ADR for decisions that affect multiple platforms or the Foundation.

Recommended location:

```text
docs/architecture/adr/
```

Naming:

```text
ADR-0001-native-platform-architecture.md
ADR-0002-offline-first-sync.md
ADR-0003-local-database.md
ADR-0004-message-format.md
```

ADR template:

```markdown
# ADR-NNNN: Title

## Status

Proposed | Accepted | Deprecated | Superseded

## Context

What problem are we solving?

## Decision

What are we choosing?

## Alternatives

What alternatives were considered?

## Consequences

What becomes easier?

What becomes harder?

## Migration

How will existing code migrate?

## Rollback

How can this decision be reversed?
```

---

# 38. Claude Code Working Rules

When modifying this repository:

## Before Coding

1. Read this `CLAUDE.md`.
2. Inspect the relevant Foundation module.
3. Inspect the relevant platform adapter.
4. Inspect existing contracts.
5. Search for existing implementations before creating new abstractions.
6. Determine whether the change belongs to Foundation or a platform.

## During Coding

- Keep platform-specific code inside the platform project.
- Keep Foundation platform-neutral.
- Do not introduce cross-platform UI frameworks.
- Prefer existing abstractions.
- Do not duplicate business logic between iOS and Android.
- Do not hide platform differences when those differences matter.
- Add tests for state transitions and failure paths.
- Preserve backward compatibility where possible.

## After Coding

Verify:

```text
Foundation builds
Platform project builds
Unit tests pass
Platform tests pass
Schema compatibility is preserved
Offline mode works
Synchronization is recoverable
No new cross-platform UI framework was introduced
No secrets were introduced
No platform permission is silently assumed
```

---

# 39. Feature Classification

Before implementing a new feature, classify it:

```text
[FOUNDATION]
Platform-independent infrastructure.

[PLATFORM]
Native OS/device implementation.

[APPLICATION]
Business/application orchestration.

[UI]
Platform-specific presentation.

[CONTRACT]
API/message/event schema.

[BACKEND]
Server-side implementation.

[DEVICE]
Hardware/driver integration.
```

A feature can span multiple categories, but its responsibilities must remain separated.

---

# 40. Definition of Done

A feature is complete only when:

- [ ] Business behavior is defined.
- [ ] Foundation contract exists where needed.
- [ ] Message/event schema is versioned where needed.
- [ ] Local persistence behavior is defined.
- [ ] Offline behavior is defined.
- [ ] Synchronization behavior is defined.
- [ ] Failure behavior is defined.
- [ ] Platform-specific adapter exists where required.
- [ ] Native UI is implemented.
- [ ] Permissions are handled explicitly.
- [ ] Hardware availability is checked.
- [ ] Unit tests exist.
- [ ] Platform tests exist where required.
- [ ] Recovery behavior is tested.
- [ ] Logging/observability is implemented.
- [ ] Security implications are reviewed.
- [ ] Documentation is updated.
- [ ] No prohibited cross-platform UI framework was introduced.

---

# 41. Future Extension Points

The architecture should remain extensible for:

```text
Payment Terminal
Fiscal Printer
Receipt Printer
Barcode Scanner
Cash Drawer
Customer Display
Scale
NFC Reader
Card Reader
Camera
GPS
Bluetooth
USB
External Monitor
Kitchen Display
Self-Service Kiosk
Warehouse Scanner
Mobile POS
Tablet POS
Desktop POS
```

New hardware must be added through a capability/adapter model rather than directly coupling business logic to a device SDK.

---

# 42. Current Architecture Status

Update this section whenever the architecture changes.

```text
Architecture Version: 0.1

Application Model:
    Native per platform

Shared Foundation:
    Required

Cross-Platform UI Framework:
    Prohibited

Offline-First:
    Required

Synchronization:
    Event + Outbox based

Local Database:
    Required

Platform Adapter Layer:
    Required

Hardware Capability Layer:
    Required

Message Contracts:
    Versioned

ADR:
    Required for major architectural decisions
```

---

# 43. Open Decisions

Keep unresolved architecture decisions here so they can be changed without rewriting the entire document.

```text
[ ] Foundation implementation language
[ ] Foundation package/module distribution strategy
[ ] Local database technology per platform
[ ] Common serialization format
[ ] Synchronization protocol
[ ] Backend API protocol
[ ] Event broker requirements
[ ] Encryption strategy
[ ] Device identity strategy
[ ] Printer abstraction
[ ] Payment terminal abstraction
[ ] Hardware certification requirements
[ ] Remote device management
[ ] Telemetry/observability backend
[ ] Update/OTA strategy
[ ] Multi-store synchronization model
```

When an item is decided, move the decision into the relevant architecture section and create an ADR if the decision affects multiple modules.

---

# 44. Guiding Principle

The system should follow this rule:

> **Share contracts, protocols, data models, business infrastructure, and synchronization mechanisms — but do not share the platform UI or hide meaningful operating-system differences behind a cross-platform framework.**

The goal is not to eliminate platform-specific code.

The goal is to make platform-specific code **small, explicit, testable, and replaceable**, while keeping the core POS behavior consistent across every device.