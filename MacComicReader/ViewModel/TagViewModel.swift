//
//  TagViewModel.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/01/04.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Cocoa

class TagViewModel: ObservableObject {

    @Published var tags : Array<String>
    
    var book : Book
    
    init (book : Book)
    {
        self.tags = book.tags
        self.book = book
    }
    
    func apply()
    {
        self.book.tags = self.tags
    }
    
    func tagExists(_ tagName : String)->Bool
    {
        if let _  =  self.tags.firstIndex(of: tagName)
        {
            return true
        }
        return false
    }
    
    func addTag(_ tagName : String)
    {
        if let _  =  self.tags.firstIndex(of: tagName)
        {
            return // do notrhing
        }
        
         self.tags.append(tagName)
    }
    
    func removeTag(_ tagName: String)
    {
        if let index  =  self.tags.firstIndex(of: tagName)
        {
             self.tags.remove(at: index)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.tags.move(fromOffsets: source, toOffset: destination)
    }
}
