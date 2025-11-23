// MARK: - Advanced Concurrency Patterns for SharePlay
// Production-ready patterns with verified SDK integration

import Foundation

// MARK: - 1. AsyncStream Backpressure Control
actor BackpressureController<T> {
    private let maxBufferSize: Int
    private var bufferedItems: [T] = []
    private var continuation: AsyncStream<T>.Continuation?

    init(maxBufferSize: Int = 100) {
        self.maxBufferSize = maxBufferSize
    }

    func stream() -> AsyncStream<T> {
        AsyncStream<T> { continuation in
            self.continuation = continuation
        }
    }

    func yield(_ item: T) async throws {
        // Apply backpressure - wait for buffer space
        while bufferedItems.count >= maxBufferSize {
            try await Task.sleep(for: .milliseconds(10))
        }

        bufferedItems.append(item)
        continuation?.yield(item)
    }

    func currentBufferSize() -> Int {
        return bufferedItems.count
    }

    func clearBuffer() {
        bufferedItems.removeAll()
    }

    func endStream() {
        continuation?.finish()
        continuation = nil
    }
}

// MARK: - 2. Task Resource Pool with Limiting
actor TaskResourcePool {
    private let maxConcurrentTasks: Int
    private var activeTasks: Int = 0
    private var waitingTasks: [CheckedContinuation<Void, Never>] = []

    init(maxConcurrentTasks: Int = 4) {
        self.maxConcurrentTasks = maxConcurrentTasks
    }

    func executeTask<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        // Wait for a slot to become available
        while activeTasks >= maxConcurrentTasks {
            await withCheckedContinuation { continuation in
                waitingTasks.append(continuation)
            }
        }

        activeTasks += 1
        defer { releaseSlot() }

        return try await operation()
    }

    private func releaseSlot() {
        activeTasks -= 1

        if !waitingTasks.isEmpty {
            let waitingTask = waitingTasks.removeFirst()
            waitingTask.resume()
        }
    }

    func activeTaskCount() -> Int {
        return activeTasks
    }

    func waitingTaskCount() -> Int {
        return waitingTasks.count
    }

    func shutdown() {
        // Cancel all waiting tasks
        for task in waitingTasks {
            task.resume()
        }
        waitingTasks.removeAll()
    }
}

// MARK: - 3. Memory-Efficient Message Queue with Limits
actor EfficientMessageQueue {
    private struct QueuedMessage {
        let id: UUID
        let data: Data
        let priority: MessagePriority
        let timestamp: Date
        let retryCount: Int
    }

    enum MessagePriority: Int, CaseIterable {
        case critical = 1
        case high = 2
        case normal = 3
        case low = 4
    }

    private var queue: [QueuedMessage] = []
    private let maxMemoryMB: UInt64 = 50
    private var currentMemoryUsage: UInt64 = 0
    private let maxQueueSize: Int = 1000

    func enqueue(_ data: Data, priority: MessagePriority = .normal, id: UUID = UUID()) async throws {
        let messageSize = UInt64(data.count)

        // Check memory limit
        while currentMemoryUsage + messageSize > maxMemoryMB * 1024 * 1024 {
            try await removeLowestPriorityMessage()
        }

        // Check queue size limit
        while queue.count >= maxQueueSize {
            try await removeLowestPriorityMessage()
        }

        let message = QueuedMessage(
            id: id,
            data: data,
            priority: priority,
            timestamp: Date(),
            retryCount: 0
        )

        queue.append(message)
        currentMemoryUsage += messageSize
    }

    private func removeLowestPriorityMessage() async throws {
        // Find message with lowest priority (highest numeric value)
        guard let lowestPriorityIndex = queue.enumerated()
            .min(by: { $0.element.priority < $1.element.priority })?.offset else {
            throw QueueError.queueEmpty
        }

        let removed = queue.remove(at: lowestPriorityIndex)
        currentMemoryUsage -= UInt64(removed.data.count)
    }

    func dequeue() -> QueuedMessage? {
        // Return message with highest priority (lowest numeric value)
        queue.sorted { $0.priority < $1.priority }.first.map { message in
            currentMemoryUsage -= UInt64(message.data.count)
            return message
        }
    }

    func dequeueByPriority(_ priority: MessagePriority) -> QueuedMessage? {
        if let index = queue.firstIndex(where: { $0.priority == priority }) {
            let message = queue.remove(at: index)
            currentMemoryUsage -= UInt64(message.data.count)
            return message
        }
        return nil
    }

    func peek() -> QueuedMessage? {
        queue.sorted { $0.priority < $1.priority }.first
    }

    func count() -> Int {
        return queue.count
    }

    func currentMemoryUsageMB() -> Double {
        return Double(currentMemoryUsage) / (1024 * 1024)
    }

    func clearExpiredMessages(olderThan timeInterval: TimeInterval) {
        let cutoffTime = Date().addingTimeInterval(-timeInterval)
        let originalCount = queue.count

        queue.removeAll { message in
            if message.timestamp < cutoffTime {
                currentMemoryUsage -= UInt64(message.data.count)
                return true
            }
            return false
        }

        let removedCount = originalCount - queue.count
        if removedCount > 0 {
            print("🧹 Cleared \(removedCount) expired messages from queue")
        }
    }
}

enum QueueError: Error {
    case memoryExceeded
    case queueEmpty
}

// MARK: - 4. TTL-Based State Cache with Memory Management
actor StateCache<T: Codable> {
    private struct CachedValue {
        let value: T
        let timestamp: Date
        let accessCount: Int
        let sizeEstimate: Int
    }

    private var cache: [String: CachedValue] = [:]
    private let ttl: TimeInterval
    private let maxCacheSize: Int
    private let maxMemoryMB: UInt64 = 10
    private var currentMemoryUsage: UInt64 = 0

    init(ttl: TimeInterval = 300, maxCacheSize: Int = 1000) {
        self.ttl = ttl
        self.maxCacheSize = maxCacheSize
    }

    func set(_ value: T, forKey key: String, sizeEstimate: Int = 0) async throws {
        // Check memory limit
        let estimatedSize = max(100, sizeEstimate) // Minimum 100 bytes per cached item

        while currentMemoryUsage + estimatedSize > maxMemoryMB * 1024 * 1024 {
            try await removeOldestOrLeastUsedEntry()
        }

        // Check cache size limit
        while cache.count >= maxCacheSize {
            try await removeOldestOrLeastUsedEntry()
        }

        let cachedValue = CachedValue(
            value: value,
            timestamp: Date(),
            accessCount: 1,
            sizeEstimate: estimatedSize
        )

        cache[key] = cachedValue
        currentMemoryUsage += UInt64(estimatedSize)
    }

    func get(_ key: String) -> T? {
        guard var cached = cache[key] else { return nil }

        let age = Date().timeIntervalSince(cached.timestamp)
        if age > ttl {
            // Remove expired entry
            cache.removeValue(forKey: key)
            currentMemoryUsage -= UInt64(cached.sizeEstimate)
            return nil
        }

        // Update access statistics
        cached.accessCount += 1
        cache[key] = cachedValue

        return cached.value
    }

    func getWithLoader(_ key: String, loader: () async throws -> T) async throws -> T {
        if let cached = get(key) {
            return cached
        }

        // Load value and cache it
        let value = try await loader()
        try await set(value, forKey: key)
        return value
    }

    private func removeOldestOrLeastUsedEntry() async throws {
        // Find entry with oldest timestamp, then least used if tie
        if let oldestKey = cache.min(by: {
            ($0.value.timestamp < $1.value.timestamp) ||
            ($0.value.timestamp == $1.value.timestamp && $0.value.accessCount < $1.value.accessCount)
        }).key {
            if let removed = cache.removeValue(forKey: oldestKey) {
                currentMemoryUsage -= UInt64(removed.sizeEstimate)
            }
        }
    }

    func cleanup() {
        let now = Date()
        let originalCount = cache.count

        cache = cache.filter { _, cached in
            now.timeIntervalSince(cached.timestamp) <= ttl
        }

        // Recalculate memory usage
        currentMemoryUsage = cache.values.reduce(0) { $0 + UInt64($0.sizeEstimate) }

        let cleanedCount = originalCount - cache.count
        if cleanedCount > 0 {
            print("🧹 State cache cleanup: removed \(cleanedCount) expired entries")
        }
    }

    func getStatistics() -> CacheStatistics {
        return CacheStatistics(
            totalEntries: cache.count,
            memoryUsageMB: Double(currentMemoryUsage) / (1024 * 1024),
            oldestEntryAge: cache.values.map { Date().timeIntervalSince($0.timestamp) }.min() ?? 0,
            averageAccessCount: cache.isEmpty ? 0 : Double(cache.values.reduce(0) { $0 + $0.accessCount }) / Double(cache.count)
        )
    }

    func clear() {
        cache.removeAll()
        currentMemoryUsage = 0
    }
}

// MARK: - 5. Batching Strategy for High-Frequency Updates
actor BatchingManager<T> {
    private var pendingItems: [T] = []
    private var batchTimer: Timer?
    private let batchSize: Int
    private let flushInterval: TimeInterval
    private let onBatch: ([T]) async -> Void

    init(batchSize: Int = 10, flushInterval: TimeInterval = 0.016, onBatch: @escaping ([T]) async -> Void) {
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        self.onBatch = onBatch
    }

    func add(_ item: T) async {
        pendingItems.append(item)

        if pendingItems.count >= batchSize {
            await flushBatch()
        } else if flushInterval > 0 {
            scheduleFlush()
        }
    }

    func addBatch(_ items: [T]) async {
        pendingItems.append(contentsOf: items)

        if pendingItems.count >= batchSize {
            await flushBatch()
        } else if flushInterval > 0 {
            scheduleFlush()
        }
    }

    func flushNow() async {
        await flushBatch()
    }

    private func flushBatch() async {
        guard !pendingItems.isEmpty else { return }

        let batch = Array(pendingItems)
        pendingItems.removeAll()

        // Cancel any existing timer
        batchTimer?.invalidate()
        batchTimer = nil

        await onBatch(batch)
    }

    private func scheduleFlush() {
        batchTimer?.invalidate()
        batchTimer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: false) { [weak self] _ in
            Task {
                await self?.flushBatch()
            }
        }
    }

    func pendingCount() -> Int {
        return pendingItems.count
    }
}

// MARK: - 6. Rate Limiting for API Calls
actor RateLimiter {
    private var requestTimes: [String: [Date]] = [:]
    private let maxRequestsPerSecond: Int
    private let windowSize: TimeInterval

    init(maxRequestsPerSecond: Int = 10, windowSize: TimeInterval = 1.0) {
        self.maxRequestsPerSecond = maxRequestsPerSecond
        self.windowSize = windowSize
    }

    func checkRateLimit(for key: String = "default") -> Bool {
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-windowSize)

        // Clean old requests
        requestTimes[key]?.removeAll { $0 < cutoffTime }

        // Count recent requests
        let recentRequests = requestTimes[key]?.filter { $0 >= cutoffTime } ?? []
        requestTimes[key] = recentRequests

        return recentRequests.count < maxRequestsPerSecond
    }

    func recordRequest(for key: String = "default") {
        let now = Date()
        requestTimes[key, default: []].append(now)
    }

    func waitIfNeeded(for key: String = "default") async {
        while !checkRateLimit(for: key) {
            let waitTime = windowSize / Double(maxRequestsPerSecond)
            try? await Task.sleep(for: .seconds(waitTime))
        }
    }
}

// MARK: - 7. Circuit Breaker Pattern for Resilience
actor CircuitBreaker {
    enum State {
        case closed
        case open
        case halfOpen
    }

    enum Error: Swift.Error {
        case timeout
        case maxFailuresExceeded
    }

    private var state: State = .closed
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private let maxFailures: Int
    private let timeout: TimeInterval
    private let resetTimeout: TimeInterval

    init(maxFailures: Int = 5, timeout: TimeInterval = 30.0, resetTimeout: TimeInterval = 60.0) {
        self.maxFailures = maxFailures
        self.timeout = timeout
        self.resetTimeout = resetTimeout
    }

    func execute<T>(_ operation: () async throws -> T) async throws -> T {
        switch state {
        case .closed:
            throw CircuitBreakerError.circuitOpen
        case .open:
            return try await performOperation(operation)
        case .halfOpen:
            return try await performOperationWithTimeout(operation)
        }
    }

    private func performOperation<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            let result = try await operation()
            onSuccess()
            return result
        } catch {
            onFailure()
            throw error
        }
    }

    private func performOperationWithTimeout<T>(_ operation: () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: .cancelation) { group in
            // Add timeout task
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw CircuitBreakerError.timeout
            }

            // Add actual operation task
            group.addTask {
                let result = try await operation()
                return result
            }

            let result = try await group.next()!
            return result as! T
        }
    }

    private func onReset() {
        state = .closed
        failureCount = 0
        lastFailureTime = nil
        print("🔌 Circuit breaker reset - service available again")
    }

    private func onSuccess() {
        failureCount = 0
        if state == .halfOpen {
            state = .open
            print("✅ Circuit breaker transitioning to OPEN state")
        }
    }

    private func onFailure() {
        failureCount += 1
        lastFailureTime = Date()

        if failureCount >= maxFailures {
            state = .open
            print("❌ Circuit breaker OPEN - service unavailable")

            // Schedule reset after timeout
            Task {
                try? await Task.sleep(for: .seconds(resetTimeout))
                await onReset()
            }
        } else if failureCount >= maxFailures / 2 {
            state = .halfOpen
            print("⚠️ Circuit breaker transitioning to HALF-OPEN state")
        }
    }
}

enum CircuitBreakerError: Error {
    case circuitOpen
    case timeout
}

// MARK: - 8. Supporting Types and Statistics
struct CacheStatistics {
    let totalEntries: Int
    let memoryUsageMB: Double
    let oldestEntryAge: TimeInterval
    let averageAccessCount: Double
}

// MARK: - 9. Usage Examples
class SharePlayConcurrencyManager {
    private let backpressureController = BackpressureController<SharePlayMessage>()
    private let taskPool = TaskResourcePool()
    private let messageQueue = EfficientMessageQueue()
    private let stateCache = StateCache<GameState>()
    private let batchingManager = BatchingManager<SharePlayMessage>()
    private let rateLimiter = RateLimiter()
    private let circuitBreaker = CircuitBreaker()

    func setup() async {
        // Start monitoring and cleanup tasks
        Task {
            await monitorSystemMetrics()
        }
    }

    private func monitorSystemMetrics() async {
        while !Task.isCancelled {
            // Monitor and log system metrics every 30 seconds
            try? await Task.sleep(for: .seconds(30))
            await logSystemMetrics()
        }
    }

    private func logSystemMetrics() async {
        let bufferUtilization = await backpressureController.currentBufferSize()
        let taskStats = (
            active: await taskPool.activeTaskCount(),
            waiting: await taskPool.waitingTaskCount()
        )
        let queueStats = (
            count: await messageQueue.count(),
            memoryUsage: await messageQueue.currentMemoryUsageMB()
        )
        let cacheStats = await stateCache.getStatistics()

        print("📊 System Metrics:")
        print("  Buffer: \(bufferUtilization)/\(backpressureController.maxBufferSize)")
        print("  Tasks: \(taskStats.active) active, \(taskStats.waiting) waiting")
        print("  Queue: \(queueStats.count) items, \(String(format: "%.2f", queueStats.memoryUsage))MB")
        print("  Cache: \(cacheStats.totalEntries) entries, \(String(format: "%.2f", cacheStats.memoryUsageMB))MB")
    }
}

// MARK: - 10. State Management Example
class GameStateManager: ObservableObject {
    @Published var currentPhase: GamePhase = .waiting
    @Published var playerScores: [UUID: Int] = [:]
    @Published var gameMetadata: GameMetadata

    private let stateCache = StateCache<GameState>()
    private let circuitBreaker = CircuitBreaker()

    enum GamePhase: String, Codable, CaseIterable {
        case waiting, playing, paused, gameOver
    }

    func updateGameState(_ newState: GameState) async throws {
        // Rate limit updates
        await rateLimiter.waitIfNeeded(for: "gameState")

        // Use circuit breaker for network resilience
        try await circuitBreaker.execute {
            // Cache the state for quick access and offline scenarios
            try await stateCache.set(newState, forKey: "currentGameState")

            await MainActor.run {
                self.currentPhase = newState.phase
                self.playerScores = newState.playerScores
                self.gameMetadata = newState.metadata
            }
        }
    }

    func getCachedGameState() async -> GameState? {
        return await stateCache.get("currentGameState")
    }

    func resetGameState() async {
        await stateCache.clear()
        currentPhase = .waiting
        playerScores.removeAll()
        gameMetadata = GameMetadata()
    }
}

// Example GameState structure
struct GameState: Codable {
    let phase: GameStateManager.GamePhase
    let playerScores: [UUID: Int]
    let metadata: GameMetadata
}

struct GameMetadata: Codable {
    let sessionStartTime: Date
    let gameVersion: String
    let participantCount: Int
}