import Foundation

class LoadNotesOperation: AsyncOperation {
    private let notebook: FileNotebook
    private let loadFromDB: LoadNotesDBOperation
    private var loadFromBackend: LoadNotesBackendOperation?
    private let networkNoteBook: NetworkNoteBook
//    var fromLocalDBNotes: [String:Note]?
    
    private(set) var result: String?

    init(
         notebook: FileNotebook,
         networkNoteBook: NetworkNoteBook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {

        self.notebook = notebook
        self.networkNoteBook = networkNoteBook
//        self.fromLocalDBNotes = [String:Note]()
        loadFromDB = LoadNotesDBOperation(notebook: notebook)
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
            result = "sucsses"
           
        case .failure:
            result = "failure"
        case .emptyFile:
            result = "emptyFile"
            self.notebook.cleanNotes()
    }
    finish()
//    func isEqual() -> Bool{
//        for valueBackend in loadFromBackend!.notes! {
//            for valueLocal in fromLocalDBNotes!.keys {
//                if valueBackend.uid != valueLocal {
//                    return false
//                }
//            }
//        }
//        return true
//    }
    }

}
