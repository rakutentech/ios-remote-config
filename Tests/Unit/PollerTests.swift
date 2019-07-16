import Quick
import Nimble
@testable import RRemoteConfig

class PollerSpec: QuickSpec {
    override func spec() {
        describe("start function") {
            class MockRunLoop: PollerRunLoopProtocol {
                var addedTimer: Timer?

                func addTimer(_ timer: Timer) {
                    self.addedTimer = timer
                }
            }
            it("creates a timer with time interval equal to default delay of 1 hour") {
                let runLoop: MockRunLoop = MockRunLoop()
                let poller = Poller(runLoop: runLoop)

                poller.start { }

                expect(runLoop.addedTimer?.timeInterval).toEventually(equal(3600.0))
            }

            it("creates a timer with time interval equal to delay param") {
                let runLoop: MockRunLoop = MockRunLoop()
                let poller = Poller(delay: 10.5, runLoop: runLoop)

                poller.start { }

                expect(runLoop.addedTimer?.timeInterval).toEventually(equal(10.5))
            }

            it("synchronously executes action closure exactly once") {
                var actionCalled = 0
                let poller = Poller()

                poller.start {
                    actionCalled += 1
                }

                expect(actionCalled).to(equal(1))
            }

            it("asynchronously executes the action after the specified delay") {
                var actionCalled = 0
                let poller = Poller(delay: 0.5)

                poller.start {
                    actionCalled += 1
                }

                expect(actionCalled).toEventually(beGreaterThan(2), timeout: 2)
            }
        }
    }
}
