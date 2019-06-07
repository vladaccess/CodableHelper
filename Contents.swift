import Foundation

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(_ type: T.Type = T.self,
                                     key: Key, using formatter: DateFormatter) throws -> T? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        return formatter.date(from: stringValue) as? T
    }
    
    func decode<T: Decodable>(_ key: Key, as type:T.Type = T.self) throws -> T {
        return try decode(T.self, forKey: key)
    }
    
    func decodeIfPresent<T: Decodable>(_ key: Key, as type:T.Type = T.self) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }
    //Decode not nil value
    func decode<T: Decodable>(_ type: T.Type = T.self, key: Key, replace: T) throws -> T {
        guard let valueNotNil = try? decode(type, forKey: key) else {
            return replace
        }
        return valueNotNil
    }
}
