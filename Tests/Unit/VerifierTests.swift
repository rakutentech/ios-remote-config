import Quick
import Nimble
import XCTest
@testable import RRemoteConfig

// Both Android and iOS SDKs receive and verify against the same crypto algos so we can
// reuse the key and signature generated for the Android tests:
// https://github.com/rakutentech/android-remote-config/blob/master/remote-config/src/test/kotlin/com/rakuten/tech/mobile/remoteconfig/verification/SignatureVerifierSpec.kt#L10

class VerifierSpec: QuickSpec {
    override func spec() {
        let verifier = Verifier()

        it("should verify the signature") {
            let verified = verifier.verify(signatureBase64: "MEUCIHRXIgQhyASpyCP1Lg0ZSn2/bUbTq6U7jpKBa9Ow/1OTAiEA4jAq48uDgNl7UM7LmxhiRhPPNnTolokScTq5ijbp5fU=",
                                           dictionary: ["testKey": "test_value"],
                                           keyBase64: "BI2zZr56ghnMLXBMeC4bkIVg6zpFD2ICIS7V6cWo8p8LkibuershO+Hd5ru6oBFLlUk6IFFOIVfHKiOenHLBNIY=")
            expect(verified).to(beTrue())
        }
    }
}
