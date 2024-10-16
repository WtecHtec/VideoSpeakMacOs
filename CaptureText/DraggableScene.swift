//
//  DraggableScene.swift
//  CaptureText
//
//  Created by shenruqi on 10/15/24.
//

import SpriteKit
import AppKit

class DraggableScene: SKScene {
    var draggableNodes: [SKSpriteNode] = []
    private var selectedNode: SKSpriteNode?
    private var touchOffset: CGPoint = .zero
    private var highestZPosition: CGFloat = 1
    
    

    private var selectedCorner: SKShapeNode?
    private var selectionBox: SKShapeNode?
    private let minScale: CGFloat = 0.1
    private let maxScale: CGFloat = 2.0
    private var initialTouchLocation: CGPoint = .zero
    private var initialNodeSize: CGSize = .zero
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        
    }
    
    
    
    override func didChangeSize(_ oldSize: CGSize) {
           super.didChangeSize(oldSize)
       }
    
    func addImage(_ image: NSImage, at position: CGPoint, _ size: CGSize) {
        let texture = SKTexture(image: image)
        let node = SKSpriteNode(texture: texture)
        node.position = position
//        node.setScale(0.5) // 初始缩放
        node.zPosition = highestZPosition
        highestZPosition -= 1
        node.size = size
//        let aspectRatio = texture.size().width / texture.size().height
//        if aspectRatio > 1 {
//            node.size = CGSize(width: self.size.width, height: self.size.height / aspectRatio)
//        } else {
//            node.size = CGSize(width: self.size.width * aspectRatio, height: self.size.height)
//        }
        addChild(node)
        draggableNodes.append(node)
        
//        addCorners(to: node)
    }

//    override func mouseDown(with event: NSEvent) {
//        handleTouchDown(at: event.location(in: self))
//    }
//
//    override func mouseDragged(with event: NSEvent) {
//        handleTouchMoved(to: event.location(in: self))
//    }
//
//    override func mouseUp(with event: NSEvent) {
//        handleTouchUp()
//    }
//
//    override func mouseMoved(with event: NSEvent) {
//        updateCursorForLocation(event.location(in: self))
//    }

    func handleTouchDown(at location: CGPoint) {
        for node in draggableNodes.reversed() {
            if node.contains(location) {
                selectedNode = node
                bringNodeToFront(node)
                touchOffset = CGPoint(x: location.x - node.position.x,
                                      y: location.y - node.position.y)
                updateCursor(for: node)
                break
            }
        }
    }

    func handleTouchMoved(to location: CGPoint) {
        if let selectedNode = selectedNode {
            let newPosition = CGPoint(x: location.x - touchOffset.x,
                                      y: location.y - touchOffset.y)
            selectedNode.position = newPosition
            NSCursor.closedHand.set()
        }
    }

    func handleTouchUp() {
        selectedNode = nil
        touchOffset = .zero
        NSCursor.arrow.set()
    }

  

    private func updateCursorForLocation(_ location: CGPoint) {
        var isOverNode = false
        for node in draggableNodes {
            if node.contains(location) {
                updateCursor(for: node)
                isOverNode = true
                break
            }
        }
        if !isOverNode {
            NSCursor.arrow.set()
        }
    }

    private func updateCursor(for node: SKSpriteNode) {
        NSCursor.openHand.set()
    }

//    private func bringNodeToFront(_ node: SKSpriteNode) {
//        highestZPosition += 1
//        node.zPosition = highestZPosition
//    }
    
    
  
    // scale
    
    private func addCorners(to node: SKSpriteNode) {
         let cornerLength: CGFloat = 20
         let cornerWidth: CGFloat = 4
        let cornerRadius: CGFloat = cornerWidth / 2 // 圆角半径
         let corners = [
             CGPoint(x: -node.size.width / 2, y: -node.size.height / 2),  // 左下
             CGPoint(x: node.size.width / 2, y: -node.size.height / 2),   // 右下
             CGPoint(x: -node.size.width / 2 , y: node.size.height / 2),   // 左上
             CGPoint(x: node.size.width / 2, y: node.size.height / 2)     // 右上
         ]
         
         for corner in corners {
             let horizontalLine = SKShapeNode(rectOf: CGSize(width: cornerLength, height: cornerWidth), cornerRadius: cornerRadius)
             let verticalLine = SKShapeNode(rectOf: CGSize(width: cornerWidth, height: cornerLength), cornerRadius: cornerRadius)
             
             horizontalLine.fillColor = .blue
             verticalLine.fillColor = .blue
             
             horizontalLine.position = CGPoint(x: corner.x + (corner.x < 0 ? cornerLength/2 : -cornerLength/2), y: corner.y)
             verticalLine.position = CGPoint(x: corner.x, y: corner.y + (corner.y < 0 ? cornerLength/2 : -cornerLength/2))
             
             horizontalLine.isHidden = true
             verticalLine.isHidden = true
             
             node.addChild(horizontalLine)
             node.addChild(verticalLine)
         }
     }
   
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        selectNodeForTouch(location)
        initialTouchLocation = location
        if let selectedNode = selectedNode {
            initialNodeSize = selectedNode.size
        }
    }

    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        if selectedCorner != nil {
            resizeSelectedNode(with: location)
        } else {
            moveSelectedNode(to: location)
        }
    }
    
    
    override func mouseUp(with event: NSEvent) {
        releaseSelectedNode()
    }
    
    // 选择事件
    private func selectNodeForTouch(_ location: CGPoint) {
          selectedNode = nil
          selectedCorner = nil
          
          for node in draggableNodes {
              // 判断是否点击到缩放框
              if let corner = node.children.first(where: {
                  !$0.isHidden && $0 is SKShapeNode && $0.contains(convert(location, to: node))
              }) as? SKShapeNode {
                  selectedNode = node
                  selectedCorner = corner
                  bringNodeToFront(node)
                  updateSelectionBox(for: node)
                  return
              }
              
              if node.contains(location) {
                  selectedNode = node
                  bringNodeToFront(node)
                  touchOffset = CGPoint(x: location.x - node.position.x, y: location.y - node.position.y)
                  showCorners(for: node)
                  updateSelectionBox(for: node)
                  return
              }
          }
          
          hideAllCorners()
          removeSelectionBox()
      }
    
    // 移动 图片
    private func moveSelectedNode(to location: CGPoint) {
         guard let selectedNode = selectedNode else { return }
         let newPosition = CGPoint(x: location.x - touchOffset.x, y: location.y - touchOffset.y)
         selectedNode.position = newPosition
         updateSelectionBox(for: selectedNode)
     }
    
    // 缩放逻辑
    private func resizeSelectedNode(with location: CGPoint) {
           guard let selectedNode = selectedNode else { return }
           
           let nodeLocation = convert(location, to: selectedNode)
           let initialNodeLocation = convert(initialTouchLocation, to: selectedNode)
           
           let widthChange = (nodeLocation.x - initialNodeLocation.x) * 2
           let heightChange = (nodeLocation.y - initialNodeLocation.y) * 2
           
           var newWidth = initialNodeSize.width
           var newHeight = initialNodeSize.height
           
           if selectedCorner?.position.x ?? 0 < 0 {
               newWidth -= widthChange
           } else {
               newWidth += widthChange
           }
           
           if selectedCorner?.position.y ?? 0 < 0 {
               newHeight -= heightChange
           } else {
               newHeight += heightChange
           }
           
           let aspectRatio = initialNodeSize.width / initialNodeSize.height
           if abs(newWidth / newHeight - aspectRatio) > 0.1 {
               if newWidth / aspectRatio > newHeight {
                   newHeight = newWidth / aspectRatio
               } else {
                   newWidth = newHeight * aspectRatio
               }
           }
           
           let scale = min(max(newWidth / initialNodeSize.width, minScale), maxScale)
           selectedNode.size = CGSize(width: initialNodeSize.width * scale, height: initialNodeSize.height * scale)
           
           updateCornersPosition(for: selectedNode)
           updateSelectionBox(for: selectedNode)
       }
    
    // 初始化状态
    private func releaseSelectedNode() {
          selectedNode = nil
          selectedCorner = nil
          touchOffset = .zero
          initialNodeSize = .zero
          initialTouchLocation = .zero
      }

      private func bringNodeToFront(_ node: SKSpriteNode) {
//          highestZPosition += 1
//          node.zPosition = highestZPosition
      }
      
      private func showCorners(for node: SKSpriteNode) {
          hideAllCorners()
          node.children.forEach { $0.isHidden = false }
      }
      
    //  清除所有的 缩放框
      private func hideAllCorners() {
          draggableNodes.forEach { node in
              node.children.forEach { $0.isHidden = true }
          }
      }
    
    // 缩放图片时，更新圆角
    private func updateCornersPosition(for node: SKSpriteNode) {
           let corners = [
               CGPoint(x: -node.size.width / 2, y: -node.size.height / 2),
               CGPoint(x: node.size.width / 2, y: -node.size.height / 2),
               CGPoint(x: -node.size.width / 2, y: node.size.height / 2),
               CGPoint(x: node.size.width / 2, y: node.size.height / 2)
           ]
           
           for (index, corner) in corners.enumerated() {
               let horizontalLine = node.children[index * 2] as! SKShapeNode
               let verticalLine = node.children[index * 2 + 1] as! SKShapeNode
               
               horizontalLine.position = CGPoint(x: corner.x + (corner.x < 0 ? horizontalLine.frame.width/2 : -horizontalLine.frame.width/2), y: corner.y)
               verticalLine.position = CGPoint(x: corner.x, y: corner.y + (corner.y < 0 ? verticalLine.frame.height/2 : -verticalLine.frame.height/2))
           }
       }
       
      // 选中状态-框
       private func updateSelectionBox(for node: SKSpriteNode) {
           removeSelectionBox()
           
           let box = SKShapeNode(rectOf: node.size)
           box.strokeColor = .blue
           box.lineWidth = 1
           box.position = node.position
           box.zPosition = node.zPosition - 0.1
           
           addChild(box)
           selectionBox = box
       }
    
    // 删除当前选择框
    private func removeSelectionBox() {
        selectionBox?.removeFromParent()
        selectionBox = nil
    }
    
}
