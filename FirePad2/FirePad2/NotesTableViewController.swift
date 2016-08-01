//
//  NotesTableViewController.swift
//  FirePad2
//
//  Created by Jason Chan MBP on 7/19/16.
//  Copyright © 2016 Jason Chan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NotesTableViewController: UITableViewController {
    
    @IBAction func signOut(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBAction func addButton(sender: AnyObject) {
        
        let noteAlert = UIAlertController(title: "New Note", message: "Enter your Note", preferredStyle: .Alert)
        noteAlert.addTextFieldWithConfigurationHandler { (textField:UITextField) in
            textField.placeholder = "Your note"
        }
        noteAlert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action:UIAlertAction) in
            let noteContent = noteAlert.textFields?.first?.text
            if noteContent != "" {
                let userEmail = FIRAuth.auth()?.currentUser?.email
                let note = Note(content: noteContent!, addedByUser: userEmail!)
                
                let noteRef = self.dbRef.child(noteContent!.lowercaseString)
                
                noteRef.setValue(note.toAnyObject())
                
            } else {
                print("no text!")
            }
        }))
        
        self.presentViewController(noteAlert, animated: true, completion: nil)
    }
    
   
    
    var dbRef: FIRDatabaseReference!
    
    var notes = [Note]()
    
    
    func startObservingDB () {
        dbRef.observeEventType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
            var newNotes = [Note]()
            
            for note in snapshot.children {
                let noteObject = Note(snapshot: note as! FIRDataSnapshot)
                newNotes.append(noteObject)
            }
            
            self.notes = newNotes
            self.tableView.reloadData()
            
        }) { (error:NSError) in
            print(error.description)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dbRef = FIRDatabase.database().reference().child("note-items")
        startObservingDB()
        
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user {
                print("Welcome \(user.email)")
                self.startObservingDB()
            }else{
                print("You need to sign up or login first")
            }
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

     let note = notes[indexPath.row]
     
     cell.textLabel?.text = note.content
     cell.detailTextLabel?.text = note.addedByUser
     
     return cell
    }
 

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let note = notes[indexPath.row]
            
            note.itemRef?.removeValue()
        }
    }

}
