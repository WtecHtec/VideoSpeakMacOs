//
//  ContentView.swift
//  CaptureText
//
//  Created by shenruqi on 10/13/24.
//

import SwiftUI
import AVKit
import Vision

import AVFoundation
import Speech

import ImageIO
import UniformTypeIdentifiers
import Security 

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State private var isAnalyzing = false
    @State private var framesWithText: [FrameWithText] = []
    @State private var frames: [FrameWithText] = []
    @State private var audioTranscriptions: [AudioTranscription] = []
    @State private var progress: Float = 0
    
    @State private var selectedFrame: FrameWithText?
    @State private var isShowingPreview = false
 
    @State private var selectedTab = 0
    @State private var currentTime: CMTime = .zero
    @State private var isSelected = false
    
    @State private var downLoadError = false
    
    @ObservedObject var audioFileModel: AudioFileModel = AudioFileModel()
    
    // 定义网格布局
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    private let VideoWidth: CGFloat  = 192 * 2
    private let VideoHeight: CGFloat = 108 * 2
   
    @State private var selectedIndices: [UUID] = []
    
    @State private var isCanvasViewPresented = false
    
    @State private var searchText = ""
    
    @State private var downLoadUrl = ""
    
    @State private var  aiContents: [ContentItem] = []
    // 计算属性
    var filteredFrames: [FrameWithText] {
        if searchText.isEmpty {
            return framesWithText
        } else {
            return framesWithText.filter { $0.text.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    
    var body: some View {
        HStack {
            VStack {
                VStack {
//                    HStack() {
//                        if let player = player {
//                            VideoPlayer(player: player)
//                                .frame(width: VideoWidth, height: VideoHeight)
//                        }
//                    }.frame(width: 480)
          
                    
                    HStack() {
                        if let player = player, !isSelected {
                            VideoPlayerView(player: $player, recognizedTexts: $frames, currentTime: $currentTime )
                                .frame(width: VideoWidth, height: VideoHeight)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                ).onChange(of: player){}
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.1))
                                .frame(width: VideoWidth, height: VideoHeight)
                                .overlay(
                                    Text( isSelected ? "视频加载中" :"未选择视频")
                                        .foregroundColor(.gray)
                                )
                        }
                    }.frame(width: VideoWidth)
                    
                }
                HStack {
                    TextField("视频URL", text: $downLoadUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                    Button("解析URL视频") {
//                        YouGetExecutor.download(url: downLoadUrl, outputPath: "/Users/shenruqi/Downloads") { success, output, error in
//                            if success {
//                                print("下载成功！输出：\n\(output)")
//                            } else {
//                                print("下载失败。错误：\n\(error)")
//                            }
//                        }
                        
//                        YouGetExecutor.postDowdLoader(url: downLoadUrl) { status, output in
//                            if status {
//                                print("下载成功！输出：\n\(output)")
//                            } else {
//                                print("下载失败。错误：\n\(output)")
//                            }
//                        }
                        
                        isSelected = true
                        YouGetDownloader.postDowdLoader(url: downLoadUrl) { status, output in
                            if status  && !output.isEmpty {
                                print("下载成功！输出：\n\(output)")
                                let url = URL(fileURLWithPath: output)
                                changeVideoFile(url: url)
                              
                            } else {
                                print("下载失败。错误：\n\(output)")
                                isSelected = false
                                downLoadError = true
                            }
                        }
//                        YouGetExecutor.shell("you-get -i \(downLoadUrl)")
                        
                    }
                    
                    Button("上传视频") {
                        // 实现视频选择逻辑
                        selectVideo()
                    }
                }
                Spacer()
            }.frame(minWidth: 400)
            
//            List(framesWithText) { frame in
//                FrameView(frame: frame)
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        // 实现跳转到指定帧逻辑
//                        seekToFrame(frame: frame)
////                        selectedFrame = frame
////                        isShowingPreview = true
//                    }
//                    .contextMenu {
//                        Button("导出图片") {
//                            // 实现导出图片逻辑
//                            exportImage(frame: frame)
//                        }
//                    }
//            }
            
            TabView(selection: $selectedTab) {
                VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        //                         ForEach(framesWithText) { frame in
                        //                             FrameView(frame: frame, selectionIndex: nil)
                        //                                 .onTapGesture {
                        //                                     seekToFrame(frame: frame)
                        //                                 }
                        //                                 .contextMenu {
                        //                                     Button("导出图片") {
                        //                                         // 实现导出图片逻辑
                        //                                         exportImage(frame: frame)
                        //                                     }
                        //                                 }
                        //                         }
                        
                        
                        
                        ForEach(Array(filteredFrames.enumerated()), id: \.element.id) { index, frame  in
                            FrameView(frame: frame, selectionIndex: selectionIndex(for: frame.id))
                                .onTapGesture {
                                    //                                     seekToFrame(frame: frame)
                                    toggleSelection(of: frame.id)
                                }
                                .contextMenu {
                                    Button("导出图片") {
                                        // 实现导出图片逻辑
                                        ImageTool.exportImage(frame: frame)
                                    }
                                }
                        }
                        
                        
                    }
                    .frame(minWidth: 500)
                    .padding()
                    
                    
                    
                    
                }
                HStack {
                    SearchBar(text: $searchText)
                    
                    Button("拼接") {
                        isCanvasViewPresented = true
                    }
                    .disabled(selectedIndices.isEmpty)
                    
                     Button("立即AI生成 ") {
                         
//                         if let jsonData = try? JSONEncoder().encode(aiContents),
//                            let jsonString = String(data: jsonData, encoding: .utf8) {
//                             print("JSON 字符串: \(aiContents.count)")
//                             YouGetDownloader.postAi(content: jsonString) {  status, data in
//                                 if status {
//                                     print("")
//                                 }
//                             }
//                         }
                         print("self.audioTranscriptions.isEmpty---", self.audioTranscriptions.isEmpty)
                         if !self.audioTranscriptions.isEmpty {
                             var content = ""
                             self.audioTranscriptions.forEach { audioTranscription in
                                 content = content + "\n" + audioTranscription.text
                             }
                              YouGetDownloader.postAi(content: content) {  status, data in
                                  if status {
                                      print("")
                                  }
                              }

                         }
                     }
                     .disabled(self.audioTranscriptions.isEmpty)
                    
//                    Button("立即生成GIF") {
//                        saveImagesToGif(getSelectedImages(), loopCount: 0, frameDuration: 0.5)
//                    }
//                    .disabled(selectedIndices.isEmpty)
                    
                }.padding()
            }
                 .tabItem {
                     Image(systemName: "text.bubble")
                     Text("画面文本")
                 }
                 .tag(0)
                
                
//                ScrollView {
//                    LazyVGrid(columns: columns, spacing: 20) {
//                        ForEach(frames) { frame in
//                            FrameView(frame: frame, selectionIndex: nil)
//                                .onTapGesture {
//                                    seekToFrame(frame: frame)
//                                }
//                                .contextMenu {
//                                    Button("导出图片") {
//                                        // 实现导出图片逻辑
//                                        ImageTool.exportImage(frame: frame)
//                                    }
//                                }
//                        }
//                    }
//                    .padding()
//                }
//                 .tabItem {
//                       Image(systemName: "text.bubble")
//                       Text("画面对象")
//                   }
//                .tag(1)
                
                VStack {
                    
                    List(audioTranscriptions) { transcription in
                        AudioTranscriptionView(transcription: transcription)
                    }
                    .scrollContentBackground(.hidden) // 隐藏默认背景
                    .listStyle(PlainListStyle()) // 使用无样式的列表
                    .edgesIgnoringSafeArea(.all)
                    
                    HStack {
                        if audioFileModel.exportInProgress {
                           ProgressView("导出中...")
                       }

                        if audioFileModel.exportCompleted {
                           Text("导出成功 🎉")
                               .foregroundColor(.green)
                       }

                        if let error = audioFileModel.exportError {
                           Text("导出失败: \(error)")
                               .foregroundColor(.red)
                       }
                        Spacer()
                        Button("导出音频文件") {
                            if let videoURL = self.videoURL {
                                audioFileModel.exportAudioFile(inVideoUrl: videoURL)
                            }
                        }
                        .disabled(audioFileModel.exportInProgress || self.videoURL == nil)
                    }
                    
                }
                 .tabItem {
                     Image(systemName: "waveform")
                     Text("音频文本")
                 }
                 .tag(2)
                
            }
        }
        .padding()
        .frame(minWidth: 1000)
        .overlay(
            ToastView(message: "解析视频URL错误", isShowing: $downLoadError)
                .padding()
        )
        .sheet(isPresented: $isCanvasViewPresented) {
            CanvasView(frameWithTexts: getSelectedImages())
        }.onAppear() {
   
        }
        
    }
    
    // 其他辅助方法...
    
    private func getSelectedImages() -> [FrameWithText] {
        var selectedImages: [FrameWithText] = []
        selectedIndices.forEach { id in
            if let frame = framesWithText.first(where: { frameWithText in
                frameWithText.id == id
            }) {
                selectedImages.append(frame)
            }
        }
        return selectedImages
    }
    
    private func selectionIndex(for id: UUID) -> Int? {
          selectedIndices.firstIndex(of: id).map { $0 + 1 }
      }
    
    private func toggleSelection(of id: UUID) {
        if let existingIndex = selectedIndices.firstIndex(of: id) {
            selectedIndices.remove(at: existingIndex)
            // 重新计算索引
            for i in existingIndex..<selectedIndices.count {
                selectedIndices[i] = selectedIndices[i]
            }
        } else {
            selectedIndices.append(id)
        }
    }
    
    
    // 选择视频
    private func selectVideo() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie]
        
        panel.beginSheetModal(for: NSApp.keyWindow!) { response in
            if response == .OK, let url = panel.url {
                changeVideoFile(url: url)
                // 添加时间观察器
                self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
                      self.currentTime = time
                  }
            }
        }
    }
    
    //
    private func changeVideoFile(url: URL) {
        isSelected = true
        self.videoURL = url
        self.player = AVPlayer(url: url)
        self.frames = []
        self.framesWithText = []
        self.audioTranscriptions = []
        self.selectedIndices = []
        DispatchQueue.main.async {
            isSelected = false
        }
        
       
        // 处理视频
        DispatchQueue.global(qos: .userInitiated).async {
            
            if let url = videoURL {
                // 字幕
                TranscribeAudio.transcribeAudio(from: url) { transcriptions in
                    DispatchQueue.main.async {
                        self.audioTranscriptions = TranscribeAudio.mergeTranscriptions(transcriptions)
                    }
                }
            }
        }
        DispatchQueue.global(qos: .background).async {
            analyzeVideo()
        }
          
    
    }

    
    private func analyzeVideo() {
        guard let videoURL = videoURL else { return }
        framesWithText.removeAll()
        isAnalyzing = true
        progress = 0
        let asset = AVAsset(url: videoURL)
        let duration = asset.duration.seconds
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        var framesWithTextIng: [FrameWithText] = []
        var direct: [String: Bool] = [String: Bool]()
        
        let fps: Float = 2500000
        // 遍历时间戳 会丢失一些
//        DispatchQueue.global(qos: .userInitiated).async {
//                 for time in stride(from: 0.0, to: duration, by: 1.0 / fps) {
//                     let cmTime = CMTime(seconds: time, preferredTimescale: 600)
//                     
//                     do {
//                         let cgImage = try generator.copyCGImage(at: cmTime, actualTime: nil)
//                         let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
//                         
//                         RecognizeText.recognizeTextInImage(image: CIImage(cgImage: cgImage)) { recognizedTexts in
//                                      if !recognizedTexts.isEmpty {
//                                          DispatchQueue.main.async {
//                                              let boundingBox: [CGRect] = []
//                                              recognizedTexts.forEach { recognizedText in
//                                                  if  direct[recognizedText.text] == false
//                                                        ||  direct[recognizedText.text] == nil {
//                                                      direct[recognizedText.text] = true
//                                                      framesWithTextIng.append(FrameWithText(
//                                                        image: nsImage,
//                                                        timestamp: cmTime,
//                                                        text: recognizedText.text,
//                                                        isWithText: true,
//                                                        textBounds: [recognizedText.boundingBox]
//                                                      ))
//                                                  }
//                                              }
////                                              self.frames.append(FrameWithText(
////                                                image: nsImage,
////                                                timestamp: cmTime,
////                                                text: "",
////                                                isWithText: false,
////                                                textBounds: boundingBox
////                                            ))
//                                          }
//                                      }
//                         }
//                         DispatchQueue.main.async {
//                             self.progress = Float(time / duration)
//                             self.framesWithText = framesWithTextIng
//                         }
//                     } catch {
//                         print("Error generating frame: \(error)")
//                     }
//                 }
//                 
//                 DispatchQueue.main.async {
//                     self.isAnalyzing = false
//                     self.progress = 1
//                     
//                 }
//             }
        
        
        //
        var index = 0
        RecognizeText.extractAllFramesByTime(from: videoURL, interval: 1) { cmTime, cgImage in
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            RecognizeText.recognizeTextInImage(image: CIImage(cgImage: cgImage)) { recognizedTexts in
                if !recognizedTexts.isEmpty {
                    DispatchQueue.main.async {
                        let boundingBox: [CGRect] = []
                        recognizedTexts.forEach { recognizedText in
                            if  direct[recognizedText.text] == false
                                    ||  direct[recognizedText.text] == nil {
                                direct[recognizedText.text] = true
                                self.framesWithText.append(FrameWithText(
                                    image: nsImage,
                                    timestamp: cmTime,
                                    text: recognizedText.text,
                                    isWithText: true,
                                    textBounds: [recognizedText.boundingBox]
                                ))
                                self.aiContents.append(ContentItem(index: index,  text: recognizedText.text))
                                index = index + 1
                            }
                        }
                    }
                }
            }
        }
         DispatchQueue.main.async {
             self.isAnalyzing = false
             self.progress = 1
         }
        
    }
    

  
    
    
    
    private func seekToFrame(frame: FrameWithText) {
         player?.seek(to: frame.timestamp, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
             if finished {
                 print("已跳转到时间戳: \(frame.timestamp.seconds)")
                 // 可选：跳转后自动暂停视频
                 self.player?.pause()
             }
         }
     }
    


    
 
    
}




#Preview {
    ContentView()
}
