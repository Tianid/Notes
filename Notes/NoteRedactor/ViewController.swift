import UIKit
import CoreData

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var whiteBox: BoxFlag!
    @IBOutlet weak var redBox: BoxFlag!
    @IBOutlet weak var greenBox: BoxFlag!
    @IBOutlet weak var coloredBox: BoxFlag!
    @IBOutlet weak var dateSwitcher: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var colorForColoderBox: UIColor? = nil
    private var boxChar: Character?
    private var destroyDate: Date?
    private var colorFromPallet: UIColor?
    var fileNoteBook: FileNotebook?
    var networkNoteBook: NetworkNoteBook?
    var note:Note?
    var backgroundContext: NSManagedObjectContext!
    var backgroundContextAction:BackgroundContextAction!
    
    
    @IBAction func actionDateSwitcher(_ sender: UISwitch) {
        destroyDate = datePicker.date
        switchDate()
    }
    
    @IBAction func actionDatePicker(_ sender: UIDatePicker) {
        destroyDate = sender.date
    }
    
    
    @IBAction func changeShapeOfBoxes(_ sender: UITapGestureRecognizer) {
        let array = [greenBox,whiteBox,redBox,coloredBox]
        for item in array {
            if item == sender.view {
                item?.isShapeHiden = !item!.isShapeHiden
                if sender.view == coloredBox {
                    coloredBox.isRainbowBackground = !coloredBox.isRainbowBackground
                } else {
                    coloredBox.isRainbowBackground = true
                }
            } else {
                item?.isShapeHiden = true
            }
        }
    }
    
    @IBAction func longTapToCallPalette(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            redBox.isShapeHiden = true
            whiteBox.isShapeHiden = true
            greenBox.isShapeHiden = true
            performSegue(withIdentifier: "toColorPicker", sender: self)
        }
    }
    
    @IBAction func unwindToEditorScreen(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! ColorPickerViewController
        coloredBox.isRainbowBackground = false
        coloredBox.isShapeHiden = false
        coloredBox.backgroundColor = sourceViewController.colorPicker.boxColor?.backgroundColor
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toColorPicker" {
            if let destination = segue.destination as? ColorPickerViewController {
                destination.color = coloredBox.backgroundColor
            }
        }
    }
    
    private func setup() {
        if note != nil {
            titleTextField.text = note?.title
            textView.text = note?.content
            
            if note?.selfDestructionDate != nil {
                datePicker.setDate((note?.selfDestructionDate)!, animated: false)
                dateSwitcher.isOn = true
                switchDate()
            }
            switch note?.color {
            case UIColor.red:
                redBox.isShapeHiden = false
            case UIColor.green:
                greenBox.isShapeHiden = false
            case UIColor.white:
                whiteBox.isShapeHiden = false
            default:
                colorForColoderBox = note!.color
                coloredBox.isShapeHiden = false
            }
        } else {
            textView.text = ""
            titleTextField.text = ""
        }
        
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
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote(_:)))
    }

    
    private func switchDate() {
        datePicker.isHidden = !datePicker.isHidden
        if datePicker.isHidden {
            destroyDate = nil
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
    
    @objc private func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
        titleTextField.resignFirstResponder()
    }
    
    @objc private func saveNote(_ sender: Any) {
        titleTextField.text! = titleTextField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if titleTextField.text!.isEmpty || textView.text.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Fill title and content fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        if note == nil {
            let newNote = Note(title: titleTextField.text!, content: textView.text, color: getColorOfSelectedBox()!, importance: .common, selfDestructionDate: destroyDate)
            fileNoteBook?.add(newNote)
            let saveNoteOperation = SaveNoteOperation(note: newNote, notebook: fileNoteBook!, networkNoteBook: networkNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue, backgroundContext: backgroundContext, backgroundContextAction: backgroundContextAction)
            commonQueue.addOperation(saveNoteOperation)
        } else {
            let uid = note?.uid
            fileNoteBook?.remove(with: uid!)
            let newNote = Note(title: titleTextField.text!, content: textView.text, color: getColorOfSelectedBox()!, importance: .common, selfDestructionDate: destroyDate)
            fileNoteBook?.add(newNote)
            let saveNoteOperation = SaveNoteOperation(note: newNote, notebook: fileNoteBook!, networkNoteBook: networkNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue, backgroundContext: backgroundContext, backgroundContextAction: backgroundContextAction, noteUIDForUpdating: uid)
            commonQueue.addOperation(saveNoteOperation)
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func getColorOfSelectedBox() -> UIColor? {
        let array = [greenBox,whiteBox,redBox,coloredBox]
        var color:UIColor?
        for item in array {
            if item?.isShapeHiden == false {
                color = item?.backgroundColor
            }
        }
        guard color == nil else { return color }
        color = .white
        return color
    }
}



