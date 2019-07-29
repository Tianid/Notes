import UIKit

class DetailImagesViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    var images: [UIImage]?
    var imageViews = [UIImageView]()
    var myIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        for item in images! {
            let imageView = UIImageView(image: item)
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
  // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = scrollView.frame.size
            imageView.frame.origin.x = scrollView.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }
        let contentWidth = scrollView.frame.width * CGFloat(imageViews.count)
        scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
        
        let offset = scrollView.frame.width * CGFloat(Float(myIndex!))
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    }
}
