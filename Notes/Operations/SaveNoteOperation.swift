import Foundation

class SaveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let networkNoteBook: NetworkNoteBook
    private let saveToDb: SaveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         networkNoteBook: NetworkNoteBook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.note = note
        self.notebook = notebook
        self.networkNoteBook = networkNoteBook
        
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook)
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
        }
        finish()
    }
}
