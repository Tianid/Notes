import Foundation

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: NotesBackendResult!
    var noteBook: FileNotebook?
    var notes: [Note]?
    var networkNoteBook: NetworkNoteBook?
    
    init(noteBook: FileNotebook, networkNoteBook: NetworkNoteBook) {
        super.init()
        self.noteBook = noteBook
        self.networkNoteBook = networkNoteBook
    }
    
    override func main() {
        
//        self.result = .failure(.unreachable)
//        self.finish()
        self.networkNoteBook!.getContentFromGist { [unowned self] in
            if self.networkNoteBook!.notes != nil {
                self.result = .success
            } else {
                switch self.networkNoteBook?.result {
                case .some(.emptyFile):
                    self.result = .emptyFile
                case .none:
                    self.result = .failure(.unreachable)
                case .some(.success):
                    self.result = .failure(.unreachable)
                case .some(.failure(_)):
                    self.result = .failure(.unreachable)
                case .some(.noData):
                    self.result = .failure(.unreachable)
                case .some(.noGistOrNoNetworkConnection):
                    self.result = .failure(.unreachable)
                }
            }
            self.finish()
        }
    }
}
