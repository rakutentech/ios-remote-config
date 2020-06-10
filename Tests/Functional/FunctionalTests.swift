import Quick
import Nimble
@testable import RRemoteConfig

class FunctionalSpec: QuickSpec {
    override func spec() {
        describe("start function") {
            class MockRunLoop: PollerRunLoopProtocol {
                var addedTimer: Timer?

                func addTimer(_ timer: Timer) {
                    self.addedTimer = timer
                }
            }

            it("asynchronously executes the action after the specified delay") {
                var actionCalled = 0
                let poller = Poller(delay: PollerConstants.minimumDelay)

                poller.start {
                    actionCalled += 1
                }

                expect(actionCalled).toEventually(beGreaterThan(1), timeout: PollerConstants.minimumDelay + 10)
            }
        }
    }
}
