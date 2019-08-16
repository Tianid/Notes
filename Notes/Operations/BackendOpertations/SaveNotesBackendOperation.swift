import Foundation

enum NetworkError {
    case unreachable
}

class SaveNotesBackendOperation: BaseBackendOperation {
    private(set) var result: NotesBackendResult!
    private var noteBook: FileNotebook?
    private var networkNoteBook: NetworkNoteBook?
    
    init(noteBook: FileNotebook, networkNoteBook: NetworkNoteBook) {
        super.init()
        self.noteBook = noteBook
        self.networkNoteBook = networkNoteBook
    }
    
    override func main() {
//        self.result = .failure(.unreachable)
//        self.finish()
        
        self.networkNoteBook!.setContentForGist(notes: (noteBook?.getArrayOfNotes())!) { [unowned self] in
            switch self.networkNoteBook?.result {
            case .some(.success):
                self.result = .success
            case .some(.noData):
                self.result = .noData
            case .some(.noGistOrNoNetworkConnection):
                self.result = .failure(.unreachable)
            case .some(.emptyFile):
                self.result = .emptyFile
            case .some(.failure):
                self.result = .failure(.unreachable)
           
            case .none:
                break
            }
            self.finish()
        }
    }
}
