import Foundation

protocol Cacheable: Codable {
    var cacheKey: String { get }
    var expirationInterval: TimeInterval { get }
}

struct CacheItem<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let expirationInterval: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

class CacheManager {
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let memoryCache = NSCache<NSString, NSData>()
    
    // Cache expiration times
    enum CacheExpiration {
        static let short: TimeInterval = 5 * 60 // 5 minutes
        static let medium: TimeInterval = 30 * 60 // 30 minutes
        static let long: TimeInterval = 24 * 60 * 60 // 24 hours
        static let extended: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    }
    
    private init() {
        // Create cache directory
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("MerotInternalCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Clean up expired cache on init
        cleanupExpiredCache()
    }
    
    // MARK: - Generic Cache Methods
    
    func cache<T: Codable>(_ object: T, forKey key: String, expirationInterval: TimeInterval = CacheExpiration.medium) {
        let cacheItem = CacheItem(data: object, timestamp: Date(), expirationInterval: expirationInterval)
        
        // Cache in memory
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(cacheItem)
            memoryCache.setObject(data as NSData, forKey: key as NSString)
            print("CacheManager: Successfully cached object in memory for key: \(key)")
            
            // Cache to disk
            let fileURL = cacheDirectory.appendingPathComponent("\(key).cache")
            try data.write(to: fileURL)
            print("CacheManager: Successfully cached object to disk for key: \(key)")
        } catch {
            print("CacheManager: Error caching object for key \(key): \(error)")
        }
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        print("CacheManager: Attempting to retrieve cached data for key: \(key)")
        
        // Try memory cache first
        if let data = memoryCache.object(forKey: key as NSString) as Data? {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let cacheItem = try decoder.decode(CacheItem<T>.self, from: data)
                if !cacheItem.isExpired {
                    print("CacheManager: Found valid cached data in memory for key: \(key)")
                    return cacheItem.data
                } else {
                    print("CacheManager: Cached data in memory expired for key: \(key)")
                }
            } catch {
                print("CacheManager: Error decoding cached data from memory for key \(key): \(error)")
            }
        }
        
        // Try disk cache
        let fileURL = cacheDirectory.appendingPathComponent("\(key).cache")
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let cacheItem = try decoder.decode(CacheItem<T>.self, from: data)
            
            if !cacheItem.isExpired {
                print("CacheManager: Found valid cached data on disk for key: \(key)")
                // Update memory cache
                do {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    let encodedData = try encoder.encode(cacheItem)
                    memoryCache.setObject(encodedData as NSData, forKey: key as NSString)
                } catch {
                    print("CacheManager: Failed to update memory cache: \(error)")
                }
                return cacheItem.data
            } else {
                print("CacheManager: Cached data on disk expired for key: \(key)")
                // Remove expired cache
                try? fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("CacheManager: Error reading/decoding cached data from disk for key \(key): \(error)")
        }
        
        print("CacheManager: No valid cached data found for key: \(key)")
        return nil
    }
    
    func removeCache(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).cache")
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearAllCache() {
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        if let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for url in contents {
                try? fileManager.removeItem(at: url)
            }
        }
    }
    
    func cleanupExpiredCache() {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for url in contents {
            if let data = try? Data(contentsOf: url),
               let cacheItem = try? JSONDecoder().decode(CacheItem<Data>.self, from: data),
               cacheItem.isExpired {
                try? fileManager.removeItem(at: url)
            }
        }
    }
    
    // MARK: - Specific Cache Keys
    
    struct CacheKeys {
        static func adminDashboard() -> String { "admin_dashboard" }
        static func adminStats() -> String { "admin_stats" }
        static func employers(page: Int, search: String?) -> String {
            "employers_page_\(page)_search_\(search ?? "none")"
        }
        static func employees(page: Int, search: String?, status: String? = nil) -> String {
            "employees_page_\(page)_search_\(search ?? "none")_status_\(status ?? "all")"
        }
        static func employer(id: Int) -> String { "employer_\(id)" }
        static func employee(id: Int) -> String { "employee_\(id)" }
        static func userProfile() -> String { "user_profile" }
        static func dashboard() -> String { "dashboard" }
        static func timeOffRequests() -> String { "time_off_requests" }
        static func holidays() -> String { "holidays" }
        static func invoices(page: Int, status: String?) -> String {
            "invoices_page_\(page)_status_\(status ?? "all")"
        }
    }
    
    // MARK: - Cache Testing
    
    func testCaching() -> Bool {
        let testKey = "cache_test"
        let testData = "Test data for cache validation"
        
        // Try to cache test data
        cache(testData, forKey: testKey, expirationInterval: 60) // 1 minute
        
        // Try to retrieve test data
        let retrievedData = retrieve(String.self, forKey: testKey)
        
        // Clean up test data
        removeCache(forKey: testKey)
        
        // Return whether the test passed
        return retrievedData == testData
    }
    
    // MARK: - Cache Statistics
    
    func getCacheStatistics() -> CacheStatistics {
        var diskCacheSize: Int64 = 0
        var diskCacheCount = 0
        
        if let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for url in contents {
                if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = resourceValues.fileSize {
                    diskCacheSize += Int64(fileSize)
                    diskCacheCount += 1
                }
            }
        }
        
        return CacheStatistics(
            memoryCacheCount: memoryCache.countLimit,
            diskCacheCount: diskCacheCount,
            diskCacheSize: diskCacheSize
        )
    }
}

struct CacheStatistics {
    let memoryCacheCount: Int
    let diskCacheCount: Int
    let diskCacheSize: Int64
    
    var diskCacheSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: diskCacheSize, countStyle: .file)
    }
}

// MARK: - Cache Extensions for Models

extension AdminDashboardData: Cacheable {
    var cacheKey: String { CacheManager.CacheKeys.adminDashboard() }
    var expirationInterval: TimeInterval { CacheManager.CacheExpiration.short }
}

extension AdminStats: Cacheable {
    var cacheKey: String { CacheManager.CacheKeys.adminStats() }
    var expirationInterval: TimeInterval { CacheManager.CacheExpiration.short }
}

extension DashboardData: Cacheable {
    var cacheKey: String { CacheManager.CacheKeys.dashboard() }
    var expirationInterval: TimeInterval { CacheManager.CacheExpiration.medium }
}

extension Employer: Cacheable {
    var cacheKey: String { CacheManager.CacheKeys.employer(id: id ?? 0) }
    var expirationInterval: TimeInterval { CacheManager.CacheExpiration.long }
}

extension Employee: Cacheable {
    var cacheKey: String { CacheManager.CacheKeys.employee(id: id) }
    var expirationInterval: TimeInterval { CacheManager.CacheExpiration.long }
}