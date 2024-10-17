//
//  YouGetService.swift
//  YouGetService
//
//  Created by shenruqi on 10/16/24.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
//class YouGetService: NSObject, YouGetServiceProtocol {
//    
//    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
//    @objc func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void) {
//        let response = firstNumber + secondNumber
//        reply(response)
//    }
//}




class YouGetService: NSObject, YouGetServiceProtocol {
    @objc func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void) {
        let response = firstNumber + secondNumber
        reply(response)
    }
    
    // post 请求
    func makePostRequest(urlString: String, parameters: [String: Any], completion: @escaping (Bool, Any) -> Void) {
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
                completion(false,error)
                return
            }
            
            if let data = data {
                completion(true,data)
            } else {
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                completion(false, unknownError)
            }
        }
        
        task.resume()
    }
    
    func download(url: String, outputPath: String?, withReply reply: @escaping (Bool, String, String) -> Void) {
        let youGetPath = "/bin/bash" // 确保这是正确的路径
        let environment = [
            "TERM": "xterm",
            "HOME": "/Users/example-user/",
            "PATH": "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        ]
        
        var arguments = ["-c", "you-get \(url) -o \(outputPath!)"]
        print("arguments---", arguments)
        //        if let path = outputPath {
        //            arguments.insert("-o", at: 0)
        //            arguments.insert(path, at: 1)
        //        }
        
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = URL(fileURLWithPath: youGetPath)
        task.environment = environment
        task.arguments = arguments
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8) ?? ""
            
            reply(task.terminationStatus == 0, output, error)
        } catch {
            reply(false, "", error.localizedDescription)
        }
    }
    
    
    
    
    
}
