
import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var whiteBox: BoxFlag!
    @IBOutlet weak var redBox: BoxFlag!
    @IBOutlet weak var greenBox: BoxFlag!
    @IBOutlet weak var coloredBox: BoxFlag!
    
    var boxChar: Character = " "
    
    @IBAction func actionWhiteBoxTapped(_ sender: Any) {
        whiteBox.isShapeHiden = !whiteBox.isShapeHiden
        if whiteBox.isShapeHiden {
            redBox.isShapeHiden = false
            greenBox.isShapeHiden = false
            boxChar = "W"
        } else {
            boxChar = " "
        }
    }
    
    @IBAction func actionRedBoxTapped(_ sender: Any) {
        redBox.isShapeHiden = !redBox.isShapeHiden
        if redBox.isShapeHiden {
            whiteBox.isShapeHiden = false
            greenBox.isShapeHiden = false
            boxChar = "R"
        } else {
            boxChar = " "
        }
    }
    
    @IBAction func actionGreenBoxTapped(_ sender: Any) {
        greenBox.isShapeHiden = !greenBox.isShapeHiden
        if greenBox.isShapeHiden {
            redBox.isShapeHiden = false
            whiteBox.isShapeHiden = false
            boxChar = "G"
        } else {
            boxChar = " "
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        whiteBox.backgroundColor = UIColor.white
        whiteBox.layer.borderWidth = 1
        whiteBox.layer.borderColor = UIColor.gray.cgColor
        
        redBox.backgroundColor = UIColor.red
        redBox.layer.borderWidth = 1
        redBox.layer.borderColor = UIColor.gray.cgColor
        
        greenBox.backgroundColor = UIColor.green
        greenBox.layer.borderWidth = 1
        greenBox.layer.borderColor = UIColor.gray.cgColor
        
        coloredBox.backgroundColor = UIColor.orange
        coloredBox.layer.borderWidth = 1
        coloredBox.layer.borderColor = UIColor.gray.cgColor
        
        textView.backgroundColor = UIColor.white
        textView.isScrollEnabled = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.delegate = self
        textViewDidChange(textView)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
            
        }
    }
    
    

    

}



