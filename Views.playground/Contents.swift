import PlaygroundSupport
import UIKit


let image = UIImage(named: "spinner")!
let spinner = UIImageView(frame: CGRect(origin: .zero, size: image.size))
spinner.image = image

let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.backgroundColor = UIColor(red: 64.0/255.0, green: 128.0/255.0, blue: 224.0/255.0, alpha: 1.0)

view.addSubview(spinner)
spinner.center = view.center

let spin = CABasicAnimation(keyPath: "transform.rotation")
spin.duration = 1.0
spin.fromValue = 0
spin.toValue = 2 * Float.pi
spin.repeatCount = 10
spinner.layer.add(spin, forKey: spin.keyPath)

PlaygroundPage.current.liveView = view
