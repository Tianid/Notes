import Foundation
import CoreData

class RemoveNoteOperation: AsyncOperation {
    private let notebook: FileNotebook
    private let networkNotebook: NetworkNoteBook
    private let removeFromeDb: RemoveNotesDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    private(set) var result: Bool? = false
    
    init(
        note: Note,
        notebook: FileNotebook,
        networkNoteBook: NetworkNoteBook,
        backendQueue: OperationQueue,
        dbQueue: OperationQueue,
        backgroundContext: NSManagedObjectContext) {
        
        self.notebook = notebook
        self.networkNotebook = networkNoteBook
        
        removeFromeDb = RemoveNotesDBOperation(note: note, notebook: notebook, backgroundContext: backgroundContext)
        saveToBackend = SaveNotesBackendOperation(noteBook: notebook, networkNoteBook: networkNoteBook)
        
        super.init()
        
        removeFromeDb.completionBlock = {
            
            backendQueue.addOperation(self.saveToBackend!)
        }
        addDependency(removeFromeDb)
        addDependency(saveToBackend!)
        dbQueue.addOperation(removeFromeDb)
        
    }
    
    override func main() {
        switch saveToBackend!.result {
        case .success?:
            result = true
        case .failure?:
            result = false
        case .noData?:
            result = false
        case .noGistOrNoNetworkConnection?:
            result = false
        case .emptyFile?:
            result = false
        case .none: break
        
        }
        finish()
    }
}

