//
//  CanvasView.swift
//  CaptureText
//
//  Created by shenruqi on 10/15/24.
//


import SwiftUI
import SpriteKit

 struct CanvasView: View {
//    let images: [NSImage]
    let frameWithTexts: [FrameWithText]
    @State private var scene: DraggableScene?
    @Environment(\.presentationMode) var presentationMode
     
     @State private var magnification: CGFloat = 1.0
     
    var body: some View {
        VStack {
            if let scene = scene {
                ScrollView{
                    SpriteView(scene: scene)
                        .frame(width: 500, height: 500)
                        .padding()
                }
                .frame(height: 400)
            }
           
            
            HStack{
                Button("导出") {
                    exportCanvas()
                }
                Button("退出") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.padding(.vertical, 12)
            
            
        }
        .frame(width: 500, height: 500)
        .onAppear {
            setupScene()
        }
    }
    
    private func setupScene() {
        let firstFrame = frameWithTexts[0]
        let frameWidth = firstFrame.image.size.width
        let frameHeight = firstFrame.image.size.height
        let screenWidth: CGFloat = 500
        let screenHeight: CGFloat = 500
        var tCGSize: CGSize = .zero
        let aspectRatio = frameWidth / frameHeight
        if aspectRatio > 1 {
            tCGSize = CGSize(width: screenWidth, height: screenHeight / aspectRatio)
        } else {
            tCGSize = CGSize(width: screenWidth * aspectRatio, height: screenHeight)
        }
        // 总高
        var totalHeight: CGFloat = tCGSize.height
        var pointYs: [CGFloat] = [(tCGSize.height / 2 )]
        for (index, frame) in frameWithTexts.enumerated() {
            if index > 0 && !frame.textBounds.isEmpty {
                let bound: CGRect =  frame.textBounds[0]
                let y =  (bound.origin.y + bound.height) * tCGSize.height
               
                let offsetY = tCGSize.height  - y
                totalHeight = totalHeight + y
                pointYs.append((pointYs[pointYs.count - 1] + y))
            }
        }
        let newScene = DraggableScene(size: CGSize(width: 500 , height: totalHeight))
        newScene.scaleMode = .aspectFit
        
    
        for (index, frame) in frameWithTexts.enumerated() {
            let x = 500.0 / 2
            let y = totalHeight - pointYs[index]
            newScene.addImage(frame.image, at: CGPoint(x: x, y: y), tCGSize)
        }
        
        scene = newScene
    }
    
    func exportCanvas() {
        guard let scene = scene else { return }
        
        let texture = scene.view?.texture(from: scene)
        guard let cgImage = texture?.cgImage() else { return }
        
        let nsImage = NSImage(cgImage: cgImage, size: scene.size)
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "canvas_export.png"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                if let tiffData = nsImage.tiffRepresentation,
                   let bitmapImage = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
                    do {
                        try pngData.write(to: url)
                        DispatchQueue.main.async {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
            }
        }
    }
}





//
//
//class DraggableScene: SKScene {
//    var draggableNodes: [SKSpriteNode] = []
//    private var selectedNode: SKSpriteNode?
//    private var touchOffset: CGPoint = .zero
//    private var highestZPosition: CGFloat = 1
//
//    override func didMove(to view: SKView) {
//        backgroundColor = .white
//    }
//
//    func addImage(_ image: NSImage, at position: CGPoint) {
//        let texture = SKTexture(image: image)
//        let node = SKSpriteNode(texture: texture)
//        node.position = position
//        node.setScale(0.5) // 调整大小，根据需要修改
//        node.zPosition = highestZPosition
//        highestZPosition += 1
//        addChild(node)
//        draggableNodes.append(node)
//    }
//
//    override func mouseDown(with event: NSEvent) {
//        let location = event.location(in: self)
//        for node in draggableNodes.reversed() {
//            if node.contains(location) {
//                selectedNode = node
//                bringNodeToFront(node)
//                // 计算触摸点与节点中心的偏移
//                touchOffset = CGPoint(x: location.x - node.position.x,
//                                      y: location.y - node.position.y)
//                updateCursor(for: node)
//                break
//            }
//        }
//    }
//
//    override func mouseDragged(with event: NSEvent) {
//        if let selectedNode = selectedNode {
//            let location = event.location(in: self)
//            // 使用偏移来计算新的位置
//            let newPosition = CGPoint(x: location.x - touchOffset.x,
//                                      y: location.y - touchOffset.y)
//            selectedNode.position = newPosition
//            NSCursor.closedHand.set() // 拖动时使用"closed hand"光标
//        }
//    }
//
//    override func mouseUp(with event: NSEvent) {
//        selectedNode = nil
//        touchOffset = .zero
//        NSCursor.arrow.set() // 恢复默认鼠标样式
//    }
//
//    override func mouseMoved(with event: NSEvent) {
//        let location = event.location(in: self)
//        var isOverNode = false
//        for node in draggableNodes {
//            if node.contains(location) {
//                updateCursor(for: node)
//                isOverNode = true
//                break
//            }
//        }
//        if !isOverNode {
//            NSCursor.arrow.set() // 不在节点上时，使用默认鼠标样式
//        }
//    }
//
//    private func updateCursor(for node: SKSpriteNode) {
//        NSCursor.openHand.set()
//    }
//
//    private func bringNodeToFront(_ node: SKSpriteNode) {
//        highestZPosition += 1
//        node.zPosition = highestZPosition
//    }
//}
