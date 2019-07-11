import Quick
import Nimble
@testable import RRemoteConfig

class ConfigPollerSpec: QuickSpec {
    override func spec() {
        describe("init function") {
            it("sets default delay of 1 hour when no delay param received") {
                let poller = ConfigPoller()

                expect(poller.delay).to(equal(3600.0))
            }

            it("sets delay to value of param received") {
                let poller = ConfigPoller(delay: 10.0)

                expect(poller.delay).to(equal(10.0))
            }

            it("creates a timer") {
                let poller = ConfigPoller()

                expect(poller.timer).to(beAKindOf(Timer.self))
            }
        }
    }
}
