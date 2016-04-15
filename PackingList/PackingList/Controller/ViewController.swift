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

class ViewController: UIViewController {
    
    //	MARK: Properties - Views
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonMenu: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    private var slider: HorizontalItemList!
    @IBOutlet private weak var menuHeightConstraint: NSLayoutConstraint!
    
    //	MARK: Properties - State
    
    private var isMenuOpen = false
    private var items: [Int] = [5, 6, 7]
    private let itemTitles = ["Icecream money", "Great weather", "Beach ball", "Swim suit for him", "Swim suit for her", "Beach games", "Ironing board", "Cocktail mood", "Sunglasses", "Flip flops"]
    
    //	MARK: Actions
    
    @IBAction private func actionToggleMenu(sender: AnyObject) {
        isMenuOpen = !isMenuOpen
        
        for constraint in titleLabel.superview!.constraints where constraint.identifier != nil {
            switch constraint.identifier! {
            case "titleCenterX":
                constraint.constant = isMenuOpen ? -100.0 : 0.0
            case "titleCenterY":
                constraint.active = false
                let newConstraint = NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel.superview!, attribute: .CenterY, multiplier: isMenuOpen ? 0.67 : 1.0, constant: 5.0)
                newConstraint.identifier = constraint.identifier
                newConstraint.active = true
            default:
                break
            }
        }
        menuHeightConstraint.constant = isMenuOpen ? 200.0 : 60.0
        titleLabel.text = isMenuOpen ? "Select Item" : "Packing List"
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
            
            //  rotate it 45º when menu is open to make it look like an 'X'
            let angle = self.isMenuOpen ? CGFloat(M_PI_4) : 0.0
            self.buttonMenu.transform = CGAffineTransformMakeRotation(angle)
            }, completion: nil)
        
        if isMenuOpen {
            slider = HorizontalItemList(inView: view)
            slider.didSelectItem = { index in
                self.items.append(index)
                self.tableView.reloadData()
                self.actionToggleMenu(self)
            }
            
            self.titleLabel.superview!.addSubview(slider)
        } else {
            slider.removeFromSuperview()
        }
    }
    
    //	MARK: UI Management
    
    private func showItem(index: Int) {
        
        //  create image view appropriate to the selected item
        let image = UIImage(named: "summericons_100px_0\(index).png")
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        //  create constraints for the image view starting with centering horizontally
        let constraintX = imageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        //  attach image view to the bottom of the view + the height of the image view to shift it down primed for animation
        let constraintBottom = imageView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: imageView.frame.height)
        //  make the image view width a third of the width of the view (minus 50 to be animated)
        let constraintWidth = imageView.widthAnchor.constraintEqualToAnchor(view.widthAnchor, multiplier: 1/3, constant: -50.0)
        //  keep the height the same as the width
        let constraintHeight = imageView.heightAnchor.constraintEqualToAnchor(imageView.widthAnchor)
        
        NSLayoutConstraint.activateConstraints([constraintX, constraintBottom, constraintWidth, constraintHeight])
        
        view.layoutIfNeeded()
        
        //  animate the moving of the image view into the centre
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            constraintBottom.constant = -imageView.frame.size.height / 2.0
            constraintWidth.constant = 0.0
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        UIView.animateWithDuration(0.8, delay: 1.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            constraintBottom.constant = imageView.frame.height * 1.5
            self.view.layoutIfNeeded()
            }, completion: { _ in
                imageView.removeFromSuperview()
        })
    }
    
    //	MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.rowHeight = 54.0
    }
}

//	MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    // MARK: Table View methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = .None
        cell.textLabel?.text = itemTitles[items[indexPath.row]]
        cell.imageView?.image = UIImage(named: "summericons_100px_0\(items[indexPath.row]).png")
        return cell
    }
}

//	MARK: UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        showItem(items[indexPath.row])
    }
    
}