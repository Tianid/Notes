import Foundation

enum LoadNotesBackendResult {
    case success
    case failure(NetworkError)
}

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: LoadNotesBackendResult?
    var noteBook: FileNotebook?
    var notes: [Note]?
    
    init(noteBook: FileNotebook) {
        super.init()
        self.noteBook = noteBook
    }
    
    override func main() {
        result = .failure(.unreachable)
        finish()
    }

    
}
