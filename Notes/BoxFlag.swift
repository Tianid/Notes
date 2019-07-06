
import UIKit

@IBDesignable
class BoxFlag: UIView {
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
