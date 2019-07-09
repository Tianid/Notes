import UIKit

class ColorPickerViewController: UIViewController {
    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var boxColor: UIView!
    @IBOutlet weak var sliderColor: UISlider!
    @IBOutlet weak public var label: UILabel!
    
    var color: UIColor?
    
    @IBAction func actionDone(_ sender: UIButton) {
        performSegue(withIdentifier: "toMain", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var sliderValue: CGFloat = 0
        color?.getHue(nil, saturation: nil, brightness: &sliderValue, alpha: nil)
        sliderColor.value = Float(sliderValue)
        colorPicker.myBrightness = sliderValue
        boxColor.backgroundColor = color
        boxColor.layer.borderWidth = 1
        boxColor.layer.cornerRadius = 10
        colorPicker.layer.borderWidth = 1
        sliderColor.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .allTouchEvents)
        colorPicker.boxColor = boxColor
        colorPicker.drawCursor(at: colorPicker.getCursorPosition(for: boxColor.backgroundColor!))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMain" {
            let vc = segue.destination as! ViewController
            vc.colorForColoderBox = boxColor.backgroundColor
        }
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        boxColor.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        boxColor.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: CGFloat(slider.value), alpha: 1.0)
        colorPicker.myBrightness = CGFloat(slider.value)
        //        if let touchEvent = event.allTouches?.first{
        //            switch touchEvent.phase {
        //            case .ended:
        //
        //            default:
        //                break
        //            }
        //        }
    }
}
