//
//  Utils.swift
//  AppStabilityUITests
//
//  Created by wang_wang164@163.com on 2022/2/20.
//

import XCTest
import ZipArchive

class Utils: NSObject {
    
    static let logSavingPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Logs"
    
    static func saveImagesToFiles(images: [Int: Data], name: String = "screenshot") {
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = "\(logSavingPath)/screenshots"
        do {
            try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating images directory: \(error)")
        }
        for key in images.keys {
            let fileName = "\(name)\(key).png"
            let fileURL = URL(fileURLWithPath: "\(filePath)/\(fileName)")
            
            do {
                try images[key]!.write(to: fileURL)
            } catch {
                print("Error saving image to file: \(error)")
            }
        }
    }
    
    static func drawRectOnImage(image: UIImage, rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(at: CGPoint.zero)
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)
        context.stroke(rect)
        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return modifiedImage
    }
    
    static func zip(folderPath: String, zipFilePath: String) -> Bool {
        let success = SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: folderPath)
        if success {
            print("Compression succeeded: \(zipFilePath)")
        }
        return success
    }
    
    static func clearFolder(atPath path: String) throws {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: path)
        for content in contents {
            let fullPath = "\(path)/\(content)"
            try fileManager.removeItem(atPath: fullPath)
        }
    }
    
    static func log(_ message: String) {
        print(message)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: logSavingPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating images directory: \(error)")
        }
        var fileURL: URL
        if #available(iOS 16.0, *) {
            fileURL = URL.init(filePath: logSavingPath).appendingPathComponent("log.txt")
        } else {
            fileURL = URL.init(fileURLWithPath: logSavingPath).appendingPathComponent("log.txt")
        }
        do {
            try "\(dateString) \(message)".appendLineToURL(fileURL: fileURL)
        } catch {
            print("Error writing to log file: \(error)")
        }
    }

    static func error(_ message: String) {
        print("Error: \(message)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: logSavingPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating images directory: \(error)")
        }
        var fileURL: URL
        if #available(iOS 16.0, *) {
            fileURL = URL.init(filePath: logSavingPath).appendingPathComponent("log.txt")
        } else {
            fileURL = URL.init(fileURLWithPath: logSavingPath).appendingPathComponent("log.txt")
        }
        do {
            try "\(dateString) \(message)".appendLineToURL(fileURL: fileURL)
        } catch {
            print("Error writing to log file: \(error)")
        }
    }

}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.appendToURL(fileURL: fileURL)
    }
}

extension Data {
    func appendToURL(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

