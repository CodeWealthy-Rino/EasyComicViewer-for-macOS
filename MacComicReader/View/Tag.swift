//
//  Tag.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/01/04.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import SwiftUI

struct Tag: View  {
    
    var tag : String
    
    var body: some View
    {
        Text(self.tag)
            .padding(4)
            .foregroundColor(.black)
            .background(Color.green)
            .cornerRadius(5)
            .lineLimit(1)
    }
}
