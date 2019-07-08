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
    
    @IBAction func PanAction(_ sender: UIPanGestureRecognizer) {
        color = colorPicker.getColorAt(point: sender.location(in: colorPicker))
        boxColor.backgroundColor = color
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        boxColor.backgroundColor = color
        boxColor.layer.borderWidth = 1
        boxColor.layer.cornerRadius = 10
        colorPicker.layer.borderWidth = 1
        colorPicker.backgroundColor = .white
        sliderColor.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .allTouchEvents)
        colorPicker.myBrightness = CGFloat(sliderColor.value)
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first{
            switch touchEvent.phase {
            case .ended:
                colorPicker.myBrightness = CGFloat(slider.value)
                var hue: CGFloat = 0
                var saturation: CGFloat = 0
                color?.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
                boxColor.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: CGFloat(slider.value), alpha: 1.0)
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMain" {
            let vc = segue.destination as! ViewController
            vc.colorForColoderBox = boxColor.backgroundColor
        }
    }
}
