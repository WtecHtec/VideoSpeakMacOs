//
//  Youget.swift
//  CaptureText
//
//  Created by shenruqi on 10/16/24.
//

import Foundation


class YouGetDownloader {

    
    static func postDowdLoader(url: String, completion: @escaping (Bool, String)  -> Void) {
        makePostRequest(urlString: "http://127.0.0.1:3000/download", parameters: ["url": url]) { result in
            switch result {
               case .success(let data):
                   // 请求成功，处理返回的数据
                do {
                    if let responseString = String(data: data, encoding: .utf8)?.data(using: .utf8) {
                        if  let jsonObject = try JSONSerialization.jsonObject(with: responseString, options: []) as? [String: Any] {
                              print("Response: \(jsonObject)")
                              // 使用 JSONSerialization 将 Data 转换为 [String: Any]
                            guard  let videoPath = jsonObject["videoPath"] as? String  else {
                                completion(false, "")
                                return
                            }
                            completion(true, videoPath)
                            return
                        }
                    }
                    completion(false, "")
                } catch {
                    print("Error serializing JSON: \(error)")
                    completion(false, "")
                }
               case .failure(let error):
                   // 请求失败，处理错误
                   print("Error: \(error)")
                completion(false, "")
               }
        }
    }
    
    static func makePostRequest(urlString: String, parameters: [String: Any], completion: @escaping (Result<Data, Error>)  -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST" // 设置请求方法为 POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // 设置请求头

        // 将参数转为 JSON 数据
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data {
                completion(.success(data))
            } else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                completion(.failure(unknownError))
            }
        }

        task.resume()
    }
}

@objc(YouGetServiceProtocol)
protocol YouGetServiceProtocol {
    func download(url: String, outputPath: String?, withReply reply: @escaping (Bool, String, String) -> Void)
    
    func makePostRequest(urlString: String, parameters: [String: Any], completion: @escaping (Bool, Any) -> Void)
}

class YouGetExecutor {
    static func download(url: String, outputPath: String? = nil, completion: @escaping (Bool, String, String) -> Void) {
        let connection = NSXPCConnection(serviceName: "com.gptsmotion.YouGetService")
        connection.remoteObjectInterface = NSXPCInterface(with: YouGetServiceProtocol.self)
        connection.resume()
        
        guard let service = connection.remoteObjectProxy as? YouGetServiceProtocol else {
            completion(false, "", "无法连接到 XPC 服务")
            return
        }
        
        service.download(url: url, outputPath: outputPath) { success, output, error in
            connection.invalidate()
            completion(success, output, error)
        }
    }
    
    static func postDowdLoader(url: String, completion: @escaping (Bool, Any) -> Void) {
        let connection = NSXPCConnection(serviceName: "com.gptsmotion.YouGetService")
        connection.remoteObjectInterface = NSXPCInterface(with: YouGetServiceProtocol.self)
        connection.resume()
        
        guard let service = connection.remoteObjectProxy as? YouGetServiceProtocol else {
            completion(false, "无法连接到 XPC 服务")
            return
        }
        
        service.makePostRequest(urlString: "http://127.0.0.1:3000/download", parameters: ["url": url]) { status, output in
            connection.invalidate()
            print("output---", output)
            completion(status, output)
        }
    }
    
    static func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        let environment = [
          "TERM": "xterm",
          "HOME": "/Users/example-user/",
          "PATH": "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        ]
      
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.environment = environment
        do {
            try task.run()
        } catch {
            return "执行命令失败: \(error)"
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        print("output---", output)
        return output
    }


}
