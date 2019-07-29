import Foundation

class RemoveNotesDBOperation: BaseDBOperation {
    private let note: Note
    
    init(note: Note,
         notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.remove(with: note.uid)
        notebook.saveToFile()
        finish()
    }
}
