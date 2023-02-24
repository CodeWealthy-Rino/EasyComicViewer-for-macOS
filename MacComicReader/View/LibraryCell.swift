//
//  BookRaw.swift
//  SwiftUIMac
//
//  Created by CodeWealthy-Rino on 2019/12/15.
//  Copyright © 2019 CodeWealthy-Rino. All rights reserved.
//

import SwiftUI


struct LibraryCell: View {
    
    @ObservedObject var viewModel : LibraryViewModel
    @State var isHover = false
    
    @State var field1: String = ""
    @State var field2: String = ""
    
    @State var update : Bool = false
    
    var index : Int
    var leftIndex: Int
    var topIndex: Int
    var currentCols : Int
    var currentRows : Int
    

    var body: some View {
        
        let count = self.viewModel.orderdBooks.count
        if index < count
        {
                let book = self.viewModel.orderdBooks[index]
                return AnyView(VStack{
                        HStack()
                        {
                            
                            VStack(alignment: .leading){
                                Image(nsImage: book.thumbnail).resizable().scaledToFit()
                                MyTextField(currentVal: book.title, onEndEditing: {(currentVal) in
                                    book.title = currentVal
                                }).multilineTextAlignment(.center)
                                
                                HStack(alignment: .center)
                                {
                                    
                                    ImageButton(name:NSImage.infoName, sizeW: 16, sizeH:16, label: "", toolTipKey: "DETAIL_TOOLTIP", padding:5, invertOnDarkMode: false).onTapGesture
                                    {
                                        book.detailViewCon.view = NSHostingView(rootView:
                                        BookInfoView(book:book, viewModel: self.viewModel, onClose:{ () -> Void in
                                                    let delegate = (NSApplication.shared.delegate) as! AppDelegate
                                                    delegate.mainWindowController.dismiss(book.detailViewCon)
                                        }))
                                        
                                        let delegate = (NSApplication.shared.delegate) as! AppDelegate
                                        delegate.mainWindowController.presentAsSheet(book.detailViewCon)
                                    }.isHidden(!isHover)
                                    
                                    ImageButton(name: NSImage.touchBarDeleteTemplateName, sizeW: 16, sizeH:16, label: "", toolTipKey: "DELETE_TOOLTIP", padding:5).onTapGesture
                                    {
                                        self.viewModel.removeSelectedBooks(book)
                                    }.isHidden(!isHover)
                                        
                                    HeartButton(sizeW: 16, sizeH:16, padding:5, heartOn: book.isFavorite).onTapGesture
                                    {
                                        book.isFavorite = !book.isFavorite
                                        self.update = !self.update
                                    }.isHidden(!isHover)

                                    ImageButton(name: NSImage.folderName, sizeW: 16, sizeH:16, label: "", toolTipKey: "FOLDER_TOOLTIP", padding:5).onTapGesture
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
                    }
                    .frame(height: 250)

            })
        }else{
            return AnyView(EmptyView())
        }
    }
}
