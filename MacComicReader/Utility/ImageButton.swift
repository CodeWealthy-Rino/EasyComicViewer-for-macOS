//
//  ImageButton.swift
//  MacComicReader
//
//  Created by CodeWealthy-Rino on 2019/12/26.
//  Copyright © 2019 CodeWealthy-Rino. All rights reserved.
//

import Foundation
import SwiftUI

struct Tooltip: NSViewRepresentable {
    let tooltip: String
    func makeNSView(context: NSViewRepresentableContext<Tooltip>) -> NSView {
        let view = NSView()
        view.toolTip = tooltip
        return view
    }
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Tooltip>) {
    }
}


struct ImageToggleButton : View
{
    var name : String
    var toolTipKey  : String
    var action : ()->Void
    var invertOnDarkMode : Bool = false

    @Binding var isSelected : Bool
    
    var body: some View {
        Button(action: {
            self.action()
            self.isSelected.toggle()
        }) {
            if invertOnDarkMode
            {
                Image(nsImage:NSImage(named: name)!.invertedIfDarkMode()).resizable().frame(width : 16, height : 16)
            }else{
                Image(nsImage:NSImage(named: name)!).resizable().frame(width : 16, height : 16)
            }
        }
        .frame(height:20)
        .shadow(radius: CGFloat(0.5))
        .border(Color.blue,width: isSelected ? 2 : 0 )
        .buttonStyle(BorderedButtonStyle())
        .help(toolTipKey.toL)
    }
    
}

struct ImageButton2 : View
{
    var name : String
    var action : ()->Void
    var toolTipKey  : String

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(nsImage:NSImage(named: name)!.invertedIfDarkMode()).resizable().frame(width : 16, height : 16)
        }
        .frame(height:20)
        .shadow(radius: CGFloat(0.5))
        .buttonStyle(BorderedButtonStyle())
        .help(toolTipKey.toL)
    }
    
}


struct ImageButton: View {
    
     let name : String
     let sizeW : CGFloat
     let sizeH : CGFloat
     let label : String
     var toolTipKey  : String
     var padding : CGFloat = 40
     var rotation : Double = 0
    var invertOnDarkMode : Bool = false
 
     @State var isHover : Bool = false

      var body: some View {
          VStack{
            if invertOnDarkMode
            {
                Image(nsImage:NSImage(imageLiteralResourceName: name).invertedIfDarkMode()).resizable().frame(width : sizeW, height : sizeH).rotationEffect(Angle(degrees: rotation))
            }else{
                Image(nsImage:NSImage(imageLiteralResourceName: name)).resizable().frame(width : sizeW, height : sizeH).rotationEffect(Angle(degrees: rotation))
            }
            
            if (label as NSString).length > 0
            {
                Text(verbatim: label)
            }
          }
          .frame(width : sizeW + padding, height : sizeH + padding)
          .border(Color.blue,width: isHover ? 2 : 0 )
          .onHover(perform:{ isHover in
             self.isHover = isHover
          })
          .contentShape(Rectangle())
          .help(toolTipKey.toL)
     }
}


struct HeartButton: View {
    
     let sizeW : CGFloat
     let sizeH : CGFloat
     var padding : CGFloat = 40
    var rotation : Double = 0
    let heartOn : Bool
    
     @State var isHover : Bool = false

    var image : NSImage
    {
        heartOn ? NSImage(named:"heart_on")!.invertedIfDarkMode()  : NSImage(named: "heart_off")!.invertedIfDarkMode()
    }
    
      var body: some View {
          VStack{
            Image(nsImage:image).resizable().frame(width : sizeW, height : sizeH).rotationEffect(Angle(degrees: rotation))
          }
          .frame(width : sizeW + padding, height : sizeH + padding)
          .border(Color.blue,width: isHover ? 2 : 0 )
          .onHover(perform:{ isHover in
             self.isHover = isHover
          })
          .contentShape(Rectangle())
          .help("HEART_BUTTON_TOOLTIP".toL)
     }
}
