import Foundation

public protocol AnyDateFormatter {
    func date(from string: String) -> Date?
    func string(from date: Date) -> String
}

extension DateFormatter: AnyDateFormatter {}

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(_ key: Key,
                                     as type: T.Type = T.self) throws -> T {
        return try self.decode(T.self, forKey: key)
    }
    
    public func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }
    
    public func decode<T: Decodable, E: AnyDateFormatter>(_ type: T.Type = T.self,
                                                          key: Key,
                                                          using formatter: E) throws -> T? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        return formatter.date(from: stringValue) as? T
    }
    
    public func decode<T: Decodable>(
        forKey key: Key,
        default defaultExpression: @autoclosure () -> T
        ) throws -> T {
        return (try? decode(T.self, forKey: key)) ?? defaultExpression()
    }
    
    public func decodeBool(_ key: Key) throws -> Bool {
        if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue
        } else if let intValue = try? decode(Int.self, forKey: key) {
            return Bool(intValue)
        } else if let doubleValue = try? decode(Double.self, forKey: key) {
            return Bool(Int(doubleValue))
        } else if let stringValue = try? decode(String.self, forKey: key) {
            return ["1", "true", "y", "t"].contains(stringValue.lowercased())
        } else {
            return false
        }
    }
    
    public func decodeString(_ key: Key) throws -> String {
        var tempValue = ""
        if let stringValue = try? decode(String.self, forKey: key) {
            tempValue = stringValue
        } else if let intValue = try? decode(Int.self, forKey: key) {
            tempValue = String(intValue)
        } else if let doubleValue = try? decode(Double.self, forKey: key) {
            tempValue = String(doubleValue)
        } else if let boolValue = try? decode(Bool.self, forKey: key) {
            tempValue = String(boolValue)
        }
        return tempValue
    }
    
    public func decodeInt(_ key: Key) throws -> Int {
        var tempValue = 0
        if let intValue = try? decode(Int.self, forKey: key) {
            tempValue = intValue
        } else if let doubleValue = try? decode(Double.self, forKey: key) {
            tempValue = Int(doubleValue)
        } else if let stringValue = try? decode(String.self, forKey: key), let intValue = Int(stringValue) {
            tempValue = intValue
        } else if let boolValue = try? decode(Bool.self, forKey: key) {
            tempValue = Int(boolValue)
        }
        return tempValue
    }
    
    public func decodeDouble(_ key: Key) throws -> Double {
        var tempValue = 0.0
        if let doubleValue = try? decode(Double.self, forKey: key) {
            tempValue = doubleValue
        } else if let intValue = try? decode(Int.self, forKey: key) {
            tempValue = Double(intValue)
        } else if let stringValue = try? decode(String.self, forKey: key), let doubleValue = Double(stringValue) {
            tempValue = doubleValue
        } else if let boolValue = try? decode(Bool.self, forKey: key) {
            tempValue = Double(boolValue)
        }
        return tempValue
    }
    
    public func decodeDoubleIfPresent(_ key: Key) throws -> Double? {
        return contains(key) ? try decodeDouble(key) : nil
    }
    
    public func decodeIntIfPresent(_ key: Key) throws -> Int? {
        return contains(key) ? try decodeInt(key) : nil
    }
    
    public func decodeBoolIfPresent(_ key: Key) throws -> Bool? {
        return contains(key) ? try decodeBool(key) : nil
    }
    
    public func decodeStringIfPresent(_ key: Key) throws -> String? {
        return contains(key) ? try decodeString(key) : nil
    }
    
    func nestedContainerIfPresent<NestedKey>(keyedBy type: NestedKey.Type,
                                             forKey key: KeyedDecodingContainer.Key) throws -> KeyedDecodingContainer<NestedKey>? where NestedKey: CodingKey {
        return contains(key) ? try nestedContainer(keyedBy: type, forKey: key) : nil
    }
}

extension Decodable {
    init(jsonDictionary: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        self = try data.decoded()
    }
}

func decoded<T: Decodable>(_ decoder: JSONDecoder = JSONDecoder(),
                           key: T.Type = T.self) throws -> T {
    return try decoder.decode(key, from: self)
}

