import Foundation
import CoreData
import UIKit

class SaveNoteDBOperation: BaseDBOperation {
    private let note: Note
    private let backgroundContext: NSManagedObjectContext!
    private let backgroundContextAction: BackgroundContextAction
    private let noteUIDForUpdating: String?

    
    init(note: Note,
         notebook: FileNotebook,
         backgroundContext: NSManagedObjectContext,
         backgroundContextAction: BackgroundContextAction,
         noteUIDForUpdating: String? = nil) {
        self.note = note
        self.backgroundContext = backgroundContext
        self.backgroundContextAction = backgroundContextAction
        self.noteUIDForUpdating = noteUIDForUpdating
        super.init(notebook: notebook)
    }
    
    override func main() {
        
        switch backgroundContextAction {
        case .Create:
            createRecord()
        case .Update:
            updateRecord()
            
        }        
//        notebook.saveToFile()
        finish()
    }
    
    func createRecord() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            let notesEntity = NotesEntity(context: self.backgroundContext)
            var red: CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
            self.note.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            notesEntity.uid = self.note.uid
            notesEntity.title = self.note.title
            notesEntity.content = self.note.content
            notesEntity.red = Double(red)
            notesEntity.green = Double(green)
            notesEntity.blue = Double(blue)
            notesEntity.alpha = Double(alpha)
            notesEntity.importance = self.note.importance.rawValue
            notesEntity.selfDestructionDate = self.note.selfDestructionDate
            
            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch {
                    print(error)
                }
            }
        }
//        notebook.add(note)
    }
    
    func updateRecord() {
        
    guard let uid = noteUIDForUpdating else { return }
    let fetchRequest = NSFetchRequest<NotesEntity>.init(entityName: "NotesEntity")
    fetchRequest.predicate = NSPredicate(format: "uid = %@", uid)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: true)]
        do {
            let notes =  try backgroundContext.fetch(fetchRequest)
            let objectUpdate = notes[0] as NSManagedObject
            objectUpdate.setValue(note.uid, forKey: "uid")
            objectUpdate.setValue(note.title, forKey: "title")
            objectUpdate.setValue(note.content, forKey: "content")
            
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            note.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            objectUpdate.setValue(red, forKey: "red")
            objectUpdate.setValue(green, forKey: "green")
            objectUpdate.setValue(blue, forKey: "blue")
            objectUpdate.setValue(alpha, forKey: "alpha")
            objectUpdate.setValue(note.importance.rawValue, forKey: "importance")
            objectUpdate.setValue(note.selfDestructionDate, forKey: "selfDestructionDate")
            
            backgroundContext.performAndWait {
                do {
                    try backgroundContext.save()
                    print("saved into store")
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
//            notebook.remove(with: uid)
    }
}

