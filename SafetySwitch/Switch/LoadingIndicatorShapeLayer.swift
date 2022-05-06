//
// created 11.11.20
// lumibit.io

import UIKit

class LoadingIndicatorShapeLayer: CAShapeLayer {

    override init(layer: Any) {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        super.init(layer: layer)
    }

    override init() {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        super.init()

        self.fillColor = UIColor.clear.cgColor
        self.lineCap = .round
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, loadingIndicatorThickness: CGFloat, strokeColor: UIColor) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.strokeColor = strokeColor.cgColor
        self.lineWidth = loadingIndicatorThickness

        let loadingPathBox = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )

        let intermediatePath = UIBezierPath(ovalIn: loadingPathBox)

        intermediatePath.rotateAroundCenter(angleRad: deg2rad(angle: startAngle))

        self.path = intermediatePath.cgPath
    }

    private func deg2rad(angle: CGFloat) -> CGFloat {
        return (angle + 270) / 360 * 2 * .pi
    }

    private var x: CGFloat
    private var y: CGFloat
    private var width: CGFloat
    private var height: CGFloat

    var startAngle: CGFloat = 0
}

extension UIBezierPath {
    /**
     Rotate the whole Layer by a radian angle.
     */
    func rotateAroundCenter(angleRad: CGFloat) {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: angleRad)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        self.apply(transform)
    }
}
