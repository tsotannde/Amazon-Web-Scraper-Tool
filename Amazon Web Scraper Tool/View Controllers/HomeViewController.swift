//
//  HomeViewController.swift
//  Amazon Web Scrapper
//
//  Created by tsotannde on 5/5/25.
//

import Cocoa

class HomeViewController: NSViewController
{
    
    @IBOutlet weak var outputTextView: NSScrollView!
    
    @IBAction func loginButtonPressed(_ sender: Any)
    {
        runLoginScript()
    }
  
}

extension HomeViewController
{
    func appendToOutput(_ text: String) {
        DispatchQueue.main.async {
            if let textView = self.outputTextView.documentView as? NSTextView {
                let currentText = textView.string
                let updatedText = currentText + "\n" + text
                textView.string = updatedText
                textView.scrollToEndOfDocument(nil)
            }
        }
    }
}
// MARK: - Run Login Script
extension HomeViewController
{
    func runLoginScript() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        let scriptPath = Bundle.main.bundlePath + "/Contents/Resources/loginToAmazon.py"
        process.arguments = [scriptPath]

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let stdoutHandle = stdoutPipe.fileHandleForReading
        let stderrHandle = stderrPipe.fileHandleForReading

        stdoutHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                self.appendToOutput("Login Script Output:\n\(output.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }

        stderrHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let errorOutput = String(data: data, encoding: .utf8), !errorOutput.isEmpty {
                self.appendToOutput("⚠️ Login Script Error:\n\(errorOutput.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
        }

        do {
            try process.run()
        } catch {
            appendToOutput("❌ Failed to run login script: \(error.localizedDescription)")
                   
        }
    }
}
