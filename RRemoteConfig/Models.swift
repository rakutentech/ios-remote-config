protocol Parsable {
    init?(data: Data)
}

public typealias ConfigDictionary = [String: String]

internal struct ConfigModel: Parsable {
    let jsonData: Data
    let config: ConfigDictionary
    var keyId: String?
    var signature: String?

    init?(data: Data) {
        var dictionary: [String: Any]?
        var jsonData = data
        Logger.v("Raw payload data as string: \(String(describing: String(data: jsonData, encoding: .utf8)))")

        do {
            dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        } catch let error {
            Logger.e(error.localizedDescription)
            return nil
        }

        guard let config = dictionary?["body"] as? ConfigDictionary,
            let keyId = dictionary?["keyId"] as? String else {
            return nil
        }

        self.jsonData = jsonData.trailingNewlineTrimmed()
        self.config =  config
        self.keyId =  keyId
    }
}

internal struct KeyModel: Decodable, Parsable {
    let id: String
    let key: String
    let createdAt: String

    init?(data: Data) {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
            let id = dictionary["id"],
            let key = dictionary["key"],
            let createdAt = dictionary["createdAt"] else {
            return nil
        }
        self.id = id
        self.key = key
        self.createdAt = createdAt
    }
}

fileprivate extension Data {
    mutating func trailingNewlineTrimmed() -> Data {
        let data = self
        guard let dataString = String(data: data, encoding: .utf8) else {
            return self
        }

        if dataString.hasSuffix("\n") {
            Logger.v("Trimming newline from data")
            let trimmedDataString = String(dataString.dropLast())
            self = trimmedDataString.data(using: .utf8) ?? data
        }
        return self
    }
}
