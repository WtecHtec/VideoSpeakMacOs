//
//  NSImage+Extension.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//
import SwiftUI

extension NSImage {
    func pngData() -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}


extension NSImage {
    func drawingTextBounds(_ bounds: [CGRect], color: NSColor = .red) -> NSImage {
        let size = self.size
        let resultImage = NSImage(size: size)
        
        resultImage.lockFocus()
        
        // 绘制原始图片
        self.draw(in: NSRect(origin: .zero, size: size))
    
      // 设置绘图上下文为 NSGraphicsContext
      NSGraphicsContext.current?.shouldAntialias = false
      
      // 设置绘制颜色为红色
      NSColor.red.set()


       for rect in bounds {
           let path = NSBezierPath(rect: ImageTool.VNImageRectForNormalizedRect(rect, Int(size.width), Int(size.height)))
           path.lineWidth = 10.0 // 设置矩形边框宽度
           path.stroke() // 绘制矩形边框
       }
           
        
        resultImage.unlockFocus()
        
        return resultImage
    }
}

