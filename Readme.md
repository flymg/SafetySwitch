# SWIFT SAFETY SWITCH

A Swift 5 stateful switch which requires a long press to toggle. A loading indicator will display progress in the button.

<hr />
<p align="center">
    <a href="#EXAMPE">Example</a> • 
    <a href="#SETUP">Setup</a> •
    <a href="#INTERFACE-BUILDER">Interface Builder</a>
</p>
<hr />

## EXAMPLE
![Example Implementation](SafetySwitch.gif?raw=true)

## SETUP  

1. Checkout Repo and add `SafetySwitch/Switch` folder to your project.  
Add the repo as a submodule for future updates.

2. Drag an `UIView` to your Storyboard and link with `SafetySwitch`.

3. Implement or subclass `SafetySwitch`.  
When subclassing, 3 methods can be implemented.
At least `completeTransition` is mandatory for customizing toggling functionality.

```swift
override func startTransition() {
    isAnimating = true

    // your code here
}

override func abortTransition() {
    isAnimating = false

    // your abortion code here
}

override func completeTransition() {
    isAnimating = false
    isOn.toggle()
 
    // your toggle Code here
}
```

## INTERFACE-BUILDER
The Switch can be customized in Storyboard Mode / Interface Builder.  
By default, layouting will be done by `width` of the view. A **1:1** `aspect ration` constraint with fixed `height` will give the best experience.

![Example Config](example_config.png?raw=true)
