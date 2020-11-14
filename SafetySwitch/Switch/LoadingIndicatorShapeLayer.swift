//
// created 11.11.20
// rapid.io

import UIKit

class LoadingIndicatorShapeLayer: CAShapeLayer {

    override init(layer: Any) {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        super.init(layer: layer)
    }

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, loadingIndicatorThickness: CGFloat, strokeColor: UIColor, startAngle: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height

        super.init()

        self.strokeColor = strokeColor.cgColor
        self.lineWidth = loadingIndicatorThickness
        self.fillColor = UIColor.clear.cgColor
        self.lineCap = .round

        self.startAngle = deg2rad(angle: startAngle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout() {

        let loadingPathBox = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )

        let intermediatePath = UIBezierPath(ovalIn: loadingPathBox)

        intermediatePath.rotateAroundCenter(angleRad: startAngle)

        self.path = intermediatePath.cgPath
    }

    private func deg2rad(angle: CGFloat) -> CGFloat {
        return (angle + 270) / 360 * 2 * .pi
    }

    // MARK: - Properties
    private var x: CGFloat
    private var y: CGFloat
    private var width: CGFloat
    private var height: CGFloat

    lazy var startAngle: CGFloat = deg2rad(angle: 0)
}

extension UIBezierPath {
    func rotateAroundCenter(angleRad: CGFloat) {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: angleRad)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        self.apply(transform)
    }
}
