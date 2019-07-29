
import UIKit

class GalleryViewController: UIViewController {
    private var galleryCollectionView = GalleryCollectionView()
    let imagePicker = UIImagePickerController()
    var cells = [UIImage(named: "screen_1"), UIImage(named: "screen_2"), UIImage(named: "screen_3"), UIImage(named: "screen_4"), UIImage(named: "screen_5")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(galleryCollectionView)
        imagePicker.delegate = self
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        galleryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        galleryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        galleryCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        galleryCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addButtonTap (_ sender: Any) {
        present(self.imagePicker, animated: true, completion: nil)
        
    }
    
 
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cells.append(pickedImage)
        }
        dismiss(animated: true, completion: nil)
        galleryCollectionView.reloadData()
    }
    
    
    
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseId, for: indexPath) as! GalleryCollectionViewCell
        cell.mainImageView.image = cells[indexPath.row]
        cell.isSelected = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailImagesViewController
        detailVC.images = cells as? [UIImage]
        detailVC.myIndex = indexPath.row
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 200, height: 200)
    }
}
