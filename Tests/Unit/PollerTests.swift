import Quick
import Nimble
@testable import RRemoteConfig

class PollerSpec: QuickSpec {
    override func spec() {
        describe("init function") {
            it("sets default delay of 1 hour when no delay param received") {
                let poller = Poller()

                expect(poller.delay).to(equal(3600.0))
            }

            it("sets delay to value of param received") {
                let poller = Poller(delay: 10.0)

                expect(poller.delay).to(equal(10.0))
            }

            it("does not create a timer") {
                let poller = Poller()

                expect(poller.timer).to(beNil())
            }
        }
        describe("start function") {
            it("synchronously executes action closure exactly once") {
                var actionCalled = 0
                let poller = Poller()

                poller.start {
                    actionCalled += 1
                }

                expect(actionCalled).to(equal(1))
            }

            it("creates a valid polling timer") {
                let poller = Poller()

                poller.start {
                }

                expect(poller.timer?.isValid).to(equal(true))
            }

            it("creates a timer with expected delay") {
                let poller = Poller(delay: 2.0)

                poller.start { }

                expect(poller.timer?.timeInterval).to(equal(2.0))
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
        describe("stop function") {
            it("asynchronously invalidates the active timer") {
                let poller = Poller()
                poller.start { }

                poller.stop()

                expect(poller.timer?.isValid).toEventually(equal(false))
            }

            it("can be called before start() is called when timer is nil") {
                let poller = Poller()

                poller.stop()

                expect(poller.timer).to(beNil())
            }
        }
    }
}
