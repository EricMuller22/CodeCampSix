import UIKit
import XCPlayground


let image = UIImage(named: "spinner")!
let spinner = UIImageView.init(frame: CGRect(origin: CGPointZero, size: image.size))
spinner.image = image

let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.backgroundColor = UIColor.init(red: 64.0/255.0, green: 128.0/255.0, blue: 224.0/255.0, alpha: 1.0)

view.addSubview(spinner)
spinner.center = view.center

let spin = CABasicAnimation()
spin.keyPath = "transform.rotation"
spin.duration = 1.0
spin.fromValue = 0
spin.toValue = 2 * M_PI
spin.repeatCount = 10
spinner.layer.addAnimation(spin, forKey: spin.keyPath)

XCPlaygroundPage.currentPage.liveView = view
