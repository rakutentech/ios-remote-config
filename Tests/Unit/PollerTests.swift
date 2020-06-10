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
            it("creates a timer with time interval equal to default delay when no explicit delay param is passed into initializer") {
                let runLoop: MockRunLoop = MockRunLoop()
                let poller = Poller(runLoop: runLoop)

                poller.start { }

                expect(runLoop.addedTimer?.timeInterval).toEventually(equal(PollerConstants.defaultDelay))
            }

            it("creates a timer with time interval equal to passed in delay param when param value is greater than minimum delay") {
                let runLoop: MockRunLoop = MockRunLoop()
                let poller = Poller(delay: 100.5, runLoop: runLoop)

                poller.start { }

                expect(runLoop.addedTimer?.timeInterval).toEventually(equal(100.5))
            }

            it("creates a timer with time interval equal to minimum delay if passed in delay param is zero") {
                let runLoop: MockRunLoop = MockRunLoop()
                let poller = Poller(delay: 0, runLoop: runLoop)

                poller.start { }

                expect(runLoop.addedTimer?.timeInterval).toEventually(equal(PollerConstants.minimumDelay))
            }

            it("creates a timer with time interval equal to minimum delay if passed in delay param is less than minimum delay") {
                let runLoop: MockRunLoop = MockRunLoop()
                let poller = Poller(delay: 10, runLoop: runLoop)

                poller.start { }

                expect(runLoop.addedTimer?.timeInterval).toEventually(equal(PollerConstants.minimumDelay))
            }

            it("synchronously executes action closure exactly once") {
                var actionCalled = 0
                let poller = Poller()

                poller.start {
                    actionCalled += 1
                }

                expect(actionCalled).to(equal(1))
            }
        }
    }
}
