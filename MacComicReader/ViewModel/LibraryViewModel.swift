//
//  BookMarkViewModel.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2019/12/19.
//  Copyright © 2019 CodeWealthy-Rino. All rights reserved.
//

import Cocoa



enum Order : Int
{
    case Name = 0
    case CreationDate = 1
    case ModifiedDate = 2
    case BookType = 3
    case Tag = 4
    case Path = 5
    case LastOpend = 6
    case LastRegistered = 7
    case Author = 8
}

enum ViewType : Int
{
    case List = 0
    case Grid = 1
}

class LibraryViewModel : ObservableObject {

    @Published var order = Order.Name.rawValue
    @Published var books = Array<Book>()
    @Published var selected : Book?
    @Published var selectedLeftIndex: Int?
    @Published var selectedTopIndex : Int?
    @Published var currentRows : Int?
    @Published var currentCols : Int?
    @Published var searchString : String = ""
    @Published var showsFavoriteOnly : Bool = false
    @Published var viewType = ViewType.List.rawValue
   
    let addTagWindow = EditTagWindow()
    
    func updateHistory()
    {
        if searchString != "" &&
           searchHistory.first != searchString
        {
            searchHistory.insert(self.searchString, at: 0)
        }
    }
    
    var searchHistory : Array<String>
    {
        get{
            UserDefaults.standard.value(forKey: "searchHistory") as? Array<String> ?? Array<String>()
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "searchHistory")
        }
    }
    
    func gotoRight()
    {
        if let selectedLeftIndex = selectedLeftIndex,
           let selectedTopIndex = selectedTopIndex,
           let currentRows = currentRows,
           let currentCols = currentCols
        {
            
            if selectedLeftIndex < currentCols - 1
            {
                // goto right
                self.selectedLeftIndex = selectedLeftIndex + 1
            }else{
                if  selectedTopIndex < currentRows - 1
                {
                    //goto Next
                    self.selectedLeftIndex = 0
                    self.selectedTopIndex = selectedTopIndex + 1
                }
            }
            
            updateSelected()
        }
    }
    
    func gotoLeft()
    {
        if let selectedLeftIndex = selectedLeftIndex,
           let selectedTopIndex = selectedTopIndex
        {
            
            if selectedLeftIndex > 0
            {
                // goto left
                self.selectedLeftIndex = selectedLeftIndex - 1
            }else{
                //goto back
                if  selectedTopIndex > 0
                {
                    self.selectedLeftIndex = (currentCols! - 1)
                    self.selectedTopIndex = selectedTopIndex - 1
                }
            }
            
            updateSelected()
        }
    }
    
    func updateSelected()
    {
        if let selectedLeftIndex = selectedLeftIndex,
           let selectedTopIndex = selectedTopIndex,
           let cols = currentCols
        {
            if selectedTopIndex * cols + selectedLeftIndex  < self.orderdBooks.count
            {
                self.selected = self.orderdBooks[selectedTopIndex * cols + selectedLeftIndex]
            }
        }
    }
    
    var allTags : Array<String>
    {
        var allTags = Array<String>()
        
        for book in books
        {
            allTags.append(contentsOf: book.tags)
        }
        
        return Array(Set(allTags))
    }
    
    func filterFavorite(_ books : Array<Book>) -> Array<Book>
    {
        if showsFavoriteOnly == false
        {
            return books
        }
        
        var newBook = Array<Book>()

        for book in books
        {
            if book.isFavorite
            {
                newBook.append(book)
            }
        }
    
        return newBook
    }
    
    var filterdBooks : Array<Book>
    {
        if self.searchString == ""
        {
            return filterFavorite(self.books)
        }
     
        var newBook = Array<Book>()
        
        for book in self.books
        {
            if book.name.contains(self.searchString) ||
                book.title.contains(self.searchString) ||
                (book.author ?? "").contains(self.searchString) ||
                book.dateCreated.description.contains(self.searchString) ||
                book.dateModified.description.contains(self.searchString) ||
                book.tags.description.contains(self.searchString)
            {
                newBook.append(book)
            }
        }
                
        return filterFavorite(newBook)
    }
    
    var orderdBooks : Array<Book>
    {
        get
        {
            return filterdBooks.sorted {  book1, book2 in
                
                // Name
                if order == Order.Name.rawValue
                {
                    return book1.title.localizedCaseInsensitiveCompare(book2.title) == .orderedAscending
                }
                
                // Name
                if order == Order.Author.rawValue
                {
                    return (book1.author ?? "").caseInsensitiveCompare(book2.author ?? "") == .orderedAscending
                }
                
                // CreationDate
                if order == Order.CreationDate.rawValue
                {
                    return book1.dateCreated > book2.dateCreated
                }
                
                // ModifidData
                if order == Order.ModifiedDate.rawValue
                {
                    return book1.dateModified > book2.dateModified
                }
                
                // BookType
                if order == Order.BookType.rawValue
                {
                    return book1.type.rawValue  > book2.type.rawValue
                }
                
                // Path
                if order == Order.Path.rawValue
                {
                    return book1.url.path > book2.url.path
                }
                
                // CreationDate
                if order == Order.LastOpend.rawValue
                {
                    var book1Date = book1.dateLastOpend
                    if book1Date == nil
                    {
                        book1Date = book1.dateRegistered
                    }
                    if book1Date == nil
                    {
                        book1Date = book1.dateCreated
                    }
                    var book2Date = book2.dateLastOpend
                    if book2Date == nil
                    {
                        book2Date = book2.dateRegistered
                    }
                    if book2Date == nil
                    {
                        book2Date = book2.dateCreated
                    }
                    
                    return book1Date! > book2Date!
                }
                
                // Last Registerd
                if order == Order.LastRegistered.rawValue
                {
                    var book1Date = book1.dateRegistered
                    if book1Date == nil
                    {
                        book1Date = book1.dateCreated
                    }
                    var book2Date = book2.dateRegistered
                    if book2Date == nil
                    {
                        book2Date = book2.dateCreated
                    }
                    return book1Date! > book2Date!
                }
                
                 return book1.name > book2.name
            }
        }
    }
    
        
    func addBookWithPanel()
    {
        if let mainWindow = NSApp.mainWindow
        {
              let openPanel = NSOpenPanel()
              openPanel.canChooseFiles = true
              openPanel.allowsMultipleSelection = false
              openPanel.canChooseDirectories = true
              openPanel.title = "Choose folder or image"

             openPanel.beginSheetModal(for: mainWindow) { (response) in
                  if response == .OK {
                    if let url = openPanel.url
                    {
                        self.addBook(url: url)
                    }
                  }
                  openPanel.close()
              }
        }
    }
    
    func addBook(url : URL)
    {
            
        if let type = self.checkDraggedFile(url: url)
        {
            // Duplicate check
            let fileName = self.getFileName(url:url)
            if let bookNames = UserDefaults.standard.value(forKey: "bookNames") as? Array<String>
            {
                for bookName in bookNames
                {
                    if fileName == bookName
                    {
                        let _ = dialogOK("DUPLICATE_FILE_NAME_ERROR".toL)
                        return
                    }
                }
            }
            
            
            // if same one already exists, do nothing
            if let book = checkExists(url:url)
            {
                self.selected = book
            }else{
                self.addBook(book:Book(url: url,
                                       name: self.getFileName(url:url),
                                       isLoadFromBookMark: false,
                                       type: type,
                                       imgOrder: .kNumber,
                                       tags : Array<String>(),
                                       isFavorite: false,
                                       title:self.getFileName(url:url)
                                       ))
            }
        }
    }
    
    init()
    {
        if let bookNames = UserDefaults.standard.value(forKey: "bookNames") as? Array<String>
        {
            for bookName in bookNames
            {
                if let book = Book.loadBook(name: bookName)
                {
                    addBook(book:book)
                }
            }
        }
        
        if let order = UserDefaults.standard.value(forKey: "order") as? Int
        {
            self.order = order
        }else
        {
            self.order = Order.Name.rawValue
        }
        
        if let showsFavoriteOnly = UserDefaults.standard.value(forKey: "showsFavoriteOnly") as? Bool
        {
            self.showsFavoriteOnly = showsFavoriteOnly
        }else{
            self.showsFavoriteOnly = false
        }
    }
    
    deinit {
        print("dealloc")
    }
    
    func save() {
        var bookNames = Array<String>()
        for book in books
        {
            bookNames.append(book.name)
            book.saveBook()
        }
        UserDefaults.standard.setValue(bookNames, forKey:"bookNames")
        
        UserDefaults.standard.setValue(self.order, forKey: "order")
        UserDefaults.standard.setValue(self.showsFavoriteOnly, forKey: "showsFavoriteOnly")
    }
    
    func finalize() {
        for book in books
        {
            book.finalize()
        }
    }
    
    func checkExists(url : URL) -> Book?
    {
        for book in self.books
        {
            if book.url == url
            {
                return book
            }
        }
        return nil
    }
    
    func removeSelectedBooks(_ book : Book)
    {
        if dialogOKCancel(question: "MESSAGE_DELETE_CONFIRM".toL, text: "")
        {
            removeBook(book: book)
        }
    }
    
    func openFileInFinder(book : Book)
    {
        if book.type == .kFolder
        {
            NSWorkspace.shared.open(book.url)
        }else{
                    
            NSWorkspace.shared.selectFile(book.filePath, inFileViewerRootedAtPath: "")
            
        }
    }
    
    fileprivate func removeBook(book : Book)
    {
        if let index = self.books.firstIndex(of: book)
        {
            self.books.remove(at: index)
        }
    }
    
    fileprivate func addBook(book : Book)
    {
        book.dateRegistered = Date()
        self.books.append(book)
    }
    
    fileprivate func checkDraggedFile(url : URL) -> BookType?
    {
        // is Folder
        var isFolder : ObjCBool = false
        
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isFolder)
        {
            if isFolder.boolValue
            {
                return .kFolder
            }
        }
        
        if let _ = CGPDFDocument(NSURL(string: url.absoluteString)!)
        {
            return .kPDF
        }
        
        // is image file
        if let _ = NSImage(contentsOf: url)
        {
            return .kImageFile
        }
        
        if url.absoluteString.hasSuffix(".zip")
        {
            return .kZIP
        }
                        
        return nil
    }
    
    fileprivate func getFileName(url : URL) -> String
    {
        return (url.lastPathComponent as NSString) as String
    }
}
