import UIKit
import CoreData

class MyTableViewController: UIViewController {
    
    var backgroundContext: NSManagedObjectContext! {
        didSet {
            fetchData()
        }
    }
    var context: NSManagedObjectContext! 

    let reusableCell = "reusableCell"
    var fileNoteBook: FileNotebook?
    var networkNoteBook: NetworkNoteBook?
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
        networkNoteBook = NetworkNoteBook()
        notes = (fileNoteBook?.getArrayOfNotes())!
        
        
        
        
//        authoriseOnGitHub()
//        myTableView.isEditing = true
    }
    
    
    func fetchData() {
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueu = OperationQueue()
        
        
        let loadNotesOperation = LoadNotesOperation(notebook: self.fileNoteBook!, networkNoteBook: self.networkNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue, backgroundContext: backgroundContext)
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
        self.myTableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: self.reusableCell)
    }
    
    
    
    
//    private func authoriseOnGitHub() {
//        guard !(self.networkNoteBook?.token.isEmpty)! else {
//            requestToken()
//            return
//        }
//    }
//
//    private func requestToken() {
//        let requestTokenViewController = AuthViewController()
//        requestTokenViewController.delegate = self
//        requestTokenViewController.completion = { [unowned self] in
//
//            let backendQueue = OperationQueue()
//            let dbQueue = OperationQueue()
//            let commonQueu = OperationQueue()
//
//
//            let loadNotesOperation = LoadNotesOperation(notebook: self.fileNoteBook!, networkNoteBook: self.networkNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue)
//            loadNotesOperation.completionBlock = { [unowned self] in
//                DispatchQueue.main.async {
//
//                    if loadNotesOperation.result == "sucsses" || loadNotesOperation.result == "emptyFile" {
//                        // Data from GitHub Gists, if gist is empty then  tableview will be empty too
//                        self.notes = (self.fileNoteBook?.getArrayOfNotes())!
//                        self.myTableView.reloadData()
//                    } else {
//
//                        // Data from local storage
//                        self.notes = (self.fileNoteBook?.getArrayOfNotes())!
//                        self.myTableView.reloadData()
//                    }
//                }
//            }
//            commonQueu.addOperation(loadNotesOperation)
//            DispatchQueue.main.async {
//                self.myTableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: self.reusableCell)
//            }
//        }
//        present(requestTokenViewController, animated: false, completion: nil)
//    }
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
                destination.networkNoteBook = networkNoteBook
                destination.note = self.notes[noteIndex!]
                destination.backgroundContext = self.backgroundContext
                destination.backgroundContextAction = "Update"
            }
        } else {
            if segue.identifier == "toEditScreen" {
                if let destination = segue.destination as? ViewController{
                    destination.networkNoteBook = networkNoteBook
                    destination.fileNoteBook = fileNoteBook
                    destination.backgroundContext = self.backgroundContext
                    destination.backgroundContextAction = "Create"

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
            let backendQueue = OperationQueue()
            let dbQueue = OperationQueue()
            let commonQueue = OperationQueue()
            
            
            myTableView.beginUpdates()
            
            let tempNote = notes[indexPath.row]
            notes.remove(at: indexPath.row)
            fileNoteBook?.remove(with: tempNote.uid)
            myTableView.deleteRows(at: [indexPath], with: .automatic)
            
            myTableView.endUpdates()

            
            let removeNoteOperation = RemoveNoteOperation(note: tempNote, notebook: fileNoteBook!, networkNoteBook: networkNoteBook!, backendQueue: backendQueue, dbQueue: dbQueue, backgroundContext: backgroundContext)
            
            removeNoteOperation.completionBlock = {
                print("Note was DELETED")
            }
            commonQueue.addOperation(removeNoteOperation)
        }
    }
}

extension MyTableViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        self.networkNoteBook!.token = token
    }
}

