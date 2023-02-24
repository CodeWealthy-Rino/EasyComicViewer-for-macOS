//
//  FavoriteTagView.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/11/08.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageCall : View
{
    @State var isHover : Bool = false
    var thumbnail : NSImage
    var title : String
    
    var body : some View
    {
        VStack(alignment: .center){
                Image(nsImage: self.thumbnail).resizable().scaledToFit()
                Text(verbatim: self.title)
           }
           .frame(height: 250)
           .border(Color.blue,width: self.isHover ? 2 : 0 )
           .onHover(perform:{ isHover in
               self.isHover = isHover
           })
    }
}

struct FavoriteView: View  {
    
    @ObservedObject var viewModel : FavioriteViewModel
    var onClose: (_ name : String) -> Void

    @State var isHover : Bool = false
    
    var body: some View
    {
        let count = self.viewModel.book.favoritePages.count
        
        return List() {
            ForEach(0..<count, id: \.self) { index in
                ImageCall(thumbnail:        self.viewModel.getThumbnail(self.viewModel.book.soretedFavoritePages[index])!,
                    title:  self.viewModel.book.soretedFavoritePages[index])
                    .onTapGesture {
                        self.onClose(self.viewModel.book.soretedFavoritePages[index])
                    }
            }
        }
    }
}
