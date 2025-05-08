//
//  setupViewController.swift
//  Amazon Web Scrapper
//
//  Created by tsotannde on 5/5/25.
//

import Cocoa
import Security
import SwiftUI

class SetupViewController: NSViewController
{
    // MARK: - IBOutlets for Dependency Status Icons
    @IBOutlet weak var chromeStatusIcon: NSImageView!
    @IBOutlet weak var pythonStatusIcon: NSImageView!
    @IBOutlet weak var chromeDriverIcon: NSImageView!
    @IBOutlet weak var seleniumIcon: NSImageView!
    @IBOutlet weak var webDriverPluginIcon: NSImageView!
    
    @IBOutlet weak var systemCheckStatusIcon: NSProgressIndicator!
    @IBOutlet weak var statusUpdateTextView: NSTextField!
    
    var statusMessageQueue: [String] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        startSpinningStatusIcons()
        systemCheckStatusIcon.startAnimation(nil)
        runAllChecks()
        
        
    }
    
    
    func summarizeSystemCheckResults(_ results: [Bool]) {
        let allPassed = results.allSatisfy { $0 }

        systemCheckStatusIcon.stopAnimation(nil)
        systemCheckStatusIcon.isHidden = true

        let finalIcon = NSImage(systemSymbolName: allPassed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                                accessibilityDescription: allPassed ? "Success" : "Warning")
        let finalColor = allPassed ? NSColor.systemGreen : NSColor.systemYellow

        let summaryImageView = NSImageView()
        summaryImageView.image = finalIcon
        summaryImageView.contentTintColor = finalColor
        summaryImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(summaryImageView)
        NSLayoutConstraint.activate([
            summaryImageView.centerXAnchor.constraint(equalTo: systemCheckStatusIcon.centerXAnchor),
            summaryImageView.centerYAnchor.constraint(equalTo: systemCheckStatusIcon.centerYAnchor),
            summaryImageView.widthAnchor.constraint(equalToConstant: 30),
            summaryImageView.heightAnchor.constraint(equalToConstant: 30)
        ])

        // Update statusUpdateTextView with summary
        if allPassed {
            statusUpdateTextView.stringValue = "✅ All resources installed.\n➡️ Press Next to continue."
        } else {
            var failedMessages: [String] = []
            if !results[0] { failedMessages.append("❌ Chrome not installed") }
            if !results[1] { failedMessages.append("❌ Python not installed") }
            if !results[2] { failedMessages.append("❌ Chrome Driver not installed") }
            if !results[3] { failedMessages.append("❌ Selenium not installed") }
            if !results[4] { failedMessages.append("❌ WebDriver Manager not installed") }

            statusUpdateTextView.stringValue = failedMessages.joined(separator: "\n")
        }
    }
}


// MARK: - Reflect Status in UI
extension SetupViewController
{
    //Update icons
    func updateStatusIcon(_ imageView: NSImageView, isSuccess: Bool)
    {
        // Remove any spinner if present (NSHostingView)
        for subview in imageView.subviews
        {
            if subview is NSHostingView<SpinningStatusIcon>
            {
                subview.removeFromSuperview()
            }
        }
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
    
    //Spinning Icon
    func startSpinningStatusIcons()
    {
        let icons: [NSImageView] = [chromeStatusIcon,pythonStatusIcon,chromeDriverIcon,seleniumIcon,webDriverPluginIcon]
        
        for icon in icons
        {
            icon.image = nil // Removes the placeholder icon in InterfaceBuilder
            let spinnerView = NSHostingView(rootView: SpinningStatusIcon())
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            icon.addSubview(spinnerView)
            
            NSLayoutConstraint.activate([
                spinnerView.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
                spinnerView.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
                spinnerView.widthAnchor.constraint(equalToConstant: 30),
                spinnerView.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    }
}

//MARK: - Status Message Queue Handling
extension SetupViewController
{
    func queueStatusMessage(_ message: String)
    {
        statusMessageQueue.append(message)
    }
    
    func startStatusMessageQueue(completion: (() -> Void)? = nil)
    {
        guard !statusMessageQueue.isEmpty else
        {
            completion?()
            return
        }
        
        statusUpdateTextView.stringValue = statusMessageQueue.removeFirst()
        
        let delay = Double.random(in: 0.1...3.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay)
        {
            self.startStatusMessageQueue(completion: completion)
        }
    }
}

//MARK: - System Readiness Functions
extension SetupViewController
{
    //Chrome Check
    func isChromeInstalled() -> Bool
    {
        queueStatusMessage("🔍 Starting Chrome check")
        queueStatusMessage("📦 Looking for Google Chrome bundle ID")
        
        let bundleID = "com.google.Chrome"
        queueStatusMessage("🔎 Searching for application with bundle ID: \(bundleID)")
        
        let result = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) != nil
        queueStatusMessage("📥 Setting result from NSWorkspace check")
        
        queueStatusMessage(result ? "✅ Chrome is installed and accessible" : "❌ Chrome is not installed or cannot be found")
        
        return result
    }
    
    //Python Check
    func isPythonInstalled() -> Bool
    {
        queueStatusMessage("🔍 Starting Python Check")
        queueStatusMessage("🛠️ Creating Process")
        let process = Process()
        
        queueStatusMessage("🚀 Setting Launch Path")
        process.launchPath = "/usr/bin/env"
        
        queueStatusMessage("⚙️ Setting Arguments for Python 3 Check")
        process.arguments = ["python3", "--version"]
        
        queueStatusMessage("🔌 Creating Output Pipe")
        let pipe = Pipe()
        
        queueStatusMessage("🔗 Connecting Standard Output to Pipe")
        process.standardOutput = pipe
        
        queueStatusMessage("🔗 Connecting Standard Error to Pipe")
        process.standardError = pipe
        
        queueStatusMessage("🌐 Setting Environment PATH")
        process.environment = ["PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
        
        do {
            queueStatusMessage("▶️ Running Python 3 Check")
            try process.run()
            process.waitUntilExit()
            
            queueStatusMessage("📥 Reading Python 3 Output")
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let _ = String(data: data, encoding: .utf8)
            {
                if process.terminationStatus == 0 {
                    queueStatusMessage("✅ Python 3 is installed and accessible")
                    return true
                }
                
                queueStatusMessage("⚠️ Python 3 not found — attempting Python 2 fallback")
                
                let process2 = Process()
                queueStatusMessage("🛠️ Creating fallback Process for Python 2")
                process2.launchPath = "/usr/bin/env"
                process2.arguments = ["python", "--version"]
                process2.standardOutput = pipe
                process2.standardError = pipe
                process2.environment = process.environment
                
                queueStatusMessage("▶️ Running Python 2 Fallback")
                try process2.run()
                process2.waitUntilExit()
                
                queueStatusMessage("📥 Reading Python 2 Output")
                let data2 = pipe.fileHandleForReading.readDataToEndOfFile()
                if let _ = String(data: data2, encoding: .utf8) {
                    let success = process2.terminationStatus == 0
                    queueStatusMessage(success ? "✅ Python 2 is installed and accessible" : "❌ Python not found")
                    return success
                }
            }
            
            queueStatusMessage("❌ Unable to read output from Python 3 check")
            return false
        }
        catch {
            queueStatusMessage("❌ Error occurred while checking Python: \(error.localizedDescription)")
            return false
        }
    }
    
    //Chrome Driver Check
    func isChromeDriverInstalled() -> Bool {
        queueStatusMessage("🔍 Starting ChromeDriver check")
        
        queueStatusMessage("🛠️ Creating process to locate ChromeDriver")
        let process = Process()
        
        queueStatusMessage("🚀 Setting process launch path to /usr/bin/env")
        process.launchPath = "/usr/bin/env"
        
        queueStatusMessage("⚙️ Setting process arguments: which chromedriver")
        process.arguments = ["which", "chromedriver"]
        
        queueStatusMessage("🌐 Configuring environment PATH")
        process.environment = ["PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
        
        queueStatusMessage("🔌 Creating output pipe")
        let pipe = Pipe()
        
        queueStatusMessage("🔗 Connecting standard output and error to pipe")
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            queueStatusMessage("▶️ Running ChromeDriver lookup process")
            try process.run()
            process.waitUntilExit()
            
            queueStatusMessage("📥 Reading output from process")
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            if let output = String(data: data, encoding: .utf8) {
                let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
                let result = !trimmedOutput.isEmpty
                
                queueStatusMessage(result ? "✅ ChromeDriver is installed and found at: \(trimmedOutput)" : "❌ ChromeDriver not found in PATH")
                return result
            }
            
            queueStatusMessage("❌ Failed to read output from process")
            return false
        } catch {
            queueStatusMessage("❌ Error occurred while checking ChromeDriver: \(error.localizedDescription)")
            return false
        }
    }
    
    //Selenium Driver Check
    func isSeleniumInstalled() -> Bool {
        queueStatusMessage("🔍 Starting Selenium check")
        
        queueStatusMessage("🛠️ Creating process to import Selenium in Python")
        let process = Process()
        
        queueStatusMessage("🚀 Setting process launch path to /usr/bin/env")
        process.launchPath = "/usr/bin/env"
        
        queueStatusMessage("⚙️ Setting arguments: python3 -c 'import selenium'")
        process.arguments = ["python3", "-c", "import selenium"]
        
        queueStatusMessage("🔌 Creating pipe for capturing errors")
        let pipe = Pipe()
        process.standardError = pipe
        
        do {
            queueStatusMessage("▶️ Running process to test Selenium import")
            try process.run()
            process.waitUntilExit()
            
            let success = process.terminationStatus == 0
            queueStatusMessage(success ? "✅ Selenium is installed and importable" : "❌ Selenium import failed — not installed")
            return success
        } catch {
            queueStatusMessage("❌ Error occurred while checking Selenium: \(error.localizedDescription)")
            return false
        }
    }
    
    //Web DriverManager Check
    func isWebDriverManagerInstalled() -> Bool
    {
        queueStatusMessage("🔍 Starting WebDriver Manager check")
        
        queueStatusMessage("🛠️ Creating process to import webdriver_manager in Python")
        let process = Process()
        
        queueStatusMessage("🚀🚀 Setting process launch path to /usr/bin/env")
        process.launchPath = "/usr/bin/env"
        
        queueStatusMessage("⚙️ Setting arguments: python3 -c 'import webdriver_manager'")
        process.arguments = ["python3", "-c", "import webdriver_manager"]
        
        queueStatusMessage("🔌 Creating pipe for capturing errors")
        let pipe = Pipe()
        process.standardError = pipe
        
        do {
            queueStatusMessage("▶️ Running process to test webdriver_manager import")
            try process.run()
            process.waitUntilExit()
            
            let success = process.terminationStatus == 0
            queueStatusMessage(success ? "✅ WebDriver Manager is installed and importable" : "❌ WebDriver Manager import failed — not installed")
            return success
        } catch {
            queueStatusMessage("❌ Error occurred while checking WebDriver Manager: \(error.localizedDescription)")
            return false
        }
    }
    
    
}

// MARK: - System Check Wrappers & Chaining function
extension SetupViewController
{
    func runAllChecks()
    {
        runChromeCheck
        {
            self.runPythonCheck
            {
                self.runChromeDriverCheck
                {
                    self.runSeleniumCheck
                    {
                        self.runWebDriverCheck
                        {
                            let results = [
                                self.isChromeInstalled(),
                                self.isPythonInstalled(),
                                self.isChromeDriverInstalled(),
                                self.isSeleniumInstalled(),
                                self.isWebDriverManagerInstalled()
                            ]
                            self.summarizeSystemCheckResults(results)
                            print("✅ All system checks completed.")
                        }
                    }
                }
            }
        }
    }
    
    func runChromeCheck(completion: @escaping () -> Void)
    {
        let result = isChromeInstalled()
        startStatusMessageQueue
        {
            self.updateStatusIcon(self.chromeStatusIcon, isSuccess: result)
            completion()
        }
    }

    func runPythonCheck(completion: @escaping () -> Void)
    {
        let result = isPythonInstalled()
        startStatusMessageQueue
        {
            self.updateStatusIcon(self.pythonStatusIcon, isSuccess: result)
            completion()
        }
    }

    func runChromeDriverCheck(completion: @escaping () -> Void)
    {
        let result = isChromeDriverInstalled()
        startStatusMessageQueue
        {
            self.updateStatusIcon(self.chromeDriverIcon, isSuccess: result)
            completion()
        }
    }

    func runSeleniumCheck(completion: @escaping () -> Void)
    {
        let result = isSeleniumInstalled()
        startStatusMessageQueue
        {
            self.updateStatusIcon(self.seleniumIcon, isSuccess: result)
            completion()
        }
    }

    func runWebDriverCheck(completion: @escaping () -> Void)
    {
        let result = isWebDriverManagerInstalled()
        startStatusMessageQueue
        {
            self.updateStatusIcon(self.webDriverPluginIcon, isSuccess: result)
            completion()
        }
    }
}
