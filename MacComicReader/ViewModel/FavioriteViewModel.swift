//
//  FavioriteViewModel.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/11/08.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import Cocoa

class FavioriteViewModel: ObservableObject {

    var book : Book
    
    init (book : Book)
    {
        self.book = book
    }
    
    func getThumbnail(_ name : String) -> NSImage?
    {
        let images = self.book.allImgs
        for image in images
        {
            if image.fileName == name
            {
                return image.GetThumbnail()
            }
        }
        
        return nil
    }
    

}
