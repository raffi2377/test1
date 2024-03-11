//
//  ContentView.swift
//  YouTube-dl
//
//  Created by Raffi Chamakian on 2/4/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State var text: String = ""
    
    func runShellCommand(command: String) {
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print(output)
                }
            }
            let path = NSString(string: "~/Downloads/YouTube").expandingTildeInPath
            let openFinderProcess = Process()
            openFinderProcess.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            openFinderProcess.arguments = [path]
            
            try openFinderProcess.run()
            openFinderProcess.waitUntilExit()
        } catch {
            DispatchQueue.main.async {
                // Handle errors in the UI if needed
                print("Failed to run shell command: \(error)")
            }
            
        }
    }
    
    func downloadHandler(text: String) {
        runShellCommand(command: "/opt/homebrew/bin/yt-dlp \(text)")
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("YouTube URL")
                TextField("Enter YouTube URL here...", text: $text).textFieldStyle(.roundedBorder)
            }
            HStack(alignment: .center) {
                Button("Download") {
                    DispatchQueue.global(qos: .background).async {
                        self.downloadHandler(text: text)
                    }
                }
            }
        }.padding()
    }
}

#Preview {
    ContentView()
}
