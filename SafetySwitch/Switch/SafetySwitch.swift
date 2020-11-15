//
// created 11.11.20
// rapid.io

import UIKit

/**
 A Switch, that needs a long press to be toggled. Progress feedback of the waiting durations is available.
 
 For safety critical purposes and situations where it needs to be ensured that no accidential touches triggers a switch.
 When the switch area is left by dragging or while touching, the toggle action is aborted.
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
    
    private var animationType: AnimationType = .loading
    private let hapticFeedback: SafetySwitchHapticFeedbackGenerator = SafetySwitchHapticFeedbackGenerator()
    
    // MARK: - Layers
    private var outerDonutLayer: DonutShapeLayer = DonutShapeLayer()
    private var loadingIndicatorShapeLayer: LoadingIndicatorShapeLayer = LoadingIndicatorShapeLayer()
    private var loadingIndicatorDonutLayer: DonutShapeLayer = DonutShapeLayer()
    private var innerCircleLayer: CircleShapeLayer = CircleShapeLayer()
    
    // MARK: - Handle Darkmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let outerColorSwitched = self.outerColor
        self.outerColor = outerColorSwitched
        
        let innerColorSwitched = self.innerColor
        self.innerColor = innerColorSwitched
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !fullBackground {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = self.bounds.width / 2
        }
        
        self.outerDonutLayer.layout(x: 0,
                                    y: 0,
                                    outerDiameter: self.bounds.width,
                                    thickness: outerWidth,
                                    fillColor: outerColor
        )
        self.layer.addSublayer(outerDonutLayer)
        
        // Layout Indication Layer, adding will be done by animation
        self.loadingIndicatorShapeLayer.layout(x: outerWidth + 0.5 * indicatorWidth,
                                               y: outerWidth + 0.5 * indicatorWidth,
                                               width: self.bounds.width - 2 * outerWidth - indicatorWidth,
                                               height: self.bounds.width - 2 * outerWidth - indicatorWidth,
                                               loadingIndicatorThickness: indicatorWidth,
                                               strokeColor: indicatorColor)
        
        self.loadingIndicatorDonutLayer.layout(x: outerWidth,
                                               y: outerWidth,
                                               outerDiameter: self.bounds.width - 2 * outerWidth,
                                               thickness: indicatorWidth,
                                               fillColor: stateColor
        )
        self.layer.addSublayer(loadingIndicatorDonutLayer)
        
        self.innerCircleLayer.layout(x: outerWidth + indicatorWidth,
                                     y: outerWidth + indicatorWidth,
                                     diameter: self.bounds.width - 2 * indicatorWidth - 2 * outerWidth,
                                     fillColor: innerColor)
        self.layer.addSublayer(innerCircleLayer)
    }

    // MARK: - Animation
    func animateStroke() {
        
        let loadingAnimation = LoadingAnimation(
            direction: animationType, duration: switchTime
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
     Starts the toggling transition. State is untouched. Animations start.
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
     Cancels the toggling transition. Fall back to last save state.
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
     Completes the toggling transitioning. The switch is toggled here.
     
     Override here to enable custom actions.
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
    
    /**
     Shows the transition process as deloading. Default is false.
     
     Animation will show as Loading by default.
     */
    @IBInspectable var isDeloading: Bool = false {
        didSet {
            if isDeloading {
                animationType = .deloading
            } else {
                animationType = .loading
            }
        }
    }
    
    /**
     The Angle in degree where the loading indication should start. Default is 0.
     */
    @IBInspectable var startAngle: CGFloat = 0 {
        didSet {
            loadingIndicatorShapeLayer.startAngle = startAngle
        }
    }
    
    /**
     The time [sec] it takes for the switch to toggle. This is also the animation time. Default is 1.
     */
    @IBInspectable var switchTime: Double = 1 {
        didSet {
            switchTime = abs(switchTime)
            self.gestureRecognizer?.minimumPressDuration = switchTime
        }
    }
    
    /**
     The thickness of the outer ring circle. Default is 2.5% of views width.
     */
    @IBInspectable lazy var outerWidth: CGFloat = 0.025 * self.bounds.width {
        didSet {
            outerDonutLayer.thickness = outerWidth
        }
    }
    
    /**
     The color of the outer ring circle. Default is system label color.
     */
    @IBInspectable var outerColor: UIColor = .label {
        didSet {
            outerDonutLayer.fillColor = outerColor.cgColor
        }
    }
    
    /**
     The color of the inner circle. Default is system label color.
     */
    @IBInspectable var innerColor: UIColor = .label {
        didSet {
            innerCircleLayer.fillColor = innerColor.cgColor
        }
    }
    
    /**
     Determines whether or not the views rectangular background should be enabled. Default is false.
     */
    @IBInspectable var fullBackground: Bool = false {
        didSet {
            if fullBackground {
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 0
            } else {
                self.layer.masksToBounds = true
                self.layer.cornerRadius = self.bounds.width / 2
            }
        }
    }
    
    /**
     The color of the loading indicator. By default, the color switches and corellates to the state of the button.
     */
    lazy var indicatorColor: UIColor = self.isOn ? self.isOffColor : self.isOnColor {
        didSet {
            loadingIndicatorShapeLayer.strokeColor = indicatorColor.cgColor
        }
    }
    
    /**
     The color of the button state. By default, the color switches and corellates to the loading indicator.
     */
    lazy var stateColor: UIColor = self.isOn ? self.isOnColor : self.isOffColor {
        didSet {
            loadingIndicatorDonutLayer.fillColor = stateColor.cgColor
        }
    }

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
