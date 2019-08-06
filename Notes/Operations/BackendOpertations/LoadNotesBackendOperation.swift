import Foundation

enum LoadNotesBackendResult {
    case success
    case failure(NetworkError)
    case emptyFile
}

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: LoadNotesBackendResult?
    var noteBook: FileNotebook?
    var notes: [Note]?
    let networkNoteBook = NetworkNoteBook()
    
    init(noteBook: FileNotebook) {
        super.init()
        self.noteBook = noteBook
    }
    
    override func main() {
        self.networkNoteBook.getContentFromGist { [unowned self] in
            if self.networkNoteBook.notes != nil {
                self.result = .success
            } else {
                if self.networkNoteBook.result == "empty_file" {
                    self.result = .emptyFile
                } else {
                    self.result = .failure(.unreachable)
                }
                
            }
            self.finish()
        }
    }
}
