//
//  String+Localize.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2020/10/25.
//  Copyright © 2020 CodeWealthy-Rino. All rights reserved.
//

import Foundation


extension String
{
    
    var toL : String
    {
       return NSLocalizedString(self, comment: "")
    }
    
}

