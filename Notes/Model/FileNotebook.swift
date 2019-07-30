import Foundation

class FileNotebook {
    private(set) var notes: [String:Note]
    
    init() {
        self.notes = [String:Note]()
//        loadFromFile()
    }
    
    public func add(_ note: Note) {
//        if self.notes.count > 0 {
//            let keys = self.notes.keys
//            if (keys.firstIndex(of: note.uid ) == nil) {
//                self.notes.updateValue(note, forKey: note.uid)
//            }
//        } else {
//            self.notes.updateValue(note, forKey: note.uid)
//        }
        self.notes.updateValue(note, forKey: note.uid)

    }
    
    public func updateNotes(_ note: Note) {
        self.notes.updateValue(note, forKey: note.uid)
    }
    
    public func remove(with uid: String) {
        self.notes.removeValue(forKey: uid)
    }
    
    public func saveToFile() {
        
        var result = [[String: Any]]()
        for value in notes.values {
            result.append(value.json)
        }
        
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        if path == nil { return }
        
        let dirUrl = path?.appendingPathComponent("StepikNoteBook")
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: (dirUrl?.path)!, isDirectory: &isDir) == false, isDir.boolValue == false{
            do {
                try FileManager.default.createDirectory(at: dirUrl!, withIntermediateDirectories: true, attributes: nil)
            } catch {}
        }
        
        let filename = dirUrl?.appendingPathComponent("Notes")
        do {
            let data = try JSONSerialization.data(withJSONObject: result, options: [])
            print(FileManager.default.createFile(atPath: filename!.path, contents: data, attributes: nil) , " - result of creating")
            print("absolute savepath - ",filename?.absoluteURL as Any)
        } catch {}
    }
    
    public func loadFromFile() {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        if path == nil { return }
        
        let dirUrl = path?.appendingPathComponent("StepikNoteBook/Notes")
        var isFile = false
        isFile = FileManager.default.fileExists(atPath: dirUrl!.path)
        if isFile {
            do {
                let data = try Data(contentsOf: dirUrl!)
                let serializableData = try JSONSerialization.jsonObject(with: data, options: []) as! [[String : Any]]
                for dictionary in serializableData {
                    print(dictionary)
                    if let note = Note.parse(json: dictionary) {
                        self.add(note)
                    }
                }
            } catch {}
        }
    }
    
    public func getArrayOfNotes() -> [Note]{
        var notesArray = [Note]()
        for value in (notes.values) {
            notesArray.append(value)
        }
        return notesArray
    }
    
    public func saveDataFromArrayToDictionary(notes: [Note]) {
        for value in notes {
            self.notes.updateValue(value, forKey: value.uid)
        }
    }
    
    public func setDictionaty(dict: [String:Note]) {
        self.notes = dict
    }
    
//    public func deleteDirWithNotes() {
//        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
//        if path == nil { return }
//
//        let dirUrl = path?.appendingPathComponent("StepikNoteBook")
//        var isDir:ObjCBool = false
//        if FileManager.default.fileExists(atPath: (dirUrl?.path)!, isDirectory: &isDir), isDir.boolValue {
//            do {
//                try FileManager.default.removeItem(at: dirUrl!)
//            } catch { }
//        }
//    }
    
}
