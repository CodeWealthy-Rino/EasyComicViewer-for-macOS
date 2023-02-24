//
//  Tag.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/01/04.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
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
