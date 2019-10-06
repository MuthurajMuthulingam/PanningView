//
//  PanningView.swift
//  PanningView
//
//  Created by Muthuraj Muthulingam on 02/01/18.
//  Copyright © 2018 Muthuraj. All rights reserved.
//

import UIKit

public enum MMDirection {
    case left
    case top
    case right
    case bottom
    case none
}

public struct MMMovement {
    var vertical: CGFloat
    var horizontal: CGFloat
}

public struct MMPan {
    var direction:Direction
    var movement:Movement
    var distance:CGFloat
}

public typealias PanCompletion = ((_ panView:PanningView)->Void)
public typealias PanProgressCompletion = ((_ panView:PanningView, _ pan:Pan)->Void)

@IBDesignable
public class MMPanningView: UIView {

    @IBInspectable private var panningEnabled:Bool
    
    // MARK: - Notifiers
    public var panStarted:PanCompletion?
    public var panEnded:PanCompletion?
    public var panProgress:PanProgressCompletion?
    
    //MARK: - Initializer
   public init(WithPanningEnabled enabled:Bool) {
        self.panningEnabled = enabled
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.panningEnabled = false
        super.init(coder: aDecoder)
    }
    
    // MARK: - Touch Handling
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if panningEnabled {
            panStarted?(self)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if panningEnabled {
            guard let location = touches.first?.location(in: self),
                  let previousLocation = touches.first?.previousLocation(in: self) else { return }
            let movement = Movement(vertical: location.verticalMovement(fromPoint: previousLocation), horizontal: location.horizontalMovement(fromPoint: previousLocation))
            let pan = Pan(direction: location.direction(FromLastPoint: previousLocation), movement: movement, distance: location.distance(To: previousLocation))
            panProgress?(self,pan)
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if panningEnabled  {
            panEnded?(self)
        }
    }
}

// MARK: - CGPoint Helpers
extension CGPoint {
    public func distance(To point:CGPoint) -> CGFloat {
        let xDist = point.x - self.x
        let yDist = point.y - self.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    public func direction(FromLastPoint previousPoint:CGPoint) -> Direction {
        var direction:Direction = .none
        if previousPoint.x < self.x { // towards right
            direction = .right
        } else if previousPoint.y > self.y { // towards bottom
            direction = .bottom
        } else if previousPoint.y < self.y { // towards top
            direction = .top
        } else if previousPoint.x > self.x {
            direction = .left
        }
        return direction
    }
    
    public func horizontalMovement(fromPoint previousLocation:CGPoint) -> CGFloat {
        return abs(self.x - previousLocation.x)
    }
    
    public func verticalMovement(fromPoint previousLocation:CGPoint) -> CGFloat {
        return abs(self.y - previousLocation.y)
    }
}

