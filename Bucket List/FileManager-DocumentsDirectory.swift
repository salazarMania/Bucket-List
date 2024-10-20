//
//  FileManager-DocumentsDirectory.swift
//  Bucket List
//
//  Created by SANIYA KHATARKAR on 20/10/24.
//

import Foundation

extension FileManager{
    static var documentsDirectory : URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
