protocol Parsable {
    init?(data: Data)
}

internal struct ConfigModel: Parsable {
    let jsonData: Data
    let config: [String: String]
    var keyId: String?
    var signature: String?

    init?(data: Data) {
        var dictionary: [String: Any]?
        print("payload data as string: \(String(data: data, encoding: .utf8) ?? "data cannot be encoded to utf8 string")")
        do {
            dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch let error {
            Logger.e(error.localizedDescription)
            return nil
        }
        self.jsonData = data
        self.config = dictionary?["body"] as? [String: String] ?? [:]
        self.keyId = dictionary?["keyId"] as? String
    }
}

internal struct KeyModel: Decodable, Parsable {
    let id: String
    let key: String
    let createdAt: String

    init?(data: Data) {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
            return nil
        }
        self.id = dictionary["id"] ?? ""
        self.key = dictionary["key"] ?? ""
        self.createdAt = dictionary["createdAt"] ?? ""
    }
}
