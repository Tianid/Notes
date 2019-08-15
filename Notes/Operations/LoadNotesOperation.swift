import Foundation
import CoreData
import UIKit

class LoadNotesOperation: AsyncOperation {
    private let notebook: FileNotebook
    private let loadFromDB: LoadNotesDBOperation
    private var loadFromBackend: LoadNotesBackendOperation?
    private let networkNoteBook: NetworkNoteBook
    private let backgroundContext: NSManagedObjectContext
//    var fromLocalDBNotes: [String:Note]?
    
    private(set) var result: NotesBackendResult!

    init(
         notebook: FileNotebook,
         networkNoteBook: NetworkNoteBook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         backgroundContext: NSManagedObjectContext) {

        self.notebook = notebook
        self.networkNoteBook = networkNoteBook
        self.backgroundContext = backgroundContext
//        self.fromLocalDBNotes = [String:Note]()
        loadFromDB = LoadNotesDBOperation(notebook: notebook, backgroundContext: backgroundContext)
        loadFromBackend = LoadNotesBackendOperation(noteBook: notebook, networkNoteBook: networkNoteBook)
        
        super.init()
        
        loadFromDB.completionBlock = {
            backendQueue.addOperation(self.loadFromBackend!)
        }
        addDependency(loadFromDB)
        addDependency(loadFromBackend!)
        dbQueue.addOperation(loadFromDB)
//        fromLocalDBNotes = notebook.notes
        
    }
    
    override func main() {
        switch loadFromBackend!.result! {
        case .success:
            notebook.saveDataFromArrayToDictionary(notes: (self.networkNoteBook.notes)!, cleanFlag: true)
            refreshCoreData()
            result = .success
           
        case .failure:
            result = .failure(.unreachable)
        case .emptyFile:
            result = .emptyFile
            self.notebook.cleanNotes()
        case .noData:
            result = .noData
        case .noGistOrNoNetworkConnection:
            result = .noGistOrNoNetworkConnection
        }
        finish()
    }
    
    
    
    private func resetCoreData() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "NotesEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try backgroundContext.execute(deleteRequest)
            try backgroundContext.save()
        }
        catch {
            print (error)
        }
    }
    
    private func setNewObjectsToCoreData() {
        for item in networkNoteBook.notes! {
            let notesEntity = NotesEntity(context: self.backgroundContext)
            
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            item.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            notesEntity.uid = item.uid
            notesEntity.title = item.title
            notesEntity.content = item.content
            notesEntity.red = Double(red)
            notesEntity.green = Double(green)
            notesEntity.blue = Double(blue)
            notesEntity.alpha = Double(alpha)
            notesEntity.importance = item.importance.rawValue
            notesEntity.selfDestructionDate = item.selfDestructionDate
            
            
        }
        self.backgroundContext.performAndWait {
            do {
                try self.backgroundContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func refreshCoreData() {
        resetCoreData()
        setNewObjectsToCoreData()
    }

}
