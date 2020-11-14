//
// created 06.09.20
// rapid.io

import UIKit

class SafetySwitchHapticFeedbackGenerator {
    
    func soft() {
        self.sendHapticFeedback(style: .soft)
    }
    
    func light() {
        self.sendHapticFeedback(style: .light)
    }
    
    func medium() {
        self.sendHapticFeedback(style: .medium)
    }
    
    func heavy() {
        self.sendHapticFeedback(style: .heavy)
    }
    
    private func sendHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()

    }
    
}
