
import UIKit

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var whiteBox: BoxFlag!
    @IBOutlet weak var redBox: BoxFlag!
    @IBOutlet weak var greenBox: BoxFlag!
    @IBOutlet weak var coloredBox: BoxFlag!
    @IBOutlet weak var dateSwitcher: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var colorForColoderBox: UIColor? = nil
    var boxChar: Character?
    var destroyDate: Date?
    
    
    @IBAction func actionDateSwitcher(_ sender: UISwitch) {
        datePicker.isHidden = !datePicker.isHidden
        if datePicker.isHidden {
            destroyDate = nil
        }
    }
    
    @IBAction func actionDatePicker(_ sender: UIDatePicker) {
        destroyDate = sender.date
    }
    
    
    @IBAction func actionWhiteBoxTapped(_ sender: Any) {
        whiteBox.isShapeHiden = !whiteBox.isShapeHiden
        if !whiteBox.isShapeHiden {
            redBox.isShapeHiden = true
            greenBox.isShapeHiden = true
            coloredBox.isShapeHiden = true
            coloredBox.isRainbowBackground = true
        }
    }
    
    @IBAction func actionRedBoxTapped(_ sender: Any) {
        redBox.isShapeHiden = !redBox.isShapeHiden
        if !redBox.isShapeHiden {
            whiteBox.isShapeHiden = true
            greenBox.isShapeHiden = true
            coloredBox.isShapeHiden = true
            coloredBox.isRainbowBackground = true
        }
    }
    
    @IBAction func actionGreenBoxTapped(_ sender: Any) {
        greenBox.isShapeHiden = !greenBox.isShapeHiden
        if !greenBox.isShapeHiden {
            redBox.isShapeHiden = true
            whiteBox.isShapeHiden = true
            coloredBox.isShapeHiden = true
            coloredBox.isRainbowBackground = true
        }
    }
    
    @IBAction func longTapToCallPalette(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            coloredBox.isShapeHiden = !coloredBox.isShapeHiden
            if !coloredBox.isShapeHiden {
                redBox.isShapeHiden = true
                whiteBox.isShapeHiden = true
                greenBox.isShapeHiden = true
            }
            performSegue(withIdentifier: "toColorPicker", sender: self)
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
        
        if colorForColoderBox == nil {
            coloredBox.isRainbowBackground = true
        } else {
            coloredBox.backgroundColor = colorForColoderBox
            coloredBox.isRainbowBackground = false
            colorForColoderBox = nil
            coloredBox.isShapeHiden = false
        }
        coloredBox.layer.borderWidth = 1
        coloredBox.layer.borderColor = UIColor.gray.cgColor
        
        textView.backgroundColor = UIColor.white
        textView.isScrollEnabled = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.delegate = self
        textViewDidChange(textView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toColorPicker" {
            if let destination = segue.destination as? ColorPickerViewController {
                destination.color = coloredBox.backgroundColor
            }
        }
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
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
        titleTextField.resignFirstResponder()
    }
}



