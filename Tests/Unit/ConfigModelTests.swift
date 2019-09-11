import Quick
import Nimble
@testable import RRemoteConfig

class ConfigModelSpec: QuickSpec {
    override func spec() {
        context("initialization") {
            describe("when json is the expected format") {
                let data = """
                    {"body":{"key1":"val1","key2":"val2","key3":"val3"},"keyId":"a1b2c3"}
                    """.data(using: .utf8) ?? Data()
                let config = ConfigModel(data: data)

                it("stores the original data in the jsonData property") {
                    expect(config?.jsonData).to(equal(data))
                }

                it("sets the config dictionary with the expected number of keys") {
                    expect(config?.config.count).to(equal(["key1": "val1", "key2": "val2", "key3": "val3"].count))
                }

                it("sets the config dictionary with the expected key-value") {
                    expect(config?.config["key1"]).to(equal("val1"))
                }

                it("sets the expected key id") {
                    expect(config?.keyId).to(equal("a1b2c3"))
                }
            }
            describe("when json is not the expected format") {
                it("returns nil when json cannot be serialized") {
                    let config = ConfigModel(data: "\"string\"".data(using: .utf8) ?? Data())

                    expect(config).to(beNil())
                }

                it("returns nil when json does not have a body object") {
                    let dataString = """
                    "key1":"val1","key2":"val2","key3":"val3","keyId":"a1b2c3"
                    """
                    let config = ConfigModel(data: dataString.data(using: .utf8) ?? Data())

                    expect(config).to(beNil())
                }
            }
            describe("when json has unexpected newline") {
                it("stores the modified data with the newline trimmed in the jsonData property") {
                    let dataWithNewline = """
                    {"body":{"key1":"val1","key2":"val2","key3":"val3"},"keyId":"a1b2c3"}

                    """.data(using: .utf8) ?? Data()
                    let config = ConfigModel(data: dataWithNewline)
                    let dataWithoutNewline = """
                    {"body":{"key1":"val1","key2":"val2","key3":"val3"},"keyId":"a1b2c3"}
                    """.data(using: .utf8)

                    expect(config?.jsonData).to(equal(dataWithoutNewline))
                }
            }
        }
    }
}
