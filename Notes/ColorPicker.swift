import UIKit

@IBDesignable
class ColorPicker: UIView {
    
    let saturationExponentBottom:Float = 1.0
    var myBrightness: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var elementSize: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: 0.0 ,to: rect.height , by: elementSize) {
            var saturation = 2.0 * CGFloat(rect.height - y) / rect.height
            
            saturation = CGFloat(powf(Float(saturation), saturationExponentBottom))
            for x : CGFloat in stride(from: 0.0 ,to: rect.width  , by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: myBrightness, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
    }
    
    func getColorAt(point : CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
                                   y:elementSize * CGFloat(Int(point.y / elementSize)))
        var saturation = 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        saturation = CGFloat(powf(Float(saturation),  saturationExponentBottom))
        let hue = roundedPoint.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: myBrightness, alpha: 1.0)
    }
}
