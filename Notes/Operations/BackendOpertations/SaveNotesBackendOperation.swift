import Foundation

enum NetworkError {
    case unreachable
}

enum SaveNotesBackendResult {
    case success
    case failure(NetworkError)
    case noData
}

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: SaveNotesBackendResult?
    var noteBook: FileNotebook?
    var networkNoteBook: NetworkNoteBook?
    
    init(noteBook: FileNotebook, networkNoteBook: NetworkNoteBook) {
        super.init()
        self.noteBook = noteBook
        self.networkNoteBook = networkNoteBook
    }
    
    override func main() {
        self.result = .failure(.unreachable)
        self.finish()
        
//        self.networkNoteBook!.setContentForGist(notes: (noteBook?.getArrayOfNotes())!) { [unowned self] in
//            if self.networkNoteBook!.result == "sucsses" {
//                self.result = .success
//            } else if self.networkNoteBook!.result == "no data" {
//                self.result = .noData
//                print("no data")
//            } else if self.networkNoteBook!.result == "failure" {
//                self.result = .failure(.unreachable)
//                print("failure")
//            }
//            self.finish()
//        }
    }
}
