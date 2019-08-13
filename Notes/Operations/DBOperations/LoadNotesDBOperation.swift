import Foundation
import CoreData
import UIKit
class LoadNotesDBOperation: BaseDBOperation {
    private let backgroundContext: NSManagedObjectContext!

    
    init(notebook: FileNotebook, backgroundContext: NSManagedObjectContext) {
        self.backgroundContext = backgroundContext
        super.init(notebook: notebook)

    }
    
    override func main() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotesEntity")
            do {
                let result = try self?.backgroundContext.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    let uid = data.value(forKey: "uid") as! String
                    let title = data.value(forKey: "title") as! String
                    let content = data.value(forKey: "content") as! String
                    let red = data.value(forKey: "red") as! CGFloat
                    let green = data.value(forKey: "green") as! CGFloat
                    let blue = data.value(forKey: "blue") as! CGFloat
                    let alpha = data.value(forKey: "alpha") as! CGFloat
                    let importance = data.value(forKey: "importance") as! String
                    let selfDestructionDate = data.value(forKey: "selfDestructionDate") as! Date?
                    let color: UIColor
                    
                    if red == 1 ,green == 1, blue == 1, alpha == 1 {
                        color = .white
                    } else {
                        color = UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
                    }
                    
                    self!.notebook.add(Note(uid: uid, title: title, content: content, color: color, importance: .common, selfDestructionDate: selfDestructionDate))
                }
                
            } catch {
                print(error)
            }
            self!.finish()
        }
//        notebook.loadFromFile()
    }
}
