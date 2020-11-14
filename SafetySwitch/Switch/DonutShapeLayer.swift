//
// created 11.11.20
// rapid.io

import UIKit

class DonutShapeLayer: CAShapeLayer {

    override init(layer: Any) {
        self.x = 0
        self.y = 0
        self.outerDiameter = 0
        self.thickness = 0
        super.init(layer: layer)
    }

    init(x: CGFloat, y: CGFloat, outerDiameter: CGFloat, thickness: CGFloat, fillColor: UIColor) {
        self.x = x
        self.y = y
        self.outerDiameter = outerDiameter
        self.thickness = thickness

        super.init()
        self.fillColor = fillColor.cgColor

    }

    override convenience init() {
        self.init(x: 0, y: 0, outerDiameter: 0, thickness: 0, fillColor: .black)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout() {

        let outerDonutRect = CGRect(
            x: x,
            y: y,
            width: outerDiameter,
            height: outerDiameter)

        let outerDonutCirclePath = UIBezierPath(roundedRect: outerDonutRect, cornerRadius: 0.5 * outerDiameter)

        let innerDonutRect = CGRect(
            x: outerDonutRect.minX + thickness,
            y: outerDonutRect.minY + thickness,
            width: outerDiameter - 2 * thickness,
            height: outerDiameter - 2 * thickness
        )

        let innerDonutDiameter = innerDonutRect.width
        let innerDonutCirclePath = UIBezierPath(roundedRect: innerDonutRect, cornerRadius: innerDonutDiameter)

        outerDonutCirclePath.append(innerDonutCirclePath)
        let mask = CAShapeLayer()
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        mask.path = outerDonutCirclePath.cgPath

        self.path = outerDonutCirclePath.cgPath
        self.position = CGPoint(x: 0, y: 0)
        self.mask = mask
    }

    // MARK: - Properties
    private var x: CGFloat
    private var y: CGFloat
    private var outerDiameter: CGFloat

    var thickness: CGFloat
}
