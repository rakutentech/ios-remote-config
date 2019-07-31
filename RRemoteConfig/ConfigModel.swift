internal struct ConfigModel: Decodable {
    let config: [String: String]
    let keyId: String
    var signature: String?

    init(config: [String: String],
         keyId: String = "") {
        self.config = config
        self.keyId = keyId
    }

    enum CodingKeys: String, CodingKey {
        case keyId, config = "body"
    }
}
