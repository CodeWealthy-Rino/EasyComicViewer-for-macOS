//
//  BookImg.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/01/02.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import PDFKit

protocol BookImg   {
    func GetNSImage() -> NSImage
    func GetThumbnail() -> NSImage?
    var fileName : String {get}
    var dateCreated : Date {get}
    var dateModified : Date {get}
    var numberOnlyfileName : String {get}
}

struct PDFBookImg : BookImg
{
    var index : Int
    var page : PDFPage
    
    func GetNSImage() -> NSImage
    {
        guard let dataPage = page.dataRepresentation
        else{
            return NSImage()
        }
                        
        guard let pdfImageRep = NSPDFImageRep(data: dataPage)
        else{
            return NSImage()
        }
    
            
        let size = NSSize(width: pdfImageRep.size.width * 2, height: pdfImageRep.size.height * 2)
        
        let image = NSImage(size: size)
 
        image.lockFocus()
    
        let rect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        NSColor.white.set()
        rect.fill()
    
        pdfImageRep.draw(in: NSMakeRect(0, 0, size.width, size.height))
        
        image.unlockFocus()
                
        return image
    }
    
    func GetThumbnail() -> NSImage?
    {
        let bounds = NSRectFromCGRect(page.bounds(for: .cropBox))
        return page.thumbnail(of: NSMakeSize(bounds.width, bounds.height) , for: .cropBox)
    }
        
    var fileName : String
    {
        "\(index + 1)"
    }
    var numberOnlyfileName : String
    {
        "\(index + 1)"
    }

    var dateCreated : Date
    {
        Date()
    }
    
    var dateModified : Date
    {
        Date()
    }
}

struct NoThumbnailImg : BookImg
{
    func GetNSImage() -> NSImage
     {
         return NSImage(imageLiteralResourceName: "NoThumbnail")
     }
     
     func GetThumbnail() -> NSImage?
     {
        return NSImage(imageLiteralResourceName: "NoThumbnail")
     }
         
     var fileName : String
     {
         return "No Thumbnail"
     }

    var numberOnlyfileName : String
    {
        "1"
    }
    
     var dateCreated : Date
     {
         return Date()
     }
     
     var dateModified : Date
     {
         return Date()
     }
}

class URLBookImg : BookImg
{

    var url : URL
    
    func GetNSImage() -> NSImage
    {
        return NSImage(contentsOf: url)!
    }
    
    init(url : URL)
    {
        self.url = url
    }
    
    deinit {
        print("dealloc")
    }
    
    var _thumbnail : NSImage?
    
    func GetThumbnail() -> NSImage?
    {
        if (_thumbnail == nil)
        {
            if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
                let options: [NSString: NSObject] = [
                    kCGImageSourceThumbnailMaxPixelSize: NSNumber(256),
                    kCGImageSourceCreateThumbnailFromImageAlways: NSNumber(true),
                    kCGImageSourceCreateThumbnailWithTransform: NSNumber(true)
                ]

                if let scaledImage  = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) {
                    _thumbnail = NSImage(cgImage: scaledImage, size: NSMakeSize(256, 256))
                }
            }
        }
        return _thumbnail
    }
        
    var fileName : String
    {
        return url.lastPathComponent
    }

    var _numberOnlyFileName : String? = nil
    
    var numberOnlyfileName : String
    {
        if _numberOnlyFileName == nil
        {
            self._numberOnlyFileName = fileName.trimmingCharacters(in: charsetNotNumber)
        }
        return _numberOnlyFileName!
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
    
    var dateModified : Date
    {
        var value : AnyObject?
        try? (url as NSURL).getResourceValue(&value, forKey: .contentModificationDateKey)
        
        if let date = value as? Date {
            return date
        }
        return Date()
    }
}
