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
        notes = (fileNoteBook?.getArrayOfNotes())!
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueu = OperationQueue()
        
        let loadNotesOperation = LoadNotesOperation(notebook: fileNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue)
        loadNotesOperation.completionBlock = { [unowned self] in
            DispatchQueue.main.async {
                
                if loadNotesOperation.result == "sucsses" || loadNotesOperation.result == "emptyFile" {
                    // Data from GitHub Gists, if gist is empty then  tableview will be empty too
                    self.notes = (self.fileNoteBook?.getArrayOfNotes())!
                    self.myTableView.reloadData()
                } else {
                    
                    // Data from local storage
                    self.notes = (self.fileNoteBook?.getArrayOfNotes())!
                    self.myTableView.reloadData()
                }
            }
        }
        commonQueu.addOperation(loadNotesOperation)
        myTableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: reusableCell)
//        myTableView.isEditing = true
    }
}

extension MyTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            notes = (self.fileNoteBook?.getArrayOfNotes())!
            let cell = myTableView.dequeueReusableCell(withIdentifier: reusableCell, for: indexPath) as! MyTableViewCell
        if notes.count != 0 {
            cell.noteTitle.text = notes[indexPath.row].title
            cell.noteContent.text = notes[indexPath.row].content
            cell.noteColor.backgroundColor = notes[indexPath.row].color
            cell.noteColor.layer.borderWidth = 1
            cell.selectionStyle = .none
        }
            
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

            let backendQueue = OperationQueue()
            let dbQueue = OperationQueue()
            let commonQueue = OperationQueue()
            let removeNoteOperation = RemoveNoteOperation(note: temp, notebook: fileNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue)
            
            removeNoteOperation.completionBlock = {
                DispatchQueue.main.async {
                    self.myTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.myTableView.endUpdates()
                }
            }
            commonQueue.addOperation(removeNoteOperation)
        }
    }
}

