

import UIKit

class MyTableViewController: UIViewController {

    let reusableCell = "reusableCell"
    var fileNoteBook: FileNotebook?
    var notes = [Note]()
    
    @IBAction func addButtonTap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toEditScreen", sender: nil)
    }
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        fileNoteBook = FileNotebook()
        fileNoteBook?.add(Note(uid: "as", title: "1", content: "asdf", color: .green, importance: .notImportant))
        fileNoteBook?.add(Note(uid: "as1", title: "2", content: "asdf", color: .green, importance: .common))
        fileNoteBook?.add(Note(uid: "as2", title: "3", content: "asdf", color: .white, importance: .important))
        
        for value in (fileNoteBook?.notes.values)! {
            notes.append(value)
        }
        
        myTableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: reusableCell)
//        myTableView.isEditing = true
    }
    
    override func viewDidLayoutSubviews() {
        
    }
}

extension MyTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = myTableView.dequeueReusableCell(withIdentifier: reusableCell, for: indexPath) as! MyTableViewCell
            
            cell.noteTitle.text = notes[indexPath.row].title
            cell.noteContent.text = notes[indexPath.row].content
            cell.noteColor.backgroundColor = notes[indexPath.row].color
            cell.noteColor.layer.borderWidth = 1
            return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
}

