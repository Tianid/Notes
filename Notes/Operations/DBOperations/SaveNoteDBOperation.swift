import Foundation
import CoreData
import UIKit

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    private let backgroundContext: NSManagedObjectContext!
    private let backgroundContextAction: String!
    private var noteUIDForUpdating: String? = nil

    
    init(note: Note,
         notebook: FileNotebook,
         backgroundContext: NSManagedObjectContext,
         backgroundContextAction: String,
         noteUIDForUpdating: String?) {
        self.note = note
        self.backgroundContext = backgroundContext
        self.backgroundContextAction = backgroundContextAction
        self.noteUIDForUpdating = noteUIDForUpdating
        super.init(notebook: notebook)
    }
    
    override func main() {
        switch backgroundContextAction {
        case "Update":
            updateRecord()
        case "Create":
            createRecord()
        default:
            break
        }
        
//        notebook.saveToFile()
        finish()
    }
    
    func createRecord() {
        guard let backgroundContext = backgroundContext else { return }
        
        let notesEntity = NotesEntity(context: backgroundContext)
        
        
        var red: CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        note.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        notesEntity.uid = note.uid
        notesEntity.title = note.title
        notesEntity.content = note.content
        notesEntity.red = Double(red)
        notesEntity.green = Double(green)
        notesEntity.blue = Double(blue)
        notesEntity.alpha = Double(alpha)
        notesEntity.importance = note.importance.rawValue
        notesEntity.selfDestructionDate = note.selfDestructionDate
        
        backgroundContext.performAndWait {
            do {
                try backgroundContext.save()
            } catch {
                print(error)
            }
        }
//        notebook.add(note)
    }
    
    func updateRecord() {
        guard let backgroundContext = backgroundContext else { return }
        guard let uid = noteUIDForUpdating else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "NotesEntity")
        fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
        do {
            let notes = try backgroundContext.fetch(fetchRequest)
            let objectUpdate = notes[0] as! NSManagedObject
            
            objectUpdate.setValue(note.uid, forKey: "uid")
            objectUpdate.setValue(note.title, forKey: "title")
            objectUpdate.setValue(note.content, forKey: "content")
            
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            note.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            print()
            objectUpdate.setValue(red, forKey: "red")
            objectUpdate.setValue(green, forKey: "green")
            objectUpdate.setValue(blue, forKey: "blue")
            objectUpdate.setValue(alpha, forKey: "alpha")
            objectUpdate.setValue(note.importance.rawValue, forKey: "importance")
            objectUpdate.setValue(note.selfDestructionDate, forKey: "selfDestructionDate")
            
            backgroundContext.performAndWait {
                do {
                    try backgroundContext.save()
                } catch {
                    print(error)
                }
            }
//            notebook.remove(with: uid)
        } catch {
            print(error)
        }
    }
}
