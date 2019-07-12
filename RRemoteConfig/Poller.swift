internal class Poller {
    let delay: TimeInterval
    var timer: Timer?

    init(delay: TimeInterval = 60.0 * 60.0) {
        self.delay = delay
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
                RunLoop.current.add(timer, forMode: .common)
            }
        }
    }

    func stop() {
        guard let timer = self.timer else {
            return
        }
        if timer.isValid {
            // timer must be invalidated on the same thread
            // it was added to the run loop
            DispatchQueue.main.async {
                timer.invalidate()
            }
        }
    }
}
