import Foundation
import CoreData

class SaveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let networkNoteBook: NetworkNoteBook
    private let saveToDb: SaveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    private let backgroundContextAction: BackgroundContextAction!
    private let noteUIDForUpdating: String?
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         networkNoteBook: NetworkNoteBook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue,
         backgroundContext: NSManagedObjectContext,
         backgroundContextAction: BackgroundContextAction,
         noteUIDForUpdating: String? = nil) {
        self.note = note
        self.notebook = notebook
        self.networkNoteBook = networkNoteBook
        self.backgroundContextAction = backgroundContextAction
        self.noteUIDForUpdating = noteUIDForUpdating
        
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook, backgroundContext: backgroundContext, backgroundContextAction: backgroundContextAction, noteUIDForUpdating: noteUIDForUpdating)
        saveToBackend = SaveNotesBackendOperation(noteBook: notebook, networkNoteBook: networkNoteBook)
        
        super.init()
        
        saveToDb.completionBlock = {
            backendQueue.addOperation(self.saveToBackend!)
        }
        addDependency(saveToDb)
        addDependency(saveToBackend!)
        
        dbQueue.addOperation(saveToDb)
    }
    
    override func main() {

        switch saveToBackend!.result! {
        case .success:
            result = true
        case .failure:
            result = false
        case .noData:
            result = false
        case .noGistOrNoNetworkConnection:
            result = false
        case .emptyFile:
            result = false
        }
        finish()
    }
}
