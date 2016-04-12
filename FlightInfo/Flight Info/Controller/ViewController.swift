/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import QuartzCore

//
// Util delay function
//
func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

class ViewController: UIViewController {
    
    //	MARK: Animation Direction Enum
    
    private enum AnimationDirection: Int {
        case Positive = 1
        case Negative = -1
    }
    
    //	MARK: Properties - Subviews
    
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var summaryIcon: UIImageView!
    @IBOutlet var summary: UILabel!
    
    @IBOutlet var flightNr: UILabel!
    @IBOutlet var gateNr: UILabel!
    @IBOutlet var departingFrom: UILabel!
    @IBOutlet var arrivingTo: UILabel!
    @IBOutlet var planeImage: UIImageView!
    
    @IBOutlet var flightStatus: UILabel!
    @IBOutlet var statusBanner: UIImageView!
    
    var snowView: SnowView!
    
    //MARK: view controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adjust ui
        summary.addSubview(summaryIcon)
        summaryIcon.center.y = summary.frame.size.height/2
        
        //add the snow effect layer
        snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
        let snowClipView = UIView(frame: CGRectOffset(view.frame, 0, 50))
        snowClipView.clipsToBounds = true
        snowClipView.addSubview(snowView)
        view.addSubview(snowClipView)
        
        //start rotating the flights
        changeFlightDataTo(londonToParis)
    }
    
    //MARK: custom methods
    
    func changeFlightDataTo(data: FlightData, animated: Bool = false) {
        
        // populate the UI with the next flight's data
        summary.text = data.summary
        flightStatus.text = data.flightStatus
        
        if animated {
            fadeImageView(bgImageView, toImage: UIImage(named: data.weatherImageName)!, showEffects: data.showWeatherEffects)
            let direction: AnimationDirection = data.isTakingOff ? .Positive : .Negative
            
            cubeTransition(label: flightNr, toText: data.flightNr, inDirection: direction)
            cubeTransition(label: gateNr, toText: data.gateNr, inDirection: direction)
            
            let offsetDeparting = CGPoint(x: CGFloat(direction.rawValue) * 80.0, y: 0.0)
            let offsetArriving = CGPoint(x: 0.0, y: CGFloat(direction.rawValue) * 50.0)
            
            moveLabel(departingFrom, toText: data.departingFrom, withOffset: offsetDeparting)
            moveLabel(arrivingTo, toText: data.arrivingTo, withOffset: offsetArriving)
            
        } else {
            bgImageView.image = UIImage(named: data.weatherImageName)
            snowView.hidden = !data.showWeatherEffects
            
            flightNr.text = data.flightNr
            gateNr.text = data.gateNr
            
            departingFrom.text = data.departingFrom
            arrivingTo.text = data.arrivingTo
        }
        
        // schedule next flight
        delay(seconds: 3.0) {
            self.changeFlightDataTo(data.isTakingOff ? parisToRome : londonToParis, animated: true)
        }
    }
    
    private func cubeTransition(label label: UILabel, toText text: String, inDirection direction: AnimationDirection) {
        //  create a label which we will transition to with the new text
        let auxillaryLabel = label.auxillaryLabel
        auxillaryLabel.text = text
        
        //  squish the label to make it look like it is on the edge of a cube and move it to the bottom or top depending on the animation direction
        let auxillaryLabelOffset = CGFloat(direction.rawValue) * label.frame.height / 2.0
        let squishTransform = CGAffineTransformMakeScale(1.0, 0.1)
        let translationTransform = CGAffineTransformMakeTranslation(0.0, auxillaryLabelOffset)
        auxillaryLabel.transform = CGAffineTransformConcat(squishTransform, translationTransform)
        label.superview!.addSubview(auxillaryLabel)
        
        //  now do the cube animation
        UIView.animateWithDuration(0.5, animations: {
            //  un-squish the auxillary label whilst we swuish the old label to make it look like a cube is rotating
            auxillaryLabel.transform = CGAffineTransformIdentity
            let translationTransform = CGAffineTransformMakeTranslation(0.0, -auxillaryLabelOffset)
            label.transform = CGAffineTransformConcat(squishTransform, translationTransform)
            }, completion: { _ in
                //  now we can remove the auxillary label and just replace the text of the old label and unsquish it
                label.text = auxillaryLabel.text
                label.transform = CGAffineTransformIdentity
                auxillaryLabel.removeFromSuperview()
        })
    }
 
    private func fadeImageView(imageView: UIImageView, toImage image: UIImage, showEffects: Bool) {
        UIView.transitionWithView(imageView, duration: 1.0, options: .TransitionCrossDissolve, animations: { 
            imageView.image = image
            }, completion: nil)
        
        UIView.animateWithDuration(1.0) {
            self.snowView.alpha = showEffects ? 1.0 : 0.0
        }
    }
 
    private func moveLabel(label: UILabel, toText text: String, withOffset offset: CGPoint) {
        let auxillaryLabel = label.auxillaryLabel
        auxillaryLabel.text = text
        auxillaryLabel.backgroundColor = .clearColor()
        auxillaryLabel.transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
        auxillaryLabel.alpha = 0.0
        view.addSubview(auxillaryLabel)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseIn, animations: { 
            label.transform = CGAffineTransformMakeTranslation(offset.x, offset.y)
            label.alpha = 0.0
            }, completion: nil)
        UIView.animateWithDuration(0.25, delay: 0.1, options: .CurveEaseIn, animations: {
            auxillaryLabel.transform = CGAffineTransformIdentity
            auxillaryLabel.alpha = 1.0
            }, completion: { _ in
                auxillaryLabel.removeFromSuperview()
                
                label.text = text
                label.alpha = 1.0
                label.transform = CGAffineTransformIdentity
        })
        
    }
}

extension UILabel {
    var auxillaryLabel: UILabel {
        let auxillaryLabel = UILabel(frame: frame)
        auxillaryLabel.text = text
        auxillaryLabel.font = font
        auxillaryLabel.textAlignment = textAlignment
        auxillaryLabel.textColor = textColor
        auxillaryLabel.backgroundColor = backgroundColor
        
        return auxillaryLabel
    }
}