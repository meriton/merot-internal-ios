import Foundation

actor RequestManager {
    private var activeTasks: [String: Task<Any, Error>] = [:]
    
    func executeRequest<T>(
        key: String,
        request: @escaping () async throws -> T
    ) async throws -> T {
        // Cancel any existing task with the same key
        if let existingTask = activeTasks[key] {
            existingTask.cancel()
        }
        
        // Create a new task
        let task = Task<Any, Error> {
            do {
                let result = try await request()
                await cleanupTask(key: key)
                return result
            } catch {
                await cleanupTask(key: key)
                throw error
            }
        }
        
        // Store the task
        activeTasks[key] = task
        
        // Execute and return the result
        do {
            let result = try await task.value
            return result as! T
        } catch {
            throw error
        }
    }
    
    func cancelRequest(key: String) {
        activeTasks[key]?.cancel()
        activeTasks.removeValue(forKey: key)
    }
    
    func cancelAllRequests() {
        for task in activeTasks.values {
            task.cancel()
        }
        activeTasks.removeAll()
    }
    
    private func cleanupTask(key: String) {
        activeTasks.removeValue(forKey: key)
    }
    
    var activeRequestCount: Int {
        activeTasks.count
    }
}