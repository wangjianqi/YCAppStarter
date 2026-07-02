# Swift Concurrency Guardian

## Purpose

This skill ensures that generated or modified Swift code follows Swift 6 strict concurrency rules and avoids common `@MainActor`, `Sendable`, `Task`, `actor`, and async isolation issues.

Use this skill whenever writing, modifying, reviewing, or refactoring Swift, SwiftUI, UIKit, AppKit, AVFoundation, StoreKit, networking, persistence, analytics, camera, media, or subscription-related code.

The goal is not only to silence compiler errors, but to produce concurrency-safe, maintainable, testable Swift code.

---

## Common Errors This Skill Prevents

Prevent or fix errors such as:

```text
Main actor-isolated property can not be referenced from a nonisolated context
```

```text
Call to main actor-isolated initializer in a synchronous nonisolated context
```

```text
Sending non-Sendable value risks causing data races
```

```text
Reference to captured var in concurrently-executing code
```

```text
Capture of 'self' with non-Sendable type in a @Sendable closure
```

```text
Mutation of captured var in concurrently-executing code
```

```text
Actor-isolated property can not be mutated from a nonisolated context
```

```text
Non-sendable type returned by implicitly asynchronous call to actor-isolated function
```

---

# Core Rules

## 1. Do Not Add `@MainActor` Blindly

Never add `@MainActor` to an entire type, file, module, or API just to silence a compiler error.

Bad:

```swift
@MainActor
final class NetworkService {
    // Bad: networking service should not usually be main-actor isolated
}
```

Bad:

```swift
@MainActor
struct DataModel {
    // Bad: plain models should not usually depend on MainActor
}
```

Allowed places for `@MainActor` usually include:

* SwiftUI `View`
* UIKit / AppKit controllers
* ViewModel
* UI Store
* Coordinator
* Router
* Presenter
* ObservableObject used by UI
* `@Observable` state containers used directly by UI

Recommended:

```swift
@MainActor
final class ExampleViewModel: ObservableObject {
    @Published private(set) var title: String = ""

    func updateTitle(_ value: String) {
        self.title = value
    }
}
```

---

## 2. Keep Model, DTO, Config, Builder, Mapper, Parser Non-MainActor by Default

These types should normally be independent of `MainActor`:

* Model
* DTO
* Request
* Response
* Config
* Builder
* Mapper
* Parser
* Formatter
* Repository interface
* Service protocol
* Domain logic
* Pure utility
* Validation logic
* Data transformation logic

Recommended:

```swift
public struct ExampleItem: Sendable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}
```

Avoid:

```swift
struct ExampleItem {
    let title: String = AppState.shared.currentTitle
}
```

Models should receive values explicitly instead of reading global UI state.

---

## 3. Use Snapshot Passing Across Actor Boundaries

When non-UI code needs state that belongs to `MainActor`, do not read it directly inside the core layer.

Bad:

```swift
enum ExampleBuilder {
    static func build() -> [ExampleItem] {
        if AppState.shared.isFeatureDisabled {
            return []
        }

        return [
            ExampleItem(id: "a", title: "A")
        ]
    }
}
```

Recommended:

```swift
public struct ExampleBuildOptions: Sendable {
    public let isFeatureDisabled: Bool
    public let isPremiumUser: Bool

    public init(
        isFeatureDisabled: Bool,
        isPremiumUser: Bool
    ) {
        self.isFeatureDisabled = isFeatureDisabled
        self.isPremiumUser = isPremiumUser
    }
}
```

```swift
public enum ExampleBuilder {
    public static func build(
        options: ExampleBuildOptions
    ) -> [ExampleItem] {
        guard options.isFeatureDisabled == false else {
            return []
        }

        return [
            ExampleItem(id: "a", title: "A")
        ]
    }
}
```

UI layer reads the actor-isolated state and passes a value snapshot:

```swift
@MainActor
final class ExampleViewModel: ObservableObject {
    @Published private(set) var items: [ExampleItem] = []

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func reload() {
        let options = ExampleBuildOptions(
            isFeatureDisabled: appState.isFeatureDisabled,
            isPremiumUser: appState.isPremiumUser
        )

        self.items = ExampleBuilder.build(options: options)
    }
}
```

Default recommendation:

```text
Read UI/MainActor state in the UI layer.
Convert it into immutable Sendable values.
Pass those values into core, model, builder, service, or domain code.
```

---

# MainActor Access Rules

## Case 1: UI Code Reading UI State

If the current code directly updates UI state, it should usually be `@MainActor`.

Recommended:

```swift
@MainActor
func reloadUI() {
    let title = state.currentTitle
    self.title = title
}
```

Or:

```swift
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var title: String = ""

    func reload() {
        title = "Settings"
    }
}
```

---

## Case 2: Async Code Temporarily Needs MainActor State

If an async function must read a `MainActor` value, use `await MainActor.run`.

Recommended:

```swift
func loadData() async {
    let isEnabled = await MainActor.run {
        appState.isEnabled
    }

    let result = await service.load(isEnabled: isEnabled)

    await MainActor.run {
        self.result = result
    }
}
```

Do not call `MainActor.run` repeatedly in a loop.

Bad:

```swift
for item in items {
    let isEnabled = await MainActor.run {
        appState.isEnabled
    }

    process(item, isEnabled: isEnabled)
}
```

Recommended:

```swift
let isEnabled = await MainActor.run {
    appState.isEnabled
}

for item in items {
    process(item, isEnabled: isEnabled)
}
```

---

## Case 3: Core Code Needs UI State

Prefer snapshot passing.

Recommended:

```swift
let snapshot = FeatureSnapshot(
    isEnabled: isEnabled,
    selectedMode: selectedMode,
    userLevel: userLevel
)

let output = CoreBuilder.build(snapshot: snapshot)
```

Avoid:

```swift
let output = CoreBuilder.build()
```

when `CoreBuilder.build()` internally reads UI state, singleton state, or `@MainActor` state.

---

# Sendable Rules

## 1. Prefer Immutable Value Types

When data crosses an async, actor, task, or thread boundary, prefer:

```swift
struct
let properties
Sendable
```

Recommended:

```swift
public struct UserProfileSnapshot: Sendable {
    public let id: String
    public let name: String
    public let isPremium: Bool
}
```

Avoid mutable shared reference state:

```swift
final class UserProfile {
    var name: String
    var isPremium: Bool
}
```

---

## 2. Make Public Value Types Sendable When Appropriate

Recommended:

```swift
public enum CaptureMode: String, Sendable {
    case photo
    case video
    case portrait
}
```

```swift
public struct CapturePreset: Sendable, Identifiable {
    public let id: String
    public let mode: CaptureMode
    public let title: String
}
```

---

## 3. Do Not Make Classes `@unchecked Sendable` Unless Proven Safe

Bad:

```swift
final class CacheStore: @unchecked Sendable {
    var values: [String: String] = [:]
}
```

Only use `@unchecked Sendable` when the class has explicit thread-safety protection, such as:

* Lock
* Actor isolation
* Serial queue
* Immutable internal state
* Atomic storage

Acceptable only with clear explanation:

```swift
final class LockedCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: String] = [:]

    func value(for key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    func setValue(_ value: String, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = value
    }
}
```

---

# Task Rules

## 1. Prefer `Task {}` Inside MainActor ViewModels

Recommended:

```swift
@MainActor
final class ExampleViewModel: ObservableObject {
    @Published private(set) var state: ViewState = .idle

    private let service: ExampleService

    init(service: ExampleService) {
        self.service = service
    }

    func reload() {
        Task {
            do {
                state = .loading
                let result = try await service.load()
                state = .loaded(result)
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
```

---

## 2. Avoid `Task.detached` by Default

Do not use `Task.detached` unless all of the following are true:

* The work should not inherit the current actor context.
* The closure does not access UI state.
* The closure does not capture non-Sendable objects.
* Input and output are `Sendable`.
* The work is pure computation, isolated IO, or explicitly actor-safe.

Acceptable:

```swift
let result = await Task.detached(priority: .userInitiated) {
    HeavyCalculator.calculate(input)
}.value
```

Bad:

```swift
Task.detached {
    self.title = "Done"
}
```

Recommended:

```swift
Task {
    let result = await service.load()

    await MainActor.run {
        self.title = result.title
    }
}
```

If `self` is already `@MainActor`, prefer:

```swift
Task {
    let result = await service.load()
    self.title = result.title
}
```

---

## 3. Do Not Mutate Captured Variables in Concurrent Tasks

Bad:

```swift
var results: [Item] = []

await withTaskGroup(of: Item.self) { group in
    for input in inputs {
        group.addTask {
            let item = process(input)
            results.append(item)
            return item
        }
    }
}
```

Recommended:

```swift
let results = await withTaskGroup(of: Item.self) { group in
    for input in inputs {
        group.addTask {
            process(input)
        }
    }

    var output: [Item] = []

    for await item in group {
        output.append(item)
    }

    return output
}
```

---

# Actor Rules

## 1. Use Actor for Shared Mutable State

Recommended:

```swift
actor TokenStore {
    private var token: String?

    func getToken() -> String? {
        token
    }

    func setToken(_ token: String?) {
        self.token = token
    }
}
```

Use actors for:

* Shared mutable cache
* Session state
* Token storage
* Long-lived async coordination
* Background data pipeline state
* Thread-safe counters or registries

---

## 2. Do Not Use Actor for Simple Immutable Models

Bad:

```swift
actor UserItem {
    let id: String
    let name: String
}
```

Recommended:

```swift
struct UserItem: Sendable {
    let id: String
    let name: String
}
```

---

# Service Design Rules

## 1. Service Protocols Should Usually Be Sendable

Recommended:

```swift
public protocol DataService: Sendable {
    func loadItems() async throws -> [DataItem]
}
```

If the service is a reference type, make sure its implementation is concurrency-safe.

Recommended:

```swift
public struct RemoteDataService: DataService {
    public func loadItems() async throws -> [DataItem] {
        // Network request
    }
}
```

---

## 2. Services Should Not Update UI Directly

Bad:

```swift
final class DataService {
    func load() async {
        viewModel.title = "Loaded"
    }
}
```

Recommended:

```swift
struct DataService {
    func load() async throws -> [DataItem] {
        // Return data only
    }
}
```

UI update happens in ViewModel:

```swift
@MainActor
final class DataViewModel: ObservableObject {
    @Published private(set) var items: [DataItem] = []

    private let service: DataService

    func reload() {
        Task {
            do {
                items = try await service.load()
            } catch {
                items = []
            }
        }
    }
}
```

---

# Forbidden Fixes

## 1. Do Not Use `DispatchQueue.main.async` to Bypass Actor Isolation

Bad:

```swift
DispatchQueue.main.async {
    self.title = "Done"
}
```

Prefer:

```swift
await MainActor.run {
    self.title = "Done"
}
```

Or keep the method on `@MainActor`:

```swift
@MainActor
func updateTitle() {
    self.title = "Done"
}
```

---

## 2. Do Not Use `nonisolated(unsafe)` Unless Explicitly Justified

Bad:

```swift
nonisolated(unsafe)
var isEnabled: Bool
```

This bypasses compiler safety and can hide data races.

---

## 3. Do Not Use Global Mutable State Without Isolation

Bad:

```swift
enum GlobalState {
    static var isEnabled = false
}
```

Recommended alternatives:

```swift
actor GlobalStateStore {
    private var isEnabled = false

    func getIsEnabled() -> Bool {
        isEnabled
    }

    func setIsEnabled(_ value: Bool) {
        isEnabled = value
    }
}
```

Or for UI-only state:

```swift
@MainActor
final class AppState: ObservableObject {
    @Published var isEnabled = false
}
```

---

## 4. Do Not Use Singleton State Inside Pure Builders

Bad:

```swift
enum MenuBuilder {
    static func build() -> [MenuItem] {
        if AppSettings.shared.isHidden {
            return []
        }

        return []
    }
}
```

Recommended:

```swift
struct MenuBuildOptions: Sendable {
    let isHidden: Bool
}

enum MenuBuilder {
    static func build(options: MenuBuildOptions) -> [MenuItem] {
        guard options.isHidden == false else {
            return []
        }

        return []
    }
}
```

---

# Common Refactoring Patterns

## Pattern 1: MainActor Property Access Error

Problem:

```swift
static func makeItems() -> [Item] {
    if appState.isEnabled {
        return []
    }

    return []
}
```

Fix:

```swift
struct ItemBuildOptions: Sendable {
    let isEnabled: Bool
}
```

```swift
static func makeItems(options: ItemBuildOptions) -> [Item] {
    guard options.isEnabled else {
        return []
    }

    return []
}
```

---

## Pattern 2: MainActor Initializer Called from Nonisolated Context

Problem:

```swift
let viewModel = SomeViewModel()
```

where `SomeViewModel` is `@MainActor`, but the call site is nonisolated.

Fix option A:

```swift
@MainActor
func makeViewModel() -> SomeViewModel {
    SomeViewModel()
}
```

Fix option B:

```swift
let viewModel = await MainActor.run {
    SomeViewModel()
}
```

Recommended choice:

* Use option A when the call site is UI-related.
* Use option B when the caller is async and only needs a temporary MainActor transition.

---

## Pattern 3: Non-Sendable Class Captured in Task

Problem:

```swift
final class Loader {
    var cache: [String: Data] = [:]

    func load() {
        Task.detached {
            self.cache.removeAll()
        }
    }
}
```

Fix option A: make it an actor.

```swift
actor Loader {
    private var cache: [String: Data] = [:]

    func clearCache() {
        cache.removeAll()
    }
}
```

Fix option B: use snapshot values.

```swift
struct LoadRequest: Sendable {
    let ids: [String]
}
```

---

## Pattern 4: UI State Updated from Background Work

Problem:

```swift
func reload() {
    Task.detached {
        let result = await service.load()
        self.items = result
    }
}
```

Fix:

```swift
func reload() {
    Task {
        let result = await service.load()

        await MainActor.run {
            self.items = result
        }
    }
}
```

If the enclosing type is `@MainActor`:

```swift
func reload() {
    Task {
        let result = await service.load()
        self.items = result
    }
}
```

---

# File Layering Guidance

## UI Layer

Usually allowed to be `@MainActor`:

```text
Views/
Screens/
ViewModels/
Coordinators/
Routers/
Presenters/
UIStores/
Controllers/
```

## Domain / Core Layer

Should usually not be `@MainActor`:

```text
Models/
DTOs/
Entities/
Requests/
Responses/
Builders/
Mappers/
Formatters/
Validators/
Repositories/
Services/
Parsers/
UseCases/
Core/
Domain/
Infrastructure/
```

## Exception

If a type in `Core` or `Services` directly owns UI state, reconsider its location or responsibility. It may belong in a UI-facing state layer instead.

---

# Decision Matrix

## When seeing a MainActor isolation error

Choose the fix in this order:

1. If the code is pure model, builder, mapper, parser, formatter, or domain logic:

   * Pass immutable `Sendable` snapshot values into the function.
2. If the code is UI-facing:

   * Mark the method or type as `@MainActor`.
3. If the caller is async and only needs temporary access:

   * Use `await MainActor.run`.
4. If the code owns shared mutable state:

   * Consider `actor`.
5. Do not use:

   * `DispatchQueue.main.async`
   * `nonisolated(unsafe)`
   * broad `@MainActor`
   * unjustified `@unchecked Sendable`

---

## When seeing a Sendable error

Choose the fix in this order:

1. Convert data to immutable `struct`.
2. Add `Sendable` to value types.
3. Avoid capturing reference types in concurrent closures.
4. Use snapshot values.
5. Convert shared mutable reference state into an actor.
6. Use locks only when actor is unsuitable.
7. Use `@unchecked Sendable` only with explicit thread-safety justification.

---

# Pre-Change Checklist

Before changing Swift code, check:

1. Is this type UI-facing or core/domain-facing?
2. Does this code access `@MainActor` state?
3. Does this code mutate UI state?
4. Does this code run inside `Task`, `Task.detached`, task group, async closure, or actor?
5. Does this code capture `self`?
6. Is `self` Sendable or actor-isolated?
7. Are mutable variables captured by concurrent closures?
8. Are global singletons being accessed from nonisolated code?
9. Can this be solved with snapshot passing?
10. Can this model be immutable and `Sendable`?

---

# Post-Change Checklist

After changing Swift code, verify:

1. No unnecessary broad `@MainActor` was added.
2. No `nonisolated(unsafe)` was added.
3. No unjustified `@unchecked Sendable` was added.
4. No `DispatchQueue.main.async` was used to bypass actor isolation.
5. Core/model/domain code does not directly read UI state.
6. Cross-actor data is immutable and `Sendable`.
7. `Task.detached` is avoided unless justified.
8. Captured values in concurrent closures are safe.
9. UI updates happen on `MainActor`.
10. Heavy computation is not moved onto the main actor accidentally.

---

# Required Output When Fixing Concurrency Errors

When fixing a Swift concurrency issue, explain:

1. The exact reason for the compiler error.
2. Which actor or concurrency boundary was violated.
3. The recommended fix.
4. The code changes.
5. Why broader `@MainActor` was not chosen, if applicable.
6. Whether call sites need to change.
7. Whether the fix changes runtime behavior.
8. Whether additional tests are recommended.

---

# Default Recommendation

When multiple fixes are possible, prefer this architecture:

```text
UI layer reads UI/MainActor state
↓
Create immutable Sendable snapshot
↓
Pass snapshot into core/domain/model/builder/service code
↓
Return immutable Sendable result
↓
UI layer applies result on MainActor
```

Avoid this architecture:

```text
Core/domain/model code directly reads MainActor state or global mutable singleton state
```

---

# Final Rule

Do not optimize for the smallest edit only.

Optimize for:

* Swift 6 strict concurrency compliance
* clear actor boundaries
* minimal main-thread pollution
* immutable data flow
* testability
* long-term maintainability
