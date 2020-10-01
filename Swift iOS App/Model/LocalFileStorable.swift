//
//  LocalFileStorable.swift
//  XpenseModel
//
//  Created by Paul Schmiedmayer on 10/10/19.
//  Copyright © 2019 TUM LS1. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - LocalFileStorable
/// An object that can be represented and stored as a local file
protocol LocalFileStorable: Codable {
    static var fileName: String { get }
}

// MARK: Extension: LocalFileStorable: URL
extension LocalFileStorable {
    
    /// The URL of the parent folder to store the LocalFileStorable in
    static func localStorageURL(path: String) -> URL {
        guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can't access the document directory in the user's home directory.")
        }
        return documentsDirectory.appendingPathComponent(path).appendingPathExtension("json")
    }
}

// MARK: Extension: LocalFileStorable: Load & Save
extension LocalFileStorable {
    
    /**
     Load an array of LocalFileStorables from a file
     - returns: An array of deserialised objects
     */
    static func loadFromFile(from path: String) -> [Self] {
        do {
            let fileWrapper = try FileWrapper(url: localStorageURL(path: path), options: .immediate)
            guard let data = fileWrapper.regularFileContents else {
                throw NSError()
            }
            
            //print("trying to decode")
            var test: [Self] = []
            do {
                test = try JSONDecoder().decode([Self].self, from: data)
            } catch {
                print(error)
            }
            return test
        } catch _ {
            print("Could not load \(Self.self)s, the Model uses an empty collection")
            return []
        }
    }
    
    /**
     Save a collection of LocalFileStorables to a file
     - parameters:
        - collection: Collection of objects to be saved
     */
    static func saveToFile(_ collection: [Self], to path: String) {
        do {
            
            /*
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let dataOld = try encoder.encode(collection)
            print(String(data: dataOld, encoding: .utf8)!)
            */            
 
            let data = try JSONEncoder().encode(collection)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: localStorageURL(path: path), options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
        } catch _ {
            print("Could not save \(Self.self)s")
        }
    }
}

// MARK: Extension: Array: Save
extension Array where Element: LocalFileStorable {
    
    /// Saves an array of LocalFileStorables to a file
    func saveToFile(path: String) {
        Element.saveToFile(self, to: path)
    }
}
