import Foundation

class LoadNotesDBOperation: BaseDBOperation {
    
    
    override init(notebook: FileNotebook) {
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.loadFromFile()
        finish()
    }
}
