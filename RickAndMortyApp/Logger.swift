//
//  Logger.swift
//  RickAndMortyApp
//
//  Created by Ваня on 17.06.2022.
//

import Foundation

enum Level: Int {
    case info
    case debug
    case warning
    case error
    case fatal
}

protocol LoggerProtocol {
    func log(level: Level, message: String)
}

protocol Writer {
    func write(message: String)
}

final class ConsoleWriteer: Writer {
    func write(message: String) {
        print(message)
    }
}

final class FileWriter: Writer {
    var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    func write(message: String) {
        
        var filename = paths.first
        filename?.appendPathComponent("log.txt")
        if let handle = try? FileHandle(forWritingTo: filename!) {
            handle.seekToEndOfFile() // moving pointer to the end
            handle.write((message + "\n").data(using: .utf8)!) // adding content
            handle.closeFile() // closing the file
        }
    }
}

final class AppLogger: LoggerProtocol {
    private static let queue = DispatchQueue(label: "")
    
    private let writers: [Writer]
    private let minLevel: Level
    
    init(writers: [Writer], minLevel: Level) {
        self.writers = writers
        self.minLevel = minLevel
    }
    
    func log(level: Level, message: String) {
        for writer in writers {
            AppLogger.queue.async {
                let now = Date()
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.string(from: now)
                writer.write(message: "\(dateString) - \(message)")
            }
        }
    }
}

let logger: AppLogger = AppLogger(writers: [ConsoleWriteer()], minLevel: .info)

