import Foundation

class RemoveNoteOperation: AsyncOperation {
    private let notebook: FileNotebook
    private let removeFromeDb: RemoveNotesDBOperation
    private var saveToBackend: SaveNotesBackendOperation?
    
    private(set) var result: Bool? = false
    
    init(
        note: Note,
        notebook: FileNotebook,
        backendQueue: OperationQueue,
        dbQueue: OperationQueue) {
        
        self.notebook = notebook
        removeFromeDb = RemoveNotesDBOperation(note: note, notebook: notebook)
        saveToBackend = SaveNotesBackendOperation(notes: notebook.getArrayOfNotes())
        
        super.init()
        
        removeFromeDb.completionBlock = {
            
            backendQueue.addOperation(self.saveToBackend!)
        }
        addDependency(removeFromeDb)
        addDependency(saveToBackend!)
        dbQueue.addOperation(removeFromeDb)
        
    }
    
    override func main() {
        switch saveToBackend!.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}

