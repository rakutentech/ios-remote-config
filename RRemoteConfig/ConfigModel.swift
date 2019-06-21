internal struct ConfigModel: Decodable {
    let config: [String: String]

    enum CodingKeys: String, CodingKey {
        case config = "body"
    }
}
