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
        loadFromBackend = LoadNotesBackendOperation(noteBook: notebook)
        
        super.init()
        
        loadFromDB.completionBlock = {
            backendQueue.addOperation(self.loadFromBackend!)
        }
        addDependency(loadFromDB)
        addDependency(loadFromBackend!)
        dbQueue.addOperation(loadFromDB)
        fromLocalDBNotes = notebook.notes
        
    }
    
    override func main() {
        switch loadFromBackend!.result! {
        case .success:
            result = true
            if isEqual() != true {
                fromLocalDBNotes = nil
            }
        case .failure:
            result = false
        }
        finish()
    }
    
    func isEqual() -> Bool{
        for valueBackend in loadFromBackend!.notes! {
            for valueLocal in fromLocalDBNotes!.keys {
                if valueBackend.uid != valueLocal {
                    return false
                }
            }
        }
        return true
    }
}

