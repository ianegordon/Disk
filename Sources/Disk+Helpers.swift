//
//  Disk+Helpers.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Get URL for existing file
    ///
    /// - Parameters:
    ///   - name: name given to file
    ///   - directory: directory the file is saved in
    /// - Returns: URL pointing to file/folder
    /// - Throws: Error if no file could be found or too many files were found
    static func getURL(for path: String?, in directory: Directory) throws -> URL {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            return url
        } catch {
            throw error
        }
    }
    
    /// Clear directory by removing all files
    ///
    /// - Parameter directory: directory to clear
    /// - Throws: Error if File Manager cannot remove a file
    static func clear(_ directory: Directory) throws {
        do {
            let url = try createURL(for: nil, in: directory)
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            throw error
        }
    }
    
    /// Remove file from file system
    ///
    /// - Parameters:
    ///   - name: name given to file when stored
    ///   - directory: directory where file is located
    /// - Throws: Error if file could not be removed
    static func remove(_ path: String, from directory: Directory) throws {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            try FileManager.default.removeItem(at: url)
        } catch {
            throw error
        }
    }
    
    /// Checks if a file exists
    ///
    /// - Parameters:
    ///   - name: name given to file when stored
    ///   - directory: directory where file is located
    /// - Returns: Bool indicating whether file exists
    static func exists(_ path: String, in directory: Directory) -> Bool {
        if let _ = try? getExistingFileURL(for: path, in: directory) {
            return true
        } else {
            let suffix = path.suffix(1).lowercased()
            if suffix != "/" {
                let folderPath = path + "/"
                if let _ = try? getExistingFileURL(for: folderPath, in: directory) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Sets the 'do not backup' attribute of the file or folder on disk to true. This ensures that the file holding the object data does not get deleted when the user's device has low storage, but prevents this file from being stored in any backups made of the device on iTunes or iCloud.
    /// This is only useful for excluding cache and other application support files which are not needed in a backup. Some operations commonly made to user documents will cause the 'do not backup' property to be reset to false and so this should not be used on user documents.
    /// Warning: You must ensure that you will purge and handle any files created with this attribute appropriately, as these files will persist on the user's disk even in low storage situtations. If you don't handle these files appropriately, then you aren't following Apple's file system guidlines and can face App Store rejection.
    /// Ideally, you should let iOS handle deletion of files in low storage situations, and you yourself handle missing files appropriately (i.e. retrieving an image from the web again if it does not exist on disk anymore.)
    ///
    /// - Parameters:
    ///   - name: name given to file when stored
    ///   - directory: directory where file is located
    /// - Throws: Error if file could not set its 'isExcludedFromBackup' property
    static func doNotBackup(_ path: String?, in directory: Directory) throws {
        do {
            try setIsExcludedFromBackup(to: true, for: path, in: directory)
        } catch {
            throw error
        }
    }
    
    /// Sets the 'do not backup' attribute of the file or folder on disk to false. This is the default behaviour so you don't have to use this function unless you already called doNotBackup(name:directory:) on a specific file.
    /// This default backing up behaviour allows anything in the .documents and .caches directories to be stored in backups made of the user's device (on iCloud or iTunes)
    ///
    /// - Parameters:
    ///   - name: name given to file when stored
    ///   - directory: directory where file is located
    /// - Throws: Error if file could not set its 'isExcludedFromBackup' property
    static func backup(_ path: String?, in directory: Directory) throws {
        do {
            try setIsExcludedFromBackup(to: false, for: path, in: directory)
        } catch {
            throw error
        }
    }
    
    /// Move file to a new directory
    ///
    /// - Parameters:
    ///   - name: name given to file stored
    ///   - directory: directory the file is currently in
    ///   - newDirectory: new directory to store file in
    /// - Throws: Error if file could not be moved
    static func move(_ path: String, in directory: Directory, to newDirectory: Directory) throws {
        do {
            let currentUrl = try getExistingFileURL(for: path, in: directory)
            let justDirectoryPath = try createURL(for: nil, in: directory).absoluteString
            let filePath = currentUrl.absoluteString.replacingOccurrences(of: justDirectoryPath, with: "")
            let newUrl = try createURL(for: filePath, in: newDirectory)
            try createSubfoldersBeforeCreatingFile(at: newUrl)
            try FileManager.default.moveItem(at: currentUrl, to: newUrl)
        } catch {
            throw error
        }
    }
    
    /// Rename a file
    ///
    /// - Parameters:
    ///   - name: original name given to file
    ///   - directory: directory the file is in
    ///   - newName: new name to give to file
    /// - Throws: Error if object could not be renamed
    static func rename(_ path: String, in directory: Directory, to newPath: String) throws {
        do {
            let currentUrl = try getExistingFileURL(for: path, in: directory)
            let justDirectoryPath = try createURL(for: nil, in: directory).absoluteString
            var currentFilePath = currentUrl.absoluteString.replacingOccurrences(of: justDirectoryPath, with: "")
            // workaround for dealing with renaming folders
            if isFolder(currentUrl) && currentFilePath.suffix(1) != "/" {
                currentFilePath = currentFilePath + "/"
            }
            let currentValidFilePath = try getValidFilePath(from: path)
            let newValidFilePath = try getValidFilePath(from: newPath)
            let newFilePath = currentFilePath.replacingOccurrences(of: currentValidFilePath, with: newValidFilePath)
            let newUrl = try createURL(for: newFilePath, in: directory)
            try createSubfoldersBeforeCreatingFile(at: newUrl)
            try FileManager.default.moveItem(at: currentUrl, to: newUrl)
        } catch {
            throw error
        }
    }
}