//
//  ImageTool.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import Cocoa
import AVKit

class ImageTool {
    
    // 导出图片
    static func exportImage(frame: FrameWithText) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.png]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "frame_\(Int(frame.timestamp.seconds)).png"
        
        savePanel.beginSheetModal(for: NSApp.keyWindow!) { response in
            if response == .OK, let url = savePanel.url {
                do {
                    
                    if let imageData = frame.image.drawingTextBounds(frame.textBounds).pngData() {
                        try imageData.write(to: url)
                        print("图片已成功保存到: \(url.path)")
                    } else {
                        print("无法将图像转换为PNG数据")
                    }
                } catch {
                    print("保存图片时发生错误: \(error)")
                }
            }
        }
    }
    
    // Vision 返回的 boundingBox 是一个归一化的矩形 (0-1)，该函数将其转换为 UIKit 坐标
    static func VNImageRectForNormalizedRect(_ normalizedRect: CGRect, _ imageWidth: Int, _ imageHeight: Int) -> CGRect {
        let x = normalizedRect.origin.x * CGFloat(imageWidth)
        let y = (normalizedRect.origin.y) * CGFloat(imageHeight)
        let width = normalizedRect.width * CGFloat(imageWidth)
        let height = normalizedRect.height * CGFloat(imageHeight)
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // images 转 gif
    static func saveImagesToGif(_ images: [NSImage], loopCount: Int = 0, frameDuration: Double = 0.1) {
        guard !images.isEmpty else {
            print("Error: No images to save")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.gif]
        savePanel.nameFieldStringValue = "output.gif"
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "保存 GIF"
        savePanel.message = "选择保存 GIF 的位置"
        savePanel.prompt = "保存"
        
        savePanel.begin { result in
              if result == .OK, let url = savePanel.url {
                  guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, images.count, nil) else {
                      print("Error: Could not create CGImageDestination")
                      return
                  }
                  
                  let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDuration]]
                  let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
                  
                  CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
                  
                  for image in images {
                      guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                          continue
                      }
                      CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
                  }
                  
                  if CGImageDestinationFinalize(destination) {
                      print("GIF saved successfully at: \(url.path)")
                  } else {
                      print("Error: Could not finalize CGImageDestination")
                  }
              }
          }
      }


}
