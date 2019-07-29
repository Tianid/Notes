

import UIKit

class MyTableViewController: UIViewController {

    let reusableCell = "reusableCell"
    var fileNoteBook: FileNotebook?
    var notes = [Note]()
    var noteIndex: Int?
    
    @IBAction func addButtonTap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toEditScreen", sender: nil)
    }
    @IBAction func editButtonTap (_ sender: UIBarButtonItem) {
        myTableView.isEditing = !myTableView.isEditing
    }
    
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        fileNoteBook = FileNotebook()
        
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
//        let commonQueu = OperationQueue()
        
        let loadNotesOperation = LoadNotesOperation(notebook: fileNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue)
        OperationQueue.main.addOperation(loadNotesOperation)
        
        
//        fileNoteBook?.add(Note(uid: "as", title: "1", content: "asdf", color: .green, importance: .notImportant))
//        fileNoteBook?.add(Note(uid: "as1", title: "2", content: "asdf", color: .red, importance: .common))
//        fileNoteBook?.add(Note(uid: "as2", title: "3", content: "asdf", color: .white, importance: .important))
//        fileNoteBook?.add(Note(uid: "sd3", title: "4", content: "qwerty", color: .orange, importance: .important, selfDestructionDate: Date()))
//        fileNoteBook?.add(Note(uid: "as4", title: "5", content: "asdf", color: .green, importance: .notImportant))
//        fileNoteBook?.add(Note(uid: "as5", title: "6", content: "asdf", color: .red, importance: .common))
//        fileNoteBook?.add(Note(uid: "as6", title: "7", content: "asdf", color: .white, importance: .important))
//        fileNoteBook?.add(Note(uid: "as7", title: "8", content: "asdf", color: .green, importance: .notImportant))
//        fileNoteBook?.add(Note(uid: "as8", title: "9", content: "asdf", color: .red, importance: .common))
//        fileNoteBook?.add(Note(uid: "as9", title: "10", content: "asdf", color: .white, importance: .important))
//        fileNoteBook?.add(Note(uid: "as10", title: "11", content: "asdf", color: .green, importance: .notImportant))
//        fileNoteBook?.add(Note(uid: "as11", title: "12", content: "asdf", color: .red, importance: .common))
//        fileNoteBook?.add(Note(uid: "as12", title: "13", content: "asdf", color: .white, importance: .important))
//        fileNoteBook?.add(Note(uid: "as13", title: "14", content: "asdf", color: .green, importance: .notImportant))
//        fileNoteBook?.add(Note(uid: "as14", title: "15", content: "asdf", color: .red, importance: .common))
//        fileNoteBook?.add(Note(uid: "as15", title: "16", content: "asdf", color: .white, importance: .important))
        
//        notes = (fileNoteBook?.getArrayOfNotes())!
        myTableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: reusableCell)
//        myTableView.isEditing = true
    }
}

extension MyTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes = (fileNoteBook?.getArrayOfNotes())!
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = myTableView.dequeueReusableCell(withIdentifier: reusableCell, for: indexPath) as! MyTableViewCell
            
            cell.noteTitle.text = notes[indexPath.row].title
            cell.noteContent.text = notes[indexPath.row].content
            cell.noteColor.backgroundColor = notes[indexPath.row].color
            cell.noteColor.layer.borderWidth = 1
            cell.selectionStyle = .none
            return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        noteIndex = indexPath.row
        performSegue(withIdentifier: "toEditScreenWithData", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEditScreenWithData" {
            if let destination = segue.destination as? ViewController{
                destination.fileNoteBook = fileNoteBook
                destination.note = self.notes[noteIndex!]
            }
        } else {
            if segue.identifier == "toEditScreen" {
                if let destination = segue.destination as? ViewController{
                    destination.fileNoteBook = fileNoteBook
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notes = (fileNoteBook?.getArrayOfNotes())!
        myTableView.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            myTableView.beginUpdates()
            let temp = notes[indexPath.row]
            notes.remove(at: indexPath.row)
//            fileNoteBook?.remove(with: temp.uid)
            let backendQueue = OperationQueue()
            let dbQueue = OperationQueue()
            let removeNoteOperation = RemoveNoteOperation(note: temp, notebook: fileNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue)
            
            OperationQueue.main.addOperation(removeNoteOperation)

            myTableView.deleteRows(at: [indexPath], with: .automatic)
            myTableView.endUpdates()
//            myTableView.reloadData()
        }
    }
    
}

