//
// created 11.11.20
// rapid.io

import UIKit

@IBDesignable
class LoadingIndicatorSwitch: UIControl {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        addGestures()
    }
    
    override func prepareForInterfaceBuilder() {
        self.isAnimating = true
        self.layoutIfNeeded()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.outerDonutLayer.layout()
        self.layer.addSublayer(outerDonutLayer)
        
        // Layout Indication Layer, adding will be done by animation
        self.loadingIndicatorShapeLayer.layout()
        
        self.loadingIndicatorDonutLayer.layout()
        self.layer.addSublayer(loadingIndicatorDonutLayer)
        
        self.innerCircleLayer.layout()
        self.layer.addSublayer(innerCircleLayer)
    }
    
    // MARK: - Handle Darkmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let outerColorSwitched = self.outerColor
        self.outerColor = outerColorSwitched
        
        let innerColorSwitched = self.innerColor
        self.innerColor = innerColorSwitched
    }
    
    // MARK: - Animation
    func animateStroke() {
        
        let loadingAnimation = LoadingAnimation(
            direction: loadingDirection, duration: loadingDuration
        )
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = loadingDuration
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [loadingAnimation]
        
        loadingIndicatorShapeLayer.add(strokeAnimationGroup, forKey: nil)
        self.layer.addSublayer(loadingIndicatorShapeLayer)
    }
    
    // MARK: - Gestures / Haptics
    private lazy var gestureRecognizer: UILongPressGestureRecognizer? = nil
    
    func addGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = loadingDuration
        longPress.allowableMovement = self.bounds.width
        self.gestureRecognizer = longPress
        self.addGestureRecognizer(longPress)
    }
    
    @objc
    func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            completeTransition()
            hapticFeedback.medium()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            startTransition()
            hapticFeedback.soft()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchPosition = touches.first?.location(in: self) else { return }
        
        if !self.bounds.contains(touchPosition) {
            // the touch was outside button boundaries
            abortTransition()
            self.gestureRecognizer?.isEnabled = false
            self.gestureRecognizer?.isEnabled = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        abortTransition()
    }
    
    // MARK: - Transitions
    enum SwitchState {
        case on
        case off
    }
    
    private var switchState: SwitchState = .off
    private var loadingDirection: LoadingType = .loading
    private let hapticFeedback: LoadingIndicatorHapticFeedbackGenerator = LoadingIndicatorHapticFeedbackGenerator()
    
    /**
     Updates the View and animate the transitioning process.
     */
    func startTransition() {
        switch switchState {
        case .on:
            indicatorColor = .systemRed
            stateColor = .clear
            isAnimating = true
        case .off:
            indicatorColor = .systemGreen
            stateColor = .clear
            isAnimating = true
        }
    }
    
    /**
     Cancels the transitioning animation.
     */
    func abortTransition() {
        switch switchState {
        case .on:
            stateColor = .systemGreen
        case .off:
            stateColor = .systemRed
        }
        isAnimating = false
    }
    
    /**
     Completes the transitioning animation.
     */
    func completeTransition() {
        switch switchState {
        case .on:
            switchState = .off
            stateColor = .systemRed
        case .off:
            switchState = .on
            stateColor = .systemGreen
        }
        isAnimating = false
    }
    
    // MARK: - Properties
    @IBInspectable lazy var indicatorWidth: CGFloat = 0.09 * self.bounds.width {
        didSet {
            loadingIndicatorShapeLayer.lineWidth = indicatorWidth
        }
    }
    
    @IBInspectable var deloadingAnimation: Bool = false {
        didSet {
            if deloadingAnimation {
                loadingDirection = .deloading
            } else {
                loadingDirection = .loading
            }
        }
    }
    
    @IBInspectable var indicatorColor: UIColor = UIColor.systemGreen {
        didSet {
            loadingIndicatorShapeLayer.strokeColor = indicatorColor.cgColor
        }
    }
    
    @IBInspectable var startAngle: CGFloat = 0 {
        didSet {
            loadingIndicatorShapeLayer.startAngle = startAngle
        }
    }
    
    @IBInspectable var stateColor: UIColor = UIColor.clear {
        didSet {
            loadingIndicatorDonutLayer.fillColor = stateColor.cgColor
        }
    }
    
    @IBInspectable var loadingDuration: Double = 1 {
        didSet {
            let temp = loadingDuration
            loadingDuration = temp
        }
    }
    
    @IBInspectable lazy var outerWidth: CGFloat = 0.025 * self.bounds.width {
        didSet {
            outerDonutLayer.thickness = outerWidth
        }
    }
    
    @IBInspectable var outerColor: UIColor = .label {
        didSet {
            outerDonutLayer.fillColor = outerColor.cgColor
        }
    }
    
    @IBInspectable var innerColor: UIColor = .label {
        didSet {
            innerCircleLayer.fillColor = innerColor.cgColor
        }
    }
    
    // MARK: - Layers
    private lazy var outerDonutLayer: DonutShapeLayer = {
        return DonutShapeLayer(x: 0,
                               y: 0,
                               outerDiameter: self.bounds.width,
                               thickness: outerWidth,
                               fillColor: outerColor
        )
    }()
    
    private lazy var loadingIndicatorShapeLayer: LoadingIndicatorShapeLayer = {
        return LoadingIndicatorShapeLayer(x: outerWidth + 0.5 * indicatorWidth,
                                          y: outerWidth + 0.5 * indicatorWidth,
                                          width: self.bounds.width - 2 * outerWidth - indicatorWidth,
                                          height: self.bounds.width - 2 * outerWidth - indicatorWidth,
                                          loadingIndicatorThickness: indicatorWidth,
                                          strokeColor: indicatorColor,
                                          startAngle: startAngle)
    }()
    
    private lazy var loadingIndicatorDonutLayer: DonutShapeLayer = {
        return DonutShapeLayer(x: outerWidth,
                               y: outerWidth,
                               outerDiameter: self.bounds.width - 2 * outerWidth,
                               thickness: indicatorWidth,
                               fillColor: stateColor
        )
    }()
    
    private lazy var innerCircleLayer: CircleShapeLayer = {
        return CircleShapeLayer(x: outerWidth + indicatorWidth,
                                y: outerWidth + indicatorWidth,
                                diameter: self.bounds.width - 2 * indicatorWidth - 2 * outerWidth,
                                fillColor: innerColor
        )
    }()
    
    var isAnimating: Bool = false {
        didSet {
            if isAnimating {
                self.animateStroke()
            } else {
                self.loadingIndicatorShapeLayer.removeFromSuperlayer()
                self.layer.removeAllAnimations()
            }
        }
    }
}
