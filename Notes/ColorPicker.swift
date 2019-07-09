import UIKit

@IBDesignable
class ColorPicker: UIView {
    
    var boxColor: UIView? =  UIView()
    var color: UIColor? = .red
    let cursor = CursorView()
    let saturationExponentBottom:Float = 1.0
    var myBrightness: CGFloat = 1
    
    @IBInspectable var elementSize: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for y : CGFloat in stride(from: 0.0 ,to: rect.height , by: elementSize) {
            var saturation = 2.0 * CGFloat(rect.height - y) / rect.height
            
            saturation = CGFloat(powf(Float(saturation), saturationExponentBottom))
            for x : CGFloat in stride(from: 0.0 ,to: rect.width  , by: elementSize) {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
        drawCursor(at: getCursorPosition(for: (boxColor?.backgroundColor!)! ))
    }
    
    private func setup() {
        self.clipsToBounds = true
        boxColor?.backgroundColor = .red
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)
        cursor.frame.size = CGSize(width: 20.0, height: 20.0)
        cursor.backgroundColor = UIColor.clear
        self.addSubview(cursor)
    }
    
    @objc private func touchedColor(gestureRecognizer: UILongPressGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        let color = getColorAt(point: point)
        self.color = color
        drawCursor(at: point)
        boxColor?.backgroundColor = color
    }
    
    func getCursorPosition(for color: UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil);
        let halfHeight = (self.bounds.height / 2)
        let yPos = halfHeight + halfHeight * (1.0 - saturation)
        let xPos = hue * self.bounds.width
        return CGPoint(x: xPos, y: yPos)
    }
    
    func getColorAt(point : CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
                                   y:elementSize * CGFloat(Int(point.y / elementSize)))
        var saturation = 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        saturation = CGFloat(powf(Float(saturation),  saturationExponentBottom))
        let hue = roundedPoint.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: myBrightness, alpha: 1.0)
    }
    
    func drawCursor(at point: CGPoint) {
        cursor.center = point
    }
}
