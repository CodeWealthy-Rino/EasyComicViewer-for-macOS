//
//  BookInfoView.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/02/22.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import SwiftUI

struct BookInfoView: View {
    
    var book : Book
    @ObservedObject var viewModel : LibraryViewModel
    var onClose: () -> Void
    @State var dummy : Int = 1 // 強引に再描画されるためのDummyState
    
    var body: some View {
            VStack(alignment: .leading){
                    VStack(alignment: .leading)
                    {
                                HStack
                                {
                                    Text(verbatim: "TITLE".toL + " : ")
                                    TitleEditTextField(value: book.title, book: book)
                                }
                                HStack
                                {
                                    Text(verbatim: "AUTHOR".toL + " : ")
                                    AuthorEditTextField(value: book.author ?? "", book: book)
                                }
                        
                                Image(nsImage: book.thumbnail).resizable().scaledToFit().frame(width:200,height:200)
                                Text(verbatim: "CDATE".toL + " : \(dateToString(book.dateCreated))")
                                Text(verbatim: "MDATE".toL + " : \(dateToString(book.dateModified))")

                                if self.book.type == .kFolder
                                {
                                    Text(verbatim: "TYPE".toL + " : " + "FOLDER".toL)
                                }
                                else if self.book.type == .kImageFile
                                {
                                    Text(verbatim: "TYPE".toL + " : " + "IMAGE_FILE".toL)
                                }
                                else if self.book.type == .kPDF
                                {
                                    Text(verbatim: "TYPE".toL + " : PDF")
                                }
                        
                                HStack{
                                    Text(verbatim: "TAGS".toL + " :")
                                    ImageButton(name: "tag", sizeW: 16, sizeH: 16, label: "", toolTipKey: "TAG_TOOLTIP", padding:5, invertOnDarkMode: true).onTapGesture{
                                        self.viewModel.addTagWindow.runModal(self.book, allTags: self.viewModel.allTags)
                                        self.dummy += 1
                                    }
                                    Text(verbatim: "dummy = \(dummy)").hidden().frame(width:0, height:0)
                                }
                                HStack{
                                    ForEach(self.book.tags, id: \.self){tag in
                                        Tag(tag: tag)
                                    }
                                }
                                
                                Spacer().frame(width : 600, height:10)
                                Text(verbatim: "PATH".toL + " : \(self.book.url.path)")
                            }.frame(width : 600, height: 400)
                            HStack
                            {
                                ImageButton(name: NSImage.stopProgressTemplateName, sizeW: 20, sizeH:20, label: "CLOSE".toL, toolTipKey: "CLOSE_TOOLTIP").onTapGesture {
                                    self.onClose()
                                }
                                
                            }.frame(width : 200, height: 50)
                }.padding()
    }
}

