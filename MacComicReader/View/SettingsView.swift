//
//  SettingsView.swift
//  MacComicReader
//
//  Created by RinoNanase on 2021/01/03.
//  Copyright © 2021 RinoNanase. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel : SettingsViewModel
    var onClose: (_ name : String) -> Void

    var body: some View {
        VStack{
            HStack{
                Text("MENU_BEHAVIOR".toL + ":")
                Picker("", selection: $viewModel.menuBehavior) {
                    Text("NORMAL".toL).tag(MenuBehavior.Normal.rawValue)
                    Text("SHOWS_ON_MOUSEHOVER".toL).tag(MenuBehavior.ShowsOnMouseHover.rawValue)
                }
            }
        }.padding()
    }
}

