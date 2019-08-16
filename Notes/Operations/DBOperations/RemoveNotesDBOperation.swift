import Foundation
import CoreData

class RemoveNotesDBOperation: BaseDBOperation {
    private let note: Note
    private let backgroundContext: NSManagedObjectContext!
    
    init(note: Note,
         notebook: FileNotebook,
         backgroundContext: NSManagedObjectContext) {
        self.note = note
        self.backgroundContext = backgroundContext
        super.init(notebook: notebook)
    }
    
    override func main() {
        
        deleteRecord()
        
//        notebook.remove(with: note.uid)
//        notebook.saveToFile()
        finish()
    }
    
    private func deleteRecord() {
        let fetchRequest = NSFetchRequest<NotesEntity>(entityName: "NotesEntity")
        fetchRequest.predicate = NSPredicate(format: "uid = %@", note.uid)
        do {
            let notes = try backgroundContext.fetch(fetchRequest)
            let noteObject = notes[0] as NSManagedObject
            backgroundContext.delete(noteObject)
            backgroundContext.performAndWait {
                do {
                    try backgroundContext.save()
                } catch {
                    print(error)
                }
            }
        } catch {
           print(error)
        }
    }
}
