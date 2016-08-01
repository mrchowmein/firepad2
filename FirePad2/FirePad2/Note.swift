//
//  Note.swift
//  FirePad2
//
//  Created by Jason Chan MBP on 7/19/16.
//  Copyright © 2016 Jason Chan. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Note {
    
    let key:String!
    let content:String!
    let addedByUser:String!
    let itemRef:FIRDatabaseReference?
    
    init (content:String, addedByUser:String, key:String = "") {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
    }
    
    init (snapshot:FIRDataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        if let noteContent = snapshot.value!["content"] as? String {
            content = noteContent
        }else {
            content = ""
        }
        
        if let noteUser = snapshot.value!["addedByUser"] as? String {
            addedByUser = noteUser
        }else {
            addedByUser = ""
        }
        
    }
    
    func toAnyObject() -> AnyObject {
        return ["content":content, "addedByUser":addedByUser]
    }
    
}