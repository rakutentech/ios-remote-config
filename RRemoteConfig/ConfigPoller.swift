internal class ConfigPoller {
    let delay: TimeInterval
    var timer: Timer

    init(delay: TimeInterval = 60.0 * 60.0) {
        self.delay = delay

        // initialize with dummy timer
        self.timer = Timer(timeInterval: 1.0, repeats: false, block: { (_) in
        })
    }

    func start(action: @escaping () -> Void) {
        // initial fetch
        action()

        // polling
        self.timer = Timer(timeInterval: self.delay, repeats: true, block: { (_) in
            action()
        })
        self.timer.tolerance = 0.1 * self.delay

        DispatchQueue.main.async {
            RunLoop.current.add(self.timer, forMode: .common)
        }
    }

    func stop() {
        if self.timer.isValid {
            DispatchQueue.main.async {
                self.timer.invalidate()
            }
        }
    }
}
