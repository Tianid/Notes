
import UIKit

@IBDesignable
class BoxFlag: UIView {
    
    let saturationExponentTop:Float = 2.0
    let saturationExponentBottom:Float = 1.3
    
    @IBInspectable var isRainbowBackground: Bool = false
    
    @IBInspectable var elementSize: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shapeColor: UIColor = .yellow {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var shapePosition: CGPoint = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var shapeSize: CGSize = CGSize(width: 5, height: 5) {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var isShapeHiden: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if (isRainbowBackground) {
            let context = UIGraphicsGetCurrentContext()
            for y : CGFloat in stride(from: 0.0 ,to: rect.height , by: elementSize) {
                var saturation = 2.0 * CGFloat(rect.height - y) / rect.height
                
                saturation = CGFloat(powf(Float(saturation), saturationExponentBottom))
                for x : CGFloat in stride(from: 0.0 ,to: rect.width  , by: elementSize) {
                    let hue = x / rect.width
                    let color = UIColor(hue: hue, saturation: saturation, brightness: CGFloat(1), alpha: 1.0)
                    context!.setFillColor(color.cgColor)
                    context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
                }
            }

        }
        
        guard !isShapeHiden else { return }
        shapeColor.setFill()
        setFlagPosition()
        let pathX = getX(in: CGRect(origin: shapePosition, size: shapeSize))

        pathX.fill()
    }
    
    private func getX(in rect:CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.lineWidth = lineWidth
        path.close()
        path.stroke()
        path.fill()
        
        return path
    }
    
   private func setFlagPosition() {
        shapePosition = CGPoint(x: shapePosition.x, y: shapePosition.y)
    }
}
