//
//  Shell.swift
//  Playground
//
//  Created by Kamaal M Farah on 22/07/2023.
//

import Foundation

#if os(macOS)
struct Shell {
    private init() { }

    enum Errors: Error {
        case standardError(message: String)
        case readPipeError(context: Error, pipe: PipeTypes)
    }

    enum PipeTypes {
        case output
        case error
    }

    static func zsh(_ command: String) -> Result<String, Errors> {
        shell("/bin/zsh", command)
    }

    static func runAppIconGenerator(input: Data, output: URL) -> Result<String, Errors> {
        let fileManager = FileManager.default
        let temporaryFileURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        try! input.write(to: temporaryFileURL)
        defer { try? cleanUp(fileURL: temporaryFileURL) }

        let appIconGeneratorPath = try! fileManager.findDirectoryOrFile(
            inDirectory: Bundle.main.resourceURL!,
            searchPath: "app-icon-generator"
        )!
            .relativePath
            .replacingOccurrences(of: " ", with: "\\ \\")
            .replacingOccurrences(of: ")", with: "\\)")
        let command = "\(appIconGeneratorPath) -o \(output.relativePath) -i \(temporaryFileURL.relativePath) -v"

        return zsh(command)
    }

    private static func shell(_ launchPath: String, _ command: String) -> Result<String, Errors> {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.arguments = ["-c", command]
        task.launchPath = launchPath
        task.launch()

        let errorData: Data?
        do {
            errorData = try errorPipe.fileHandleForReading.readToEnd()
        } catch {
            return .failure(.readPipeError(context: error, pipe: .error))
        }
        if let errorData, let errorString = String(data: errorData, encoding: .utf8) {
            return .failure(.standardError(message: errorString))
        }

        let outputData: Data?
        do {
            outputData = try outputPipe.fileHandleForReading.readToEnd()
        } catch {
            return .failure(.readPipeError(context: error, pipe: .output))
        }

        guard let outputData else { return .success("") }

        return .success(String(data: outputData, encoding: .utf8) ?? "")
    }

    private static func cleanUp(fileURL: URL) throws {
        try FileManager.default.removeItem(at: fileURL)
    }
}
#endif
