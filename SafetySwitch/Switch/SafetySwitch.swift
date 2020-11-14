//
// created 11.11.20
// rapid.io

import UIKit

/**
 A Switch, that needs a long press to be acitvated. Progress feedback of the waiting durations is provided.
 
 For safety critical purposes and situations where it needs to be ensured that no accidential touches triggers the switch.
 When the switch area is left while touching, the loading action is aborted.
 */
@IBDesignable
class SafetySwitch: UIControl {
    
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
    
    private var indicationType: IndicationType = .loading
    private let hapticFeedback: SafetySwitchHapticFeedbackGenerator = SafetySwitchHapticFeedbackGenerator()
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width / 2
        
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
            direction: indicationType, duration: switchTime
        )
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = switchTime
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [loadingAnimation]
        
        loadingIndicatorShapeLayer.add(strokeAnimationGroup, forKey: nil)
        self.layer.addSublayer(loadingIndicatorShapeLayer)
    }
    
    // MARK: - Gestures / Haptics
    private lazy var gestureRecognizer: UILongPressGestureRecognizer? = nil
    
    private func addGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressCompleted(gesture:)))
        longPress.minimumPressDuration = switchTime
        longPress.allowableMovement = self.bounds.width
        self.gestureRecognizer = longPress
        self.addGestureRecognizer(longPress)
    }
    
    @objc
    private func longPressCompleted(gesture: UILongPressGestureRecognizer) {
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
    /**
     Starts the transitioning animation. State is untouched.
     */
    func startTransition() {
        if isEnabled {
            if isOn {
                indicatorColor = isOffColor
                stateColor = .clear
                isAnimating = true
            } else {
                indicatorColor = isOnColor
                stateColor = .clear
                isAnimating = true
            }
        }
    }
    
    /**
     Cancels the transitioning animation. Fall back to last save state.
     */
    func abortTransition() {
        if isOn {
            stateColor = isOnColor
        } else {
            stateColor = isOffColor
        }
        isAnimating = false
    }
    
    /**
     Completes the transitioning animation. The switch is toggled now.
     */
    func completeTransition() {
        if isOn {
            stateColor = isOffColor
        } else {
            stateColor = isOnColor
        }
        isOn.toggle()
        isAnimating = false
    }
    
    // MARK: - Properties
    /**
     Determines the state of the switch. Default is On.
     */
    @IBInspectable var isOn: Bool = true
    @IBInspectable var isOnColor: UIColor = UIColor.systemGreen
    @IBInspectable var isOffColor: UIColor = UIColor.systemRed
    
    @IBInspectable lazy var indicatorWidth: CGFloat = 0.09 * self.bounds.width {
        didSet {
            loadingIndicatorShapeLayer.lineWidth = indicatorWidth
        }
    }
    
    @IBInspectable var isDeloading: Bool = false {
        didSet {
            if isDeloading {
                indicationType = .deloading
            } else {
                indicationType = .loading
            }
        }
    }
    
    @IBInspectable var startAngle: CGFloat = 0 {
        didSet {
            loadingIndicatorShapeLayer.startAngle = startAngle
        }
    }
    
    @IBInspectable var switchTime: Double = 1 {
        didSet {
            let temp = switchTime
            switchTime = temp
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
    // MARK: - Switch Colors
    lazy var indicatorColor: UIColor = self.isOn ? self.isOffColor : self.isOnColor {
        didSet {
            loadingIndicatorShapeLayer.strokeColor = indicatorColor.cgColor
        }
    }
    
    lazy var stateColor: UIColor = self.isOn ? self.isOnColor : self.isOffColor {
         didSet {
             loadingIndicatorDonutLayer.fillColor = stateColor.cgColor
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
