//
//  BookRaw.swift
//  SwiftUIMac
//
//  Created by RinoNanase on 2019/12/15.
//  Copyright © 2019 RinoNanase. All rights reserved.
//

import SwiftUI


struct TitleEditTextField : View {
    
    @State var value : String
    var book : Book
            
    var body: some View {
        return TextField("", text: $value)
               .onChange(of: value, perform: { newVal in
                    self.book.title = value
               })
              
        }
}

struct AuthorEditTextField : View {
    
    @State var value : String
    var book : Book
    
    var body: some View {
        return TextField("", text: $value)
               .frame(minWidth:200)
               .onChange(of: value, perform: { newVal in
                    self.book.author = value
               })
        }
}

struct LibraryCellListType: View {
    
    @ObservedObject var viewModel : LibraryViewModel
    @State var isHover = false
    
    @State var field1: String = ""
    @State var field2: String = ""
    
    @State var update : Bool = false
    
    var index : Int
    

    var body: some View {
        
        let count = self.viewModel.orderdBooks.count
        if index < count
        {
                let book = self.viewModel.orderdBooks[index]
                return AnyView(VStack{
                        HStack()
                        {
                            
                            VStack(alignment: .center){
                                Image(nsImage: book.thumbnail).resizable().scaledToFit()
                                HStack()
                                {
                                    ImageButton(name: NSImage.touchBarDeleteTemplateName, sizeW: 16, sizeH:16, label: "", toolTipKey: "DELETE_TOOLTIP", padding:5).onTapGesture
                                    {
                                        self.viewModel.removeSelectedBooks(book)
                                        self.update = !self.update
                                    }.isHidden(!isHover)
                                                                
                                    HeartButton(sizeW: 16, sizeH:16, padding:5, heartOn: book.isFavorite).onTapGesture
                                    {
                                        book.isFavorite = !book.isFavorite
                                        self.update = !self.update
                                    }.isHidden(!isHover)
                                    
                                    ImageButton(name: NSImage.folderName, sizeW: 16, sizeH:16, label: "", toolTipKey:"FOLDER_TOOLTIP" , padding:5).onTapGesture
                                    {
                                           self.viewModel.openFileInFinder(book: book)
                                    }.isHidden(!isHover)
                                    
                                    Text(verbatim:"\(self.update)").isHidden(true)
                                }
                            }
                            .frame(width: 250)
                            .onTapGesture {
                                book.bookWindow.openWindow(book)                                 
                             }
                            .onHover(perform:{ isHover in
                                self.isHover = isHover
                            })
                            VStack(alignment: .leading){
                                HStack
                                {
                                    Text(verbatim: "TITLE".toL + " : ")
                                    MyTextField(currentVal: book.title, onEndEditing: {(currentVal) in
                                        book.title = currentVal
                                    })
                                }
                                HStack
                                {
                                    Text(verbatim: "AUTHOR".toL + " : ")
                                    MyTextField(currentVal: book.author ?? "", onEndEditing: {(currentVal) in
                                        book.author = currentVal
                                    })
                                }
                                
                                Text(verbatim: "CDATE".toL + " : \(dateToString(book.dateCreated))")
                                Text(verbatim: "MDATE".toL + " : \(dateToString(book.dateModified))")

                                if book.type == .kFolder
                                {
                                    Text(verbatim: "TYPE".toL + " : " +  "FOLDER".toL)
                                }
                                else if book.type == .kImageFile
                                {
                                    Text(verbatim: "TYPE".toL + " : " + "IMAGE_FILE".toL)
                                }
                                else if book.type == .kPDF
                                {
                                    Text(verbatim: "TYPE".toL + " : PDF")
                                }
                                
                                HStack{
                                            Text(verbatim: "TAGS".toL + " :")
                                    ImageButton(name: "tag", sizeW: 16, sizeH: 16, label: "", toolTipKey: "TAG_TOOLTIP", padding:5, invertOnDarkMode: true).onTapGesture {
                                                self.viewModel.addTagWindow.runModal(book, allTags: self.viewModel.allTags)
                                                self.update = !self.update
                                            }
                                }
                                HStack{
                                        ForEach(book.tags, id: \.self){tag in
                                            Tag(tag: tag)
                                        }
                                }
                                        
                                Spacer().frame(width : 600, height:10)
                                Text(verbatim: "PATH".toL + " : \(book.url.path)")

                            }
                    }
                    .frame(height: 250)

            })
        }else{
            return AnyView(EmptyView())
        }
    }
}
