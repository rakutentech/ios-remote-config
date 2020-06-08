protocol PollerRunLoopProtocol {
    func addTimer(_ timer: Timer)
}

extension RunLoop: PollerRunLoopProtocol {
    func addTimer(_ timer: Timer) {
        add(timer, forMode: .common)
    }
}

internal enum PollerConstants {
    static let defaultDelay: TimeInterval = 60.0 * 60.0
    static let minimumDelay: TimeInterval = 60.0
}

internal class Poller {
    private let delay: TimeInterval
    private var runLoop: PollerRunLoopProtocol?
    private var timer: Timer?

    init(delay: TimeInterval = PollerConstants.defaultDelay, runLoop: PollerRunLoopProtocol = RunLoop.current) {
        self.delay = delay < PollerConstants.minimumDelay ? PollerConstants.minimumDelay : delay
        self.runLoop = runLoop
    }

    func start(action: @escaping () -> Void) {
        // initial fetch
        action()

        self.timer = Timer(timeInterval: self.delay, repeats: true, block: { (_) in
            action()
        })

        // polling
        if let timer = self.timer {
            timer.tolerance = 0.1 * self.delay
            DispatchQueue.main.async {
                // note: timer must be invalidated on the
                // same thread it was added to the run loop
                self.runLoop?.addTimer(timer)
            }
        }
    }
}
