
import SwiftUI
import AVFoundation
import AVKit
import Vision

struct VideoPlayerView: NSViewRepresentable {
    @Binding var player: AVPlayer?
    @Binding var recognizedTexts: [FrameWithText]
    @Binding var currentTime: CMTime

    func makeNSView(context: Context) -> NSView {
        let playerView = AVPlayerView()
        //         playerView.controlsStyle = .none // 隐藏控制栏，如果需要的话
        playerView.player = player
        
        
        playerView.videoGravity = .resizeAspect // 使用 .resizeAspect 来保持视频比例
       
       
        return playerView
    }
    
 

    
    
    func updateNSView(_ nsView: NSView, context: Context) {
   
        if let layer = nsView.layer?.sublayers?.first as? AVPlayerLayer {
            layer.player = player
        } else {
            let layer = AVPlayerLayer(player: player)
            layer.frame = nsView.bounds
            layer.videoGravity = .resizeAspect
            nsView.layer = CALayer()
            nsView.wantsLayer = true
            nsView.layer?.addSublayer(layer)
        }
        
        
//        let viewBounds = nsView.bounds
        
        // 移除旧的边界框
//        nsView.layer?.sublayers?.filter { $0.name == "BoundingBox" }.forEach { $0.removeFromSuperlayer() }
        
        // 添加新的边界框
//        let currentTexts = recognizedTexts.filter { abs($0.timestamp.seconds - currentTime.seconds) < 1 }
//        
//        
//        for text in currentTexts {
//            for textBound in text.textBounds {
//                let boxLayer = CALayer()
//                boxLayer.name = "BoundingBox"
//                boxLayer.borderColor = NSColor.red.cgColor
//                boxLayer.borderWidth = 2
//                // 转换边界框坐标
//                boxLayer.frame = CGRect(x: (textBound.origin.x) * CGFloat(viewBounds.width) ,
//                                        y: textBound.origin.y * CGFloat(viewBounds.height),
//                                        width: textBound.width * CGFloat(viewBounds.width),
//                                        height: textBound.height * CGFloat(viewBounds.height)
//                )
//                nsView.layer?.addSublayer(boxLayer)
//                
//            }
//            
//            
//        }
        
        
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
          // 当 player 发生变化时，更新 AVPlayerView
          nsView.player = player
      }
    

    
}


