//
// created 11.11.20
// rapid.io

import UIKit

class CircleShapeLayer: CAShapeLayer {

    override init(layer: Any) {
        self.x = 0
        self.y = 0
        self.diameter = 0
        super.init(layer: layer)
    }

    init(x: CGFloat, y: CGFloat, diameter: CGFloat, fillColor: UIColor) {
        self.x = x
        self.y = y
        self.diameter = diameter

        super.init()

        self.layout()
        self.fillColor = fillColor.cgColor
    }

    func layout() {
        let circleRect = CGRect(
            x: x,
            y: y,
            width: diameter,
            height: diameter)

        let circlePath = UIBezierPath(roundedRect: circleRect, cornerRadius: 0.5 * diameter)
        self.path = circlePath.cgPath
        self.position = CGPoint(x: 0, y: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Properties
    private var x: CGFloat
    private var y: CGFloat
    var diameter: CGFloat
}
