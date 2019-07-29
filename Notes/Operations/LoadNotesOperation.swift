import Foundation

class LoadNotesOperation: AsyncOperation {
    private let notebook: FileNotebook
    private let loadFromDB: LoadNotesDBOperation
    private var loadFromBackend: LoadNotesBackendOperation?
    var fromLocalDBNotes: [String:Note]?
    
    private(set) var result: Bool? = false
    
    init(
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {

        self.notebook = notebook
        self.fromLocalDBNotes = [String:Note]()
        loadFromDB = LoadNotesDBOperation(notebook: notebook)
        
        super.init()
        
        loadFromDB.completionBlock = {
            let loadFromBackend = LoadNotesBackendOperation(noteBook: notebook)
            self.loadFromBackend = loadFromBackend
            self.addDependency(loadFromBackend)
            backendQueue.addOperation(loadFromBackend)
        }
        addDependency(loadFromDB)
        dbQueue.addOperation(loadFromDB)
        fromLocalDBNotes = notebook.notes
        
    }
    
    override func main() {
        switch loadFromBackend!.result! {
        case .success:
            result = true
            fromLocalDBNotes = nil
        case .failure:
            result = false
        }
        finish()
    }
}

