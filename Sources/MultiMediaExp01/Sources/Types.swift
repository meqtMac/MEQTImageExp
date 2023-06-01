//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/6/1.
//

import MEQT
public typealias Matrix = MEQTMatrix<Double>
public typealias Vector = MEQTVector<Double>

import MyImageIO
import Foundation

/// convient function to open a image with a name, currently support .png file only.
public func grayMatrix(of name: String, subdirectory: String = "Resources") ->  Matrix?  {
    if let imageURL = Bundle.module.url(forResource: name, withExtension: "", subdirectory: subdirectory) {
        return grayMatrix(of: getImageFrom(contentsOf: imageURL))
    }
    return nil
}

/// storage of motion compensate vector
public struct Grid: MEQTMatrixProtocol {
    public init(rows: Index, columns: Index, repeating: Element) {
        self.init(rows: rows, columns: columns)
        for i in 0..<rows*columns {
            data[i] = repeating
        }
    }
    
    public init(_ rows: Index, _ columns: Index, _ repeating: Element) {
        self.init(rows: rows, columns: columns, repeating: repeating)
    }
    
    public init(rows: Index, columns: Index, initializer: (inout UnsafeMutableBufferPointer<(Int, Int)>) -> Void) {
        self.init(rows: rows, columns: columns)
        self.data.withUnsafeMutableBufferPointer { buffer in
            initializer(&buffer)
        }
    }
    public var count: Index { rows * columns }
    public var data: [(Int, Int)]
    public var rows: Index
    public var columns: Index
    public typealias Element = (Int, Int)
    public var description: String {
        let maxRows = min(rows, 8)
        let maxColumns = min(columns, 8)
        //        let maxRows = rows
        //        let maxColumns = columns
        var result = ""
        
        result += "(\(rows), \(columns))\n"
        
        for i in 0..<maxRows {
            for j in 0..<maxColumns {
                let index = i * columns + j
                let value = data[index]
                
                result += "(\(value.0),\(value.1))"
            }
            
            if columns > maxColumns {
                result += "⋯\t"
            }
            result += "\n"
        }
        
        if rows > maxRows {
            for _ in 0..<maxColumns {
                result += "⋮\t"
            }
            if columns > maxColumns {
                result += "⋱\n"
            }
        }
        return result
    }
    
    init(rows: Int, columns: Int) {
        precondition(rows > 0 && columns > 0, "rows and columns must be positive")
        self.rows = rows
        self.columns = columns
        self.data = [(Int, Int)](unsafeUninitializedCapacity: rows*columns, initializingWith: { buffer, initializedCount in
            initializedCount = rows*columns
        })
    }
}
