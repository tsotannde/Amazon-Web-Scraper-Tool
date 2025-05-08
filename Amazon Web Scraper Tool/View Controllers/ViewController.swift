//
//  ViewController.swift
//  Amazon Web Scrapper
//
//  Created by tsotannde on 5/2/25.
//

import Cocoa

class ViewController: NSViewController
{
    
    //SystemCheck Box
    @IBOutlet weak var sandboxStatusIcon: NSImageView!
    @IBOutlet weak var chromeStatusIcon: NSImageView!
    @IBOutlet weak var pythonStatusIcon: NSImageView!
    @IBOutlet weak var chromeDriverIcon: NSImageView!
    @IBOutlet weak var seleniumIcon: NSImageView!
    @IBOutlet weak var webDriverPluginIcon: NSImageView!
    
    //Output Box
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var reviewsTextView: NSTextView!
    
    //Used for inprogress animation
    var scrapingAnimationTimer: Timer?
    var scrapingAnimationDotCount = 0
    
    //ASIN Box
    @IBOutlet weak var scrapingStatusTextBox: NSTextField!
    @IBOutlet weak var scrapingStatus: NSImageView!
    @IBOutlet weak var asinTextField: NSTextField!
    @IBOutlet weak var asinStatusIcon: NSImageView!
    @IBAction func searchButtonPressed(_ sender: Any)
    {
        let asin = asinTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        validateAndRunASIN(asin)
    }
    
    
   
   
    
    override func viewDidLoad()
    {
        updateResourceCheck()
        super.viewDidLoad()
        
        outputTextView.backgroundColor = NSColor.black
            outputTextView.textColor = NSColor.white
            outputTextView.font = NSFont(name: "Menlo", size: 12)

            // Style the Reviews box
            reviewsTextView.backgroundColor = NSColor.black
            reviewsTextView.textColor = NSColor.white
            reviewsTextView.font = NSFont(name: "Menlo", size: 12)
        
        //Prevents user input
        outputTextView.isEditable = false
        reviewsTextView.isEditable = false
        
       
       //runScraper(withASIN: asinTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSApp.terminate(nil)  // This triggers full app termination (and cleanup)
    }
}

//MARK: - ViewDidLoad
extension ViewController
{
    func updateResourceCheck()
    {
        let chromeOK = isChromeInstalled()
        let sandboxOK = !isAppSandboxed()
        let pythonOK = isPythonInstalled()
        let chromeDriverOK = isChromeDriverInstalled()
        let seleniumOK = isSeleniumInstalled()
        let webDriverPluginOK = isWebDriverManagerInstalled()
           
        updateStatusIcon(chromeStatusIcon, isSuccess: chromeOK)
        updateStatusIcon(sandboxStatusIcon, isSuccess: sandboxOK)
        updateStatusIcon(pythonStatusIcon, isSuccess: pythonOK)
        updateStatusIcon(chromeDriverIcon, isSuccess: chromeDriverOK)
        updateStatusIcon(seleniumIcon, isSuccess: seleniumOK)
        updateStatusIcon(webDriverPluginIcon, isSuccess: webDriverPluginOK)
    }
    
    //Update icons
    func updateStatusIcon(_ imageView: NSImageView, isSuccess: Bool) {
        if isSuccess
        {
            imageView.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Success")
            imageView.contentTintColor = .systemGreen
        }
        else
        {
            imageView.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Failure")
            imageView.contentTintColor = .systemRed
        }
    }
    
    //Chrome Check
    func isChromeInstalled() -> Bool
    {
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") != nil
    }
    
    //SandBox Check
    func isAppSandboxed() -> Bool {
        return ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
    }
    
    //Python Check
    func isPythonInstalled() -> Bool
    {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["python3", "--version"] // try python3 first

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.environment = ["PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)
            {
                printToConsole("Python3 output: + \(output)")
            }

            if process.terminationStatus == 0 {
                return true
            }

            // Fallback to python2
            let process2 = Process()
            process2.launchPath = "/usr/bin/env"
            process2.arguments = ["python", "--version"]
            process2.standardOutput = pipe
            process2.standardError = pipe
            process2.environment = process.environment

            try process2.run()
            process2.waitUntilExit()

            let data2 = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output2 = String(data: data2, encoding: .utf8) {
                printToConsole("Python2 output: +  \(output2)")
            }

            return process2.terminationStatus == 0

        } catch {
            printToConsole("Error checking for Python: + \(error.localizedDescription)")
            return false
        }
    }
    
    
    func isChromeDriverInstalled() -> Bool {
        printToConsole("🔍 Starting ChromeDriver check...")

        let process = Process()
        process.launchPath = "/usr/bin/env"
        printToConsole("✅ Set launch path to: \(process.launchPath ?? "nil")")

        process.arguments = ["which", "chromedriver"]
        printToConsole("✅ Set arguments to: \(process.arguments ?? [])")

        process.environment = ["PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
        printToConsole("✅ Set environment PATH to: \(process.environment?["PATH"] ?? "nil")")

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            printToConsole("✅ Process started successfully.")
            process.waitUntilExit()
            printToConsole("✅ Process exited with status: \(process.terminationStatus)")

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
                printToConsole("📤 Raw ChromeDriver output: '\(output)'")
                printToConsole("📤 Trimmed ChromeDriver output: '\(trimmedOutput)'")

                let result = !trimmedOutput.isEmpty
                printToConsole("🟩 ChromeDriver detected? \(result)")
                return result
            }

            printToConsole("⚠️ Output was nil or not readable.")
            return false
        } catch {
            printToConsole("❌ Error checking chromedriver:")
            return false
        }
    }
    
    func isSeleniumInstalled() -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["python3", "-c", "import selenium"]

        let pipe = Pipe()
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            return process.terminationStatus == 0
        } catch {
            printToConsole("Error checking selenium: + \(error.localizedDescription)")
            return false
        }
    }
    
    func isWebDriverManagerInstalled() -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["python3", "-c", "import webdriver_manager"]

        let pipe = Pipe()
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
    
}


//MARK: - ASIN Data
extension ViewController
{
    //ASIN Validator
    func isValidASIN(_ asin: String, completion: @escaping (Bool) -> Void) {
        guard asin.count == 10 else {
            completion(false)
            return
        }

        let urlString = "https://www.amazon.com/dp/\(asin)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent") // mimic real browser

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                let isValid = (200...299).contains(httpResponse.statusCode)
                completion(isValid)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    func validateAndRunASIN(_ asin: String)
    {
        // Show a "checking" icon
        asinStatusIcon.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Checking")
        asinStatusIcon.contentTintColor = .systemGray

        isValidASIN(asin) { isValid in
            DispatchQueue.main.async {
                if isValid {
                    self.asinStatusIcon.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Valid ASIN")
                    self.asinStatusIcon.contentTintColor = .systemGreen
                    self.runScraper(withASIN: asin)
                    self.setScrapingStatusInProgress()
                } else {
                    self.asinStatusIcon.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Invalid ASIN")
                    self.asinStatusIcon.contentTintColor = .systemRed
                    self.printToConsole("\(asin) + is an invalid ASIN, Please Try again")
                }
            }
        }
    }
}

//MARK: - Script Code
extension ViewController
{
    
    func runScraper(withASIN asin: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        let scriptPath = Bundle.main.bundlePath + "/Contents/Resources/asinReceiver.py"
        process.arguments = [scriptPath, asin]

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let stdoutHandle = stdoutPipe.fileHandleForReading
        let stderrHandle = stderrPipe.fileHandleForReading

        // Handle normal output
        stdoutHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                DispatchQueue.main.async {
                    
                    
                    
                    self.outputTextView.string += "\n\(output)"
                    self.outputTextView.scrollToEndOfDocument(nil)
                    
                    // 👉 NEW: Check if this output contains reviews
                    self.extractAndDisplayReviews(from: output)
                    // NEW: Detect scraping finished
                                if output.contains("📢📢📢 SCRAPING_COMPLETE_FLAG 📢📢📢") {
                                    self.printToConsole("🎉 Scraping fully complete!")
                                    self.setScrapingStatusSuccess()
                                }
                }
            }
        }

        // Handle errors separately (optional: you could ignore them, or log them elsewhere)
        stderrHandle.readabilityHandler = { handle in
            let data = handle.availableData
            if let errorOutput = String(data: data, encoding: .utf8), !errorOutput.isEmpty {
                // 👉 OPTION 1: Ignore completely (do nothing)
                // 👉 OPTION 2: Log quietly somewhere if needed, but don't spam the user
                print("⚠️ Python Script Error (ignored): \(errorOutput)")
            }
        }

        do {
            try process.run()
        } catch {
            self.printToConsole("❌ Failed to run script: \(error)")
        }
    }
func runScraperOriginal(withASIN asin: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/python3") // Or your Python path
    let scriptPath = Bundle.main.bundlePath + "/Contents/Resources/asinReceiver.py"
    process.arguments = [scriptPath, asin]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    let fileHandle = pipe.fileHandleForReading

    
    fileHandle.readabilityHandler = { handle in
        let data = handle.availableData
        if let output = String(data: data, encoding: .utf8), !output.isEmpty {
            self.printToConsole("Script output:\n\(output)")
            DispatchQueue.main.async {
                self.outputTextView.string += "\n\(output)"
            }
        }
    }

    do {
        try process.run()
    } catch {
        printToConsole("❌ Failed to run script: \(error)")
    }
}

    
    func printToConsole(_ text: String) {
        DispatchQueue.main.async {
            self.outputTextView.string += "\n\(text)"
            self.outputTextView.scrollToEndOfDocument(nil)
        }
        Swift.print(text)
    }
    
    
    
    func extractAndDisplayReviews(from output: String) {
        let reviewLines = output.components(separatedBy: .newlines).filter { line in
            return line.starts(with: "⭐️ Review") || line.starts(with: "Title:") || line.starts(with: "Rating is:") || line.starts(with: "Date:") || line.starts(with: "Body:") || line.starts(with: "➡️ Moving to next page...")
        }

        // Rebuild the filtered review text
        let reviewText = reviewLines.joined(separator: "\n")

        if !reviewText.isEmpty {
            self.reviewsTextView.string += "\n\(reviewText)"
            self.reviewsTextView.scrollToEndOfDocument(nil)
        }
    }
    
}


// MARK: - Scraping Status
extension ViewController
{
    func setScrapingStatusIdle() {
        scrapingStatus.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Idle")
        scrapingStatus.contentTintColor = .systemGray
        scrapingStatusTextBox.stringValue = "Not Started"
    }
    
    func setScrapingStatusInProgress() {
        scrapingAnimationTimer?.invalidate()
        scrapingAnimationTimer = nil

        scrapingStatus.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Scraping In Progress")
        scrapingStatus.contentTintColor = .systemGray
        
        scrapingAnimationDotCount = 0
        scrapingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let dots = String(repeating: ".", count: self.scrapingAnimationDotCount)
            self.scrapingStatusTextBox.stringValue = "Scraping in Progress" + dots
            
            self.scrapingAnimationDotCount = (self.scrapingAnimationDotCount + 1) % 4
        }
    }
    
    func setScrapingStatusInProgress2() {
        scrapingStatus.image = NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Scraping In Progress")
        scrapingStatus.contentTintColor = .systemGray
        scrapingStatusTextBox.stringValue = "Scraping In Progress..."
    }
    
    func setScrapingStatusError() {
        scrapingStatus.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Error")
        scrapingStatus.contentTintColor = .systemRed
        scrapingStatusTextBox.stringValue = "Error Occurred"
    }
    
    func setScrapingStatusSuccess() {
        scrapingAnimationTimer?.invalidate()  // 👈 Stop the progress animation
        scrapingAnimationTimer = nil

        scrapingStatus.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Success")
        scrapingStatus.contentTintColor = .systemGreen
        scrapingStatusTextBox.stringValue = "Scraping Complete"
    }
}
