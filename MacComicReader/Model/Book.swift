//
//  Book.swift
//  SwiftUIMac
//
//  Created by CodeWealthy-Rino on 2019/12/15.
//  Copyright © 2019 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import AppKit
import PDFKit

let charsetNotNumber = CharacterSet(charactersIn: "0123456789").inverted

enum BookType : Int
{
    case kPDF
    case kFolder
    case kImageFile
    case kZIP
}

enum ImgOrder : Int
{
    case kName = 0
    case kCreationDate = 1
    case kModifiedDate = 2
    case kNumber = 3
}

class Book : Identifiable, Hashable, Equatable
{
    let bookWindow = BookWindow()
    let detailViewCon = NSViewController()

    var id : String
    var url : URL
    var name : String
    var isLoadFromBookMark : Bool
    var hashValue2 = UUID().hashValue
    var type : BookType
    var imgOrder : ImgOrder = .kNumber
    {
        didSet
        {
            sortedAllImgs_ = nil
        }
    }
    var tags = Array<String>()
    
    var title : String
    var author : String?
    
    var lastUsedPage : Int?
    var lastUsedDoubleSpread : Bool?
    var lastShowThumbnail : Bool?
    
    var zipExtracted : Bool = false
    
    var isFavorite: Bool
    
    var tempZipFolder : String?
    
    var filePath : String
    {
        let url = self.url as NSURL
        return url.path!
    }
    
    var unzipPath : String?
    
    var favoritePages : Array<String> = []
    
    deinit {
        
        if let tempZipFolder = tempZipFolder
        {
            try? FileManager.default.removeItem(atPath: tempZipFolder)
        }
        
    }
    
    var dateCreated : Date
    {
        var value : AnyObject?
        try? (url as NSURL).getResourceValue(&value, forKey: .creationDateKey)
        
        if let date = value as? Date {
            return date
        }
        return Date()
    }
    
    var dateLastOpend : Date?
    
    var dateRegistered : Date?

    var dateModified : Date
    {
        var value : AnyObject?
        try? (url as NSURL).getResourceValue(&value, forKey: .contentModificationDateKey)
        
        if let date = value as? Date {
            return date
        }
        return Date()
    }
    
    
    var thumbnail : NSImage
    {
        if let first = sortedAllImgs.first
        {
            return first.GetNSImage()
        }
        return NSImage(imageLiteralResourceName: "NoThumbnail")
    }
    
    var soretedFavoritePages: Array<String>
    {
        get
        {
            // sortedAllImagesの順序
            var result = Array<String>()
            
            for bookImg in sortedAllImgs
            {
                if favoritePages.contains(bookImg.fileName)
                {
                    result.append(bookImg.fileName)
                }
            }
            return result
        }
    }
    
    let charsetNotNumber = CharacterSet(charactersIn: "0123456789").inverted
    
    var sortedAllImgs_ : Array<BookImg>?
    
    var sortedAllImgs : Array<BookImg>
    {
        get
        {
            if sortedAllImgs_ == nil
            {
                sortedAllImgs_ = self.allImgs.sorted(by:{  img1, img2 in
                    
                    // Name
                    if imgOrder == .kName
                    {
                        return img1.fileName < img2.fileName
                    }
                    
                    // Number
                    if imgOrder == .kNumber
                    {
                        let fileName1 = img1.numberOnlyfileName
                        let fileName2 = img2.numberOnlyfileName

                        return  Int(fileName1) ?? 0 < Int(fileName2) ?? 0
                    }
            
                    // CreationDate
                    if imgOrder == .kCreationDate
                    {
                        return img1.dateCreated > img2.dateCreated
                    }
                    
                    // ModifidData
                    if imgOrder == .kModifiedDate
                    {
                        return img1.dateModified > img2.dateModified
                    }
                                
                     return img1.fileName < img2.fileName
                })
            }
            return sortedAllImgs_!
        }
    }
    
    var allImgs_ : Array<BookImg>?

    var allImgs : Array<BookImg>
    {
        if allImgs_ == nil
        {
            var results  = Array<BookImg>()
        
            if self.type == .kImageFile
            {
                results.append(URLBookImg(url:self.url))
            }
            
            if self.type == .kPDF
            {
                if let pdf = PDFDocument(url: self.url)
                {
                    for i in 0...pdf.pageCount
                    {
                        if let pdfPage = pdf.page(at: i)
                        {
                            results.append(PDFBookImg(index: i, page: pdfPage))
                        }
                    }
                }
            }
            
            if self.type == .kFolder
            {
                if let enumerator =  FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)
                {
                    for case let url as URL in enumerator
                    {
                        // check this is not directory
                        var value : AnyObject?
                        try? (url as NSURL).getResourceValue(&value, forKey: .isDirectoryKey)
                        if let value = value as? Bool
                        {
                            if value == true
                            {
                                continue
                            }
                        }
                        
                        // check this is image file
                        if checkFileExtImage(url)
                        {
                            results.append(URLBookImg(url: url))
                        }
                    }
                }
            }
            
            if self.type == .kZIP
            {
                if zipExtracted
                {
                    if let tempZipFolder = self.tempZipFolder
                    {
                        if let enumerator =  FileManager.default.enumerator(at: URL(fileURLWithPath: tempZipFolder), includingPropertiesForKeys: nil)
                        {
                            for case let url as URL in enumerator
                            {
                                // check this is not directory
                                var value : AnyObject?
                                try? (url as NSURL).getResourceValue(&value, forKey: .isDirectoryKey)
                                if let value = value as? Bool
                                {
                                    if value == true
                                    {
                                        continue
                                    }
                                }
                                
                                // check this is image file
                                if checkFileExtImage(url)
                                {
                                    results.append(URLBookImg(url: url))
                                }
                            }
                        }
                    }
                }else{
                 
                    results.append(NoThumbnailImg())
                }
            }
            allImgs_ = results
        }
        
        return allImgs_!
    }
    
    func unzipFile(at sourcePath: String, to destinationPath: String) -> Bool {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", sourcePath, "-d", destinationPath]
        process.standardOutput = pipe

        do {
            try process.run()
        } catch {
            return false
        }

        let resultData = pipe.fileHandleForReading.readDataToEndOfFile()
        let result = String (data: resultData, encoding: .utf8) ?? ""
        print(result)

        return process.terminationStatus <= 1
    }
    
    func createTempDirectory() -> String? {
        let tempDirectoryTemplate = NSTemporaryDirectory().appending(UUID().uuidString)

        let fileManager = FileManager.default

        try? fileManager.createDirectory(at: URL(fileURLWithPath: tempDirectoryTemplate),                withIntermediateDirectories: true, attributes: nil)
        return tempDirectoryTemplate
    }
        
    func extractZIP() -> Bool
    {
        if zipExtracted == false
        {
            tempZipFolder = createTempDirectory()
            if unzipFile(at: self.url.path, to: tempZipFolder!)
            {
                zipExtracted = true
                return true
            }
        }
        return false
    }
    
    
    func checkFileExtImage(_ url:URL) -> Bool
    {
        if url.absoluteURL.pathExtension == "jpg" ||
           url.absoluteURL.pathExtension == "jpeg" ||
           url.absoluteURL.pathExtension == "tif" ||
           url.absoluteURL.pathExtension == "pdf" ||
           url.absoluteURL.pathExtension == "bmp" ||
           url.absoluteURL.pathExtension == "png" ||
           url.absoluteURL.pathExtension == "zip"
        {
            return true
        }
        return false
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return self.hashValue2
     }
    
    init(url : URL,
         name : String,
         isLoadFromBookMark : Bool,
         type : BookType,
         imgOrder : ImgOrder,
         tags : Array<String>,
         isFavorite : Bool,
         title : String
        )
    {
        Logger.print("url = \(url) name = \(name) isLoadFromBookMark = \(isLoadFromBookMark)")

        self.url = url
        self.name = name
        self.isLoadFromBookMark = isLoadFromBookMark
        self.id = url.path
        self.type = type
        self.imgOrder = imgOrder
        self.tags = tags
        self.isFavorite =  isFavorite
        
        if self.type == .kPDF
        {
            self.imgOrder = .kNumber
        }
        self.title = title
    }


    func finalize()
    {
        if self.isLoadFromBookMark
        {
            Logger.print("url is \(url) stop Accessing")
            url.stopAccessingSecurityScopedResource()
        }
        
        if let tempZipFolder = tempZipFolder
        {
            try? FileManager.default.removeItem(atPath: tempZipFolder)
        }
    }
    
    static func dateToString(_ date : NSDate)->String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return  formatter.string(from: date as Date)
    }
    
    static func stringToDate(_ str : String)->Date?
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.date(from: str)
    }
    
    func saveBook()
    {
        if let data = try? url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        {
            UserDefaults.standard.set(data, forKey: "\(name)_urlbookmark")
            UserDefaults.standard.set(name, forKey: "\(name)_name")
            UserDefaults.standard.set(type.rawValue, forKey: "\(name)_type")
            UserDefaults.standard.set(imgOrder.rawValue, forKey: "\(name)_order")
            UserDefaults.standard.set(isFavorite, forKey: "\(name)_isFavorite")
            UserDefaults.standard.set(title, forKey: "\(name)_title")
            UserDefaults.standard.set(author, forKey: "\(name)_author")

            if let lastUsedPage = lastUsedPage
            {
                UserDefaults.standard.set(lastUsedPage, forKey: "\(name)_lastUsedPage")
            }
            if let lastUsedDoubleSpread = lastUsedDoubleSpread
            {
                UserDefaults.standard.set(lastUsedDoubleSpread, forKey: "\(name)_lastUsedDoubleSpread")
            }
            
            if let lastShowThumbnail = lastShowThumbnail
            {
                UserDefaults.standard.set(lastShowThumbnail, forKey: "\(name)_lastShowThumbnail")
            }
            
            if let data = try? NSKeyedArchiver.archivedData(withRootObject:  self.tags as? NSArray)
            {
                UserDefaults.standard.set(data, forKey: "\(name)_tagData")
            }
            
            if let data = try? NSKeyedArchiver.archivedData(withRootObject:  self.favoritePages as? NSArray)
            {
                UserDefaults.standard.set(data, forKey: "\(name)_favoritePages")
            }
            
            if let dateLastOpend  = self.dateLastOpend
            {
                UserDefaults.standard.set(Book.dateToString(dateLastOpend as NSDate),
                                          forKey: "\(name)_dateLastOpend")
            }
            
            if let dateRegistered  = self.dateRegistered
            {
                UserDefaults.standard.set(Book.dateToString(dateRegistered as NSDate),
                                          forKey: "\(name)_dateRegistered")
            }
        }
    }
    
    
    static func loadBook(name : String) -> Book?
    {
            if let data = UserDefaults.standard.value(forKey: "\(name)_urlbookmark") as? NSData,
               let name = UserDefaults.standard.value(forKey: "\(name)_name") as? String,
               let type = UserDefaults.standard.value(forKey: "\(name)_type") as? Int,
               let imgOrder = UserDefaults.standard.value(forKey: "\(name)_order") as? Int,
               let tagData = UserDefaults.standard.value(forKey:"\(name)_tagData") as? NSData
            {
                
                let lastUsedPage = UserDefaults.standard.value(forKey:"\(name)_lastUsedPage") as? Int
                let lastUsedDoubleSpread = UserDefaults.standard.value(forKey:"\(name)_lastUsedDoubleSpread") as? Bool
                let lastShowThumbnail = UserDefaults.standard.value(forKey:"\(name)_lastShowThumbnail") as? Bool
                let isFavorite = UserDefaults.standard.value(forKey:"\(name)_isFavorite") as? Bool ?? false
                    
                let favoritePageData = UserDefaults.standard.value(forKey: "\(name)_favoritePages") as! NSData
                
                let dateLastOpend = UserDefaults.standard.value(forKey: "\(name)_dateLastOpend") as? String
                
                let dateRegistered = UserDefaults.standard.value(forKey: "\(name)_dateRegistered") as? String

                let title = UserDefaults.standard.value(forKey: "\(name)_title") as? String
                let author = UserDefaults.standard.value(forKey: "\(name)_author") as? String

                var isStale = false
                if let restoredUrl = try? URL.init(resolvingBookmarkData: data as Data, options:
                                                NSURL.BookmarkResolutionOptions.withSecurityScope,
                                                  relativeTo: nil, bookmarkDataIsStale: &isStale)
                {
                    if (isStale == false)
                    {
                        if restoredUrl.startAccessingSecurityScopedResource()
                        {
                            var  tagArray = Array<String>()
                            if let  unarchivedTags = try? NSKeyedUnarchiver.unarchiveObject(with:tagData as Data) as? NSArray
                            {
                                tagArray = unarchivedTags as! Array<String>
                            }
                            
                            var favoritePages = Array<String>()
                            if let  unarchivedTags = try? NSKeyedUnarchiver.unarchiveObject(with:favoritePageData as Data) as? NSArray
                            {
                                favoritePages = unarchivedTags as! Array<String>
                            }
                            
                            if FileManager.default.fileExists(atPath: restoredUrl.path) == false
                            {
                                return nil
                            }
                            
                            
                            let book = Book(url: restoredUrl,
                                        name: name,
                                        isLoadFromBookMark: true,
                                        type : BookType(rawValue: type) ?? .kFolder,
                                        imgOrder : ImgOrder(rawValue : imgOrder) ?? .kName,
                                        tags: tagArray,
                                        isFavorite:isFavorite,
                                        title: title ?? name
                                        )
                            
                            book.lastUsedDoubleSpread = lastUsedDoubleSpread
                            book.lastUsedPage = lastUsedPage
                            book.lastShowThumbnail = lastShowThumbnail
                            book.favoritePages = favoritePages
                            book.author = author
                            if let dateLastOpend = dateLastOpend
                            {
                                book.dateLastOpend = stringToDate(dateLastOpend) as Date?
                            }
                            if let dateRegistered = dateRegistered
                            {
                                book.dateRegistered = stringToDate(dateRegistered) as Date?
                            }
                            
                            return book
                        }
                    }
                }
        }
        return nil
    }

}
