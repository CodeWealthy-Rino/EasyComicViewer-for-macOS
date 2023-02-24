//
//  String+Localize.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/10/25.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation


extension String
{
    
    var toL : String
    {
       return NSLocalizedString(self, comment: "")
    }
    
}

