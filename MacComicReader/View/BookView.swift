//
//  BookView.swift
//  MacComicReader
//
//  Created by RinoNanase on 2020/01/06.
//  Copyright © 2020 RinoNanase. All rights reserved.
//

import Foundation
import Foundation
import SwiftUI
import Combine

extension Int {
    var double: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}

final class AppKitTouchesView: NSView {

    var onChangeWheel : ((Double)->Void)?
    var onChangeMagnify : ((Double)->Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override var acceptsFirstResponder: Bool
    {
        return true
    }
    
    override func scrollWheel(with event: NSEvent)
    {
        print("scrollWheel  \(event.scrollingDeltaX)")
        onChangeWheel?(Double(event.scrollingDeltaX))
    }

    override func magnify(with event: NSEvent)
    {
        print("magnify ", event.magnification)
        onChangeMagnify?(Double(event.magnification))
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


struct TouchesView: NSViewRepresentable {

    //@State var scrollDelta : Double
    //@State var magnify : Double
    
    fileprivate let didChangeWheel = PassthroughSubject<Double, Never>()
    fileprivate let didChangeMagnify = PassthroughSubject<Double, Never>()

    
    func updateNSView(_ nsView: AppKitTouchesView, context: Context) {
        
        context.coordinator.parent = self
    }

    func makeNSView(context: Context) -> AppKitTouchesView {
        let view = AppKitTouchesView()
        view.onChangeWheel = {(value) in
            context.coordinator.changedWheel(value: value)
        }
        view.onChangeMagnify = {(value) in
            context.coordinator.changedMagnify(value: value)
        }
        return view
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: TouchesView

        var didReport = false
        
        init(_ view: TouchesView) {
            self.parent = view
        }
        
        @objc func timerUpdate() {

        }
        
        func changedMagnify(value : Double)
        {
            parent.didChangeMagnify.send(value)
        }
        
        func changedWheel(value : Double)
        {
            if (value > 0.3 || value < -0.3 )
            {
                if didReport == false
                {
                    print("didChangeWheel")
                    didReport = true
                    parent.didChangeWheel.send(value)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.didReport = false
                    }
                }
            }

        }
        
    }
    
    
    /// Call actions when each events occur.
    func onEvent(onChangeWheel: ((Double) -> Void)? = nil, onChangeMagnify: ((Double) -> Void)? = nil) -> some View {
        return onReceive(didChangeWheel) {(value) in
            onChangeWheel?(value)
        }
        .onReceive(didChangeMagnify) {(value) in
            onChangeMagnify?(value)
        }
    }
}
struct BookMainView: View
{
    @Binding var scale : CGFloat
    @Binding var degree : Double
    
    var image : NSImage
    
    fileprivate let didPressNext = PassthroughSubject<Void, Never>()
    fileprivate let didPressBack = PassthroughSubject<Void, Never>()

    var body : some View
    {
        ZStack{
            GeometryReader { geometry in
            ScrollView ([.horizontal, .vertical],showsIndicators:true) {
                VStack {
                    Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                }
                .frame(width:CGFloat(geometry.size.width * self.scale / 100),
                       height:CGFloat(geometry.size.height * self.scale / 100))
                .rotationEffect(.degrees(self.degree))
                .animation(.easeOut)
            }.gesture(
                MagnificationGesture()
                .onChanged { value in
                    var currentVal = value.magnitude * 100
                    if (currentVal < 100)
                    {
                        currentVal = 100
                    }
                    self.scale = currentVal
                }
             ).onTapGesture {
                self.didPressNext.send()
             }
            .contextMenu {
                Button(action: {
                    self.didPressNext.send()
                }) {
                    Text("NEXT".toL)
                }

                Button(action: {
                    self.didPressBack.send()
                }) {
                    Text("BACK".toL)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if self.scale == 100
            {
                TouchesView()
                .onEvent(onChangeWheel: {(value) in
                    print(value)
                    if self.scale <= 100
                    {
                        if (value < -0.3)
                        {
                            self.didPressNext.send()
                        }
                        if (value > 0.3){
                            self.didPressBack.send()
                        }
                    }
                }, onChangeMagnify: {(value)  in
                    print("magnify   \(value) \(self.scale)")
                    var currentVal = self.scale +  CGFloat(value) * 20
                    if (currentVal < 100)
                    {
                        currentVal = 100
                    }
                    self.scale = currentVal
                })
                .onTapGesture {
                        self.didPressNext.send()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    func onEvent(onPressNext: (() -> Void)? = nil,
                 onPressBack: (() -> Void)? = nil) -> some View {
        return onReceive(didPressNext) {
            onPressNext?()
        }
        .onReceive(didPressBack) {
            onPressBack?()
        }
    }
}

struct Thumbnail : View {
    
    var bookImage : BookImg
    var index : Int
    var thumbailCreateQueue : OperationQueue
        
    @State var thumbnail = NSImage()
    var viewModel : BookViewModel
    var scrollViewProxy : ScrollViewProxy
    
    var body: some View
    {
        if thumbnail.size.width == 0
        {
            thumbailCreateQueue.addOperation {
                let mythumbnail = bookImage.GetThumbnail()
                DispatchQueue.main.sync {
                    self.thumbnail = mythumbnail ?? NSImage()
                    self.viewModel.thumbnailCreationCount += 1
                    // thumbnail creation complete
                    if (self.viewModel.thumbnailCreationCount == self.viewModel.pages)
                    {
                        scrollViewProxy.scrollTo(self.viewModel.page, anchor: .center)
                    }
                }
            }
        }
        
        return
            VStack(alignment: .center){
                Image(nsImage: thumbnail).resizable().scaledToFit()
                Text(bookImage.fileName)
            }.frame(minWidth: 100, idealWidth:100 , maxWidth:200)
            .onAppear(perform: {
            })
    }
}

let thumbailCreateQueue = OperationQueue()

struct BookView: View  {

    @ObservedObject var viewModel : BookViewModel
        
    @State var scale : CGFloat = 100
    @State var degree : Double = 0
    
    let thumbailCreateQueue : OperationQueue

    var body: some View
    {
        let sldierValue = Binding(
             get: {
                    self.viewModel.pages.double -  self.viewModel.page.double + 1
            },
             set: {
                self.viewModel.page = Int(self.viewModel.pages.double - $0 + 1)
            }
         )
         return
            VStack {
            HStack(alignment: .center){
                if self.viewModel.showTopToolBar
                {
                        Text("ORDER".toL).isHidden(self.viewModel.book.type != .kFolder)
                        VStack(alignment:.leading){
                              Picker("", selection: $viewModel.order) {
                                  Text("NAME".toL).tag(ImgOrder.kName.rawValue)
                                  Text("NUMBER".toL).tag(ImgOrder.kNumber .rawValue)
                                  Text("CDATE".toL).tag(ImgOrder.kCreationDate.rawValue)
                                  Text("MDATE".toL).tag(ImgOrder.kModifiedDate.rawValue)
                              }.offset(x: -10, y: 0)
                        }.frame(width : self.viewModel.book.type == .kFolder ? 140 : 0).isHidden(self.viewModel.book.type != .kFolder)
                        
                                        
                        ImageButton2(name: "rotate", action: {
                            self.degree += 90
                        }, toolTipKey: "ROTATE_TOOLTIP")
                    
                        ImageButton2(name: "zoom-in", action: {
                            self.scale += 30
                        }, toolTipKey: "ZOOMIN_TOOLTIP")
                    
                        ImageButton2(name: "zoom-out", action: {
                            
                            var currentVal = self.viewModel.scale
                            currentVal -= 30
                            if (currentVal < 100)
                            {
                                currentVal = 100
                            }
                            self.scale = currentVal
                        }, toolTipKey: "ZOOMOUT_TOOLTIP")
                    
                        ImageButton2(name: "fit-to-page", action: {
                            self.scale = 100
                        }, toolTipKey: "FIT_TO_PAGE_TOOLTIP")
                    
                    ImageToggleButton(name: NSImage.bookmarksTemplateName,
                                      toolTipKey: "DOUBLE_SPREAD_TOOLTIP" ,
                                      action: {},
                                      isSelected: $viewModel.doubleSpread)
                    ImageToggleButton(name: "thumbnail",
                                      toolTipKey: "SHOW_THUMBNAIL_TOOLTIP",
                                      action: {},
                                      invertOnDarkMode : true,
                                      isSelected: $viewModel.showThumbnail
                                      )
                                        
                    HeartButton(sizeW: 16, sizeH:16, padding:5, heartOn: self.viewModel.isFavoritePage).onTapGesture
                    {
                        self.viewModel.isFavoritePage = !self.viewModel.isFavoritePage
                    }
                    Button(action: {
                        let window = FavoriteWindow()
                        if window.runModal(self.viewModel.book)  == .OK
                        {
                            self.viewModel.selectImageByName(window.returnVal)
                            self.viewModel.requestScroll = !self.viewModel.requestScroll
                        }
                    }, label: {
                        Text("VIEW_FAVORITE".toL)
                    })
                    }
                    Text("LOAD_THUMB".toL)
                    .isHidden(!self.viewModel.loadingThumbnails)
                    .frame(height:self.viewModel.loadingThumbnails ? 10 : 0)
                }
                .background(isDarkMode() ? Color.black : Color.white)
                .opacity(0.7)
                .frame(width:900, height:self.viewModel.showTopToolBar ? CGFloat(25.0) : CGFloat(10.0))
                .contentShape(Rectangle())
                .onHover(perform: { isHover in
                    if self.viewModel.settings.menuBehavior == .ShowsOnMouseHover
                    {
                        if isHover
                        {
                            self.viewModel.showTopToolBar = true
                        }else{
                            self.viewModel.showTopToolBar = false
                        }
                    }
                })
                
            if self.viewModel.showThumbnail
            {
                let thumbnailIndex = self.viewModel.sortedAllThumbnailInfo.enumerated().map({ $0 })
                                
                NavigationView{
                    ScrollView {
                        ScrollViewReader { (proxy: ScrollViewProxy) in
                            ForEach(thumbnailIndex , id: \.element) {index,  thumbnailInfo in
                                Thumbnail(bookImage: thumbnailInfo.bookImage,
                                          index:index,
                                          thumbailCreateQueue:thumbailCreateQueue,
                                          viewModel:viewModel,
                                          scrollViewProxy:proxy
                                          )
                                .padding()
                                .id(index + 1)
                                .border(Color.blue,width: thumbnailInfo == self.viewModel.selected ? 2 : 0 )
                                .onTapGesture {
                                    self.viewModel.selected = thumbnailInfo
                                }
                            }.onChange(of: self.viewModel.requestScroll, perform: {(value) in
                                withAnimation {
                                    proxy.scrollTo(self.viewModel.page, anchor: .center)
                                }
                            })
                        }
                    }.frame(minWidth: 100, idealWidth:100 , maxWidth:200)
                    BookMainView(scale:$scale, degree:$degree, image: self.viewModel.currentPage).onEvent(
                    onPressNext: {
                        self.viewModel.nextPage()
                    }, onPressBack: {
                        self.viewModel.backPage()
                    })
                }.navigationViewStyle(DoubleColumnNavigationViewStyle())
            }
            else
            {
                BookMainView(scale:$scale, degree:$degree, image: self.viewModel.currentPage).onEvent(
                onPressNext: {
                    self.viewModel.nextPage()
                }, onPressBack: {
                    self.viewModel.backPage()
                })
            }
            HStack(alignment: .center){
                if self.viewModel.showBottomToolBar
                {
                        if viewModel.pages > 1
                        {
                            Slider(value: sldierValue, in: 1.0...viewModel.pages.double, step: 1.0)
                        }
                    
                        ImageButton2(name: NSImage.goLeftTemplateName, action: {
                            self.viewModel.nextPage()
                        }, toolTipKey: "GO_LEFT_TOOLTIP")
                    
                        TextField("", value: $viewModel.page, formatter: NumberFormatter()).frame(width:40)
                        Text("/\(self.viewModel.pages)")
                    
                        ImageButton2(name: NSImage.goRightTemplateName, action: {
                            self.viewModel.backPage()
                        }, toolTipKey: "GO_RIGHT_TOOLTIP")
                    }
                }
                .background(isDarkMode() ? Color.black : Color.white)
                .opacity(0.7)
                .frame(width:500, height:self.viewModel.showBottomToolBar ? CGFloat(25.0) : CGFloat(10.0))
                .contentShape(Rectangle())
                .onHover(perform: { isHover in
                    if self.viewModel.settings.menuBehavior == .ShowsOnMouseHover
                    {
                        if isHover
                        {
                            self.viewModel.showBottomToolBar = true
                        }else{
                            self.viewModel.showBottomToolBar = false
                        }
                    }
                })
          }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
}
