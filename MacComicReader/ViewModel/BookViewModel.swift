//
//  BookViewModel.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/01/06.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import AppKit
import ImageIO

struct ThumbnailInfo : Hashable
{
    var bookImage: BookImg
    
    static func == (lhs: ThumbnailInfo, rhs: ThumbnailInfo) -> Bool {
        return lhs.bookImage.fileName == rhs.bookImage.fileName
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(bookImage.fileName)
    }
}

class BookViewModel: ObservableObject {
    
    var book : Book
    
    var settings = Settings()
    
    @Published var scale: CGFloat = 100
    @Published var degree : Double = 0
    @Published var showTopToolBar : Bool = true
    @Published var showBottomToolBar : Bool = true
    
    @Published var order  = ImgOrder.kName.rawValue
    {
        didSet
        {
            fileNameCache_ = nil
            self.book.imgOrder = ImgOrder(rawValue:order)!
        }
    }
    
    @Published var requestScroll : Bool = false
    
    @Published var page : Int = 1
    {
        didSet
        {
            if self.page <= self.sortedAllThumbnailInfo.count && self.updateThumbnail
            {
                self.selected = self.sortedAllThumbnailInfo[self.page - 1]
            }
            self.book.lastUsedPage = self.page
        }
    }
    @Published var doubleSpread : Bool = true
    {
        didSet
        {
            self.book.lastUsedDoubleSpread = self.doubleSpread
        }
    }
    
    @Published var showThumbnail : Bool = false
    {
        didSet
        {
            self.book.lastShowThumbnail = self.showThumbnail
        }
    }
    
    @Published var selected :ThumbnailInfo?
    {
        didSet
        {
            if let selected = self.selected
            {
                if let page = self.sortedAllThumbnailInfo.firstIndex(of: selected)
                {
                    updateThumbnail = false
                    self.page = page + 1
                    updateThumbnail = true
                }
                
            }
        }
    }
    
    @Published var favoritePages : Array<String> = []

    @Published var loadingThumbnails = false
    
    var thumbnailCreationCount = 0
    
    deinit
    {
        print("deallocated")
    }
    
    var isFavoritePage : Bool
    {
        set
        {
            if newValue == true
            {
                self.favoritePages.append(fileNames[self.page - 1])
                self.book.favoritePages = self.favoritePages
            }
            else{
                if let index = self.favoritePages.lastIndex(of: fileNames[self.page - 1])
                {
                    self.favoritePages.remove(at: index)
                    self.book.favoritePages = self.favoritePages
                }
            }
        }
        
        get
        {
            return self.favoritePages.contains(fileNames[self.page - 1])
        }
    }
    
    var updateThumbnail = true

    var currentPageUrl : URL?
    
    //fileprivate var _thumbnails : Array<NSImage>?
    
    
    var viewDoubleImg : Bool
    {
        if doubleSpread
        {
            if  self.page + 1 <= self.pages
            {
                return true
            }
        }
        
        return false
    }
    
    var sortedAllThumbnailInfo : Array<ThumbnailInfo>
    {
        var results = Array<ThumbnailInfo>()
        for image in self.book.sortedAllImgs
        {
            results.append(ThumbnailInfo(bookImage: image))
        }
        return results
    }
    
    /*
    var thumbnails : Array<NSImage>
    {
        if _thumbnails == nil
        {
             _thumbnails = Array<NSImage>()
            DispatchQueue.global().async {
                DispatchQueue.main.sync {
                    self.loadingThumbnails = true
                }
                for val in 1...self.pages
                {
                    if let thumbnail  = self.book.sortedAllImgs[val - 1].GetThumbnail()
                    {
                        self._thumbnails!.append(thumbnail)
                    }
                }
                DispatchQueue.main.sync {
                    self.loadingThumbnails = false
                }
            }
        }
        return _thumbnails!
    }
     */
    
    var fileNameCache_ : Array<String>?
    
    var fileNames : Array<String>
    {

        if fileNameCache_ != nil
        {
            return fileNameCache_!
        }
        
        var array = Array<String>()
        
        let images = self.book.sortedAllImgs
        for val in 1...self.pages
        {
            array.append(images[val - 1].fileName)
        }
        
        if fileNameCache_ == nil
        {
            fileNameCache_ = array
        }
        
        return array
    }
    
    var currentPage : NSImage
    {
        return imageAt(self.page).0
    }
    
    func selectImageByName(_ inName : String)
    {
        var i = 1
        for name in fileNames
        {
            if name == inName
            {
                self.page = i
            }
            i+=1
        }
    }
    

    func imageAt(_ page:Int)->(NSImage, String)
    {
        if page - 1 < self.book.sortedAllImgs.count && page - 1 >= 0
        {
            let first = self.book.sortedAllImgs[page - 1]
            
            if viewDoubleImg == false
            {
                return (first.GetNSImage(), first.fileName)
            }
            else{
                let second = self.book.sortedAllImgs[page]
                let stitchedImg = stitchImage(second.GetNSImage(), first.GetNSImage())
                return (stitchedImg, "a_a")
            }
        }
        return (NSImage(imageLiteralResourceName: "NoThumbnail"), "")
    }
    
    var pages : Int
    {
        return  self.book.sortedAllImgs.count
    }
    
    
    init (book : Book)
    {
        self.book = book
        self.order = book.imgOrder.rawValue
        if let doubleSpread = self.book.lastUsedDoubleSpread
        {
            self.doubleSpread = doubleSpread
        }
        if let showThumbnail = self.book.lastShowThumbnail
        {
              self.showThumbnail = showThumbnail
        }
        if let page = self.book.lastUsedPage
        {
            if page <= self.pages
            {
                self.page = page
            }
        }
        self.favoritePages = self.book.favoritePages
        
        if settings.menuBehavior == .ShowsOnMouseHover
        {
            self.showTopToolBar = false
            self.showBottomToolBar = false
        }
    }
    
    func stitchImage(_ first: NSImage, _ second : NSImage) -> NSImage
    {
        let newSize = NSMakeSize(first.size.width + second.size.width,  max(first.size.height, second.size.height))
        let newImage = NSImage(size: newSize)
        
        newImage.lockFocus()
        
        first.draw(in: NSMakeRect(0, 0, first.size.width, first.size.height))
        second.draw(in: NSMakeRect(first.size.width, 0, second.size.width, second.size.height))

        
        newImage.unlockFocus()
            
        return newImage
    }
    
    
    func nextPage()
    {
        if viewDoubleImg
        {
            if page + 1 < self.book.sortedAllImgs.count
            {
                page = page + 2
            }
        }else{
            if page < self.book.sortedAllImgs.count
            {
                page = page + 1
            }
        }
        self.requestScroll = !self.requestScroll
    }
    
    func backPage()
    {
        if viewDoubleImg
        {
            if page - 1 > 1
            {
                page = page - 2
            }
        }else{
            if page > 1
            {
                page = page - 1
            }
        }
        self.requestScroll = !self.requestScroll
    }
    
}
