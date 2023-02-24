//
//  ContentView.swift
//  MacComicReader
//
//  Created by RinoNanase on 2019/12/16.
//  Copyright © 2019 RinoNanase. All rights reserved.
//

import SwiftUI


struct LibraryView: View, DropDelegate  {
    @ObservedObject var viewModel : LibraryViewModel
    @ObservedObject var mainWidowViewModel : MainWindowViewModel
    
    @ViewBuilder
    var gridView : some View
    {
        let count = self.viewModel.orderdBooks.count
        if count == 0
        {
            List() {
                Spacer()
                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    Text("START_DESCRIPTION".toL).font(.system(size: 20, design: .default))
                    Spacer()
                }
            }.onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
        }else{
            let cols = Int(mainWidowViewModel.windowSizeX / 250)
            let rows = count / cols + 1
                        
            List() {
                ForEach(0..<rows, id: \.self) { i in
                    HStack {
                        ForEach(0..<cols, id: \.self) { j in
                           LibraryCell(viewModel: self.viewModel,
                                       index: j + cols * i,
                                       leftIndex: j,
                                       topIndex: i,
                                       currentCols:cols,
                                       currentRows:rows
                                       )
                        }
                    }
                }
            }.onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
        }
    }
    
    @ViewBuilder
    var listView : some View
    {
        let count = self.viewModel.orderdBooks.count
        
        if count == 0
        {
            List() {
                Spacer()
                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    Text("START_DESCRIPTION".toL).font(.system(size: 20, design: .default))
                    Spacer()
                }
            }.onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
        }else{
            List() {
                ForEach(0..<count, id: \.self) { index in
                    LibraryCellListType(viewModel: self.viewModel,
                                    index: index)
                }
            }.onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
        }
    }
    
    @ViewBuilder
    var libararyGrid : some View
    {
        if viewModel.viewType == ViewType.Grid.rawValue
        {
             self.gridView
        }
        else
        {
             self.listView
        }
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 5) {
                ImageButton(name: NSImage.addTemplateName, sizeW: 20, sizeH: 20, label: "ADD".toL, toolTipKey:"ADD_TOOLTIP").onTapGesture {
                    self.viewModel.addBookWithPanel()
                }
                VStack(alignment:.leading){
                    Text("ORDER".toL)
                    Picker("", selection: $viewModel.order) {
                        Text("NAME".toL).tag(Order.Name.rawValue)
                        Text("AUTHOR".toL).tag(Order.Author.rawValue)
                        Text("ODATE".toL).tag(Order.LastOpend.rawValue)
                        Text("RDATE".toL).tag(Order.LastRegistered.rawValue)
                        Text("CDATE".toL).tag(Order.CreationDate.rawValue)
                        Text("MDATE".toL).tag(Order.ModifiedDate.rawValue)
                        Text("TYPE".toL).tag(Order.BookType.rawValue)
                        Text("TAG".toL).tag(Order.Tag.rawValue)
                        Text("PATH".toL).tag(Order.Path.rawValue)
                    }.offset(x: -10, y: 0)
                    }.frame(width : 140)
                Spacer()
                Picker("", selection: $viewModel.viewType) {
                    Image(nsImage: NSImage(imageLiteralResourceName : NSImage.listViewTemplateName))
                        .tag(0)
                    Image(nsImage: NSImage(imageLiteralResourceName : NSImage.iconViewTemplateName))
                        .tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width:100)
                Spacer()
                Toggle(isOn: $viewModel.showsFavoriteOnly) {
                    Text("SHOWS_FAVORITE_ONLY".toL)
                }
                Spacer()
                Text("SEARCH".toL)
                Combobox(currentValue:  $viewModel.searchString,
                         allTags: viewModel.searchHistory,
                         onEndEditing: {self.viewModel.updateHistory() }
                         ).frame(width:200)
                ImageButton(name: NSImage.advancedName, sizeW: 20, sizeH: 20, label: "Settings".toL, toolTipKey:"SETTINGS_TOOLTIP").onTapGesture {
                    let window = SettingsWindow()
                    window.runModal()
                }
            }
            self.libararyGrid
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {

        let itemProviders = info.itemProviders(for: [(kUTTypeFileURL as String)])

        for itemProvider in itemProviders
        {
            itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) {item, error in
                guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                
                DispatchQueue.main.sync {
                    self.viewModel.addBook(url : url)
                }
            }
        }

        return true
    }
}
