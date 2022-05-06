//
// created 11.11.20
// lumibit.io

import UIKit

class LoadingAnimation: CABasicAnimation {

    override init() {
        super.init()
    }

    init(direction: AnimationType, duration: Double) {

        super.init()

        self.keyPath = direction == .deloading ? "strokeStart" : "strokeEnd"

        self.beginTime = 0
        self.fromValue = 0
        self.toValue = 1
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

enum AnimationType {
    case loading
    case deloading
}
