//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/6/1.
//

import MEQT

/// calculate sum of absolute difference of two grayscale matrix of same size
/// - Parameters:
///   - lhs: source image grayscale matrix
///   - rhs: destination image grayscale matrix
/// - Returns: sum of absoulte difference
public func sad(_ lhs: Matrix, _ rhs: Matrix) -> Double {
    return sum( absolute(lhs - rhs))
}

/// generate source with reference by assigning each block `s[i*blockSize, j*blockSize]` with `ref[i*blockSize+grid[i,j].0, j*blockSize+gird[i,j].1]`
/// - Parameters:
///   - referenceImage: image regenerate source
///   - grid: move vector from source to reference
///   - blockSize: block size
/// - Returns: regenerated image gray scale matrix
public func motionCompensation(with referenceImage: Matrix, grid: Grid, blockSize: Int) -> Matrix {
    let rows = referenceImage.rows
    let columns = referenceImage.columns
    let blockRows = rows/blockSize
    let blockColumns = columns/blockSize
    precondition( blockRows * blockSize <= rows && blockColumns * blockSize <= columns, "image overflow" )
    precondition( blockRows == grid.rows && blockColumns == grid.columns, "grid, block and image unmatch ")
    
    // empty a matrix with same shape as reference
    var source = referenceImage.shapeClone()
    
    for i in 0..<blockRows {
        for j in 0..<blockColumns {
            // shift in row and column by pixels
            let (rowShift, columnShift) = grid[i, j]
            // block range  of source
            let sourceRows = i*blockSize..<(i+1)*blockSize
            let sourceColumns = j*blockSize..<(j+1)*blockSize
            // block range of reference
            let refRows = ( i*blockSize + rowShift) ..< ( (i+1) * blockSize + rowShift )
            let refColumns = ( j*blockSize + columnShift ) ..< ( (j+1) * blockSize + columnShift )
            // copy by block, overflow is managed inside assignment
            source[sourceRows, sourceColumns] = referenceImage[refRows, refColumns]
        }
    }
    
    return source
}

/// full path search
/// - Parameters:
///   - source: image to be encoder
///   - reference: image to be referenced
///   - blockSize: prediction block size
///   - stepSize: step size
///   - diff: difference calculation method
/// - Returns: move vector grid and counts of diff method calling
public func fullPathSearch(from source: Matrix, to reference: Matrix, blockSize: Int, stepSize: Int,  diff: (Matrix, Matrix) -> Matrix.Element ) -> (Grid, Int) {
    precondition(source.rows == reference.rows && source.columns == reference.columns, "source and reference must be of same size")
    let rows = source.rows
    let columns = source.columns
    let blockSize = blockSize
    precondition(rows % blockSize == 0 && columns % blockSize == 0, "blockSize invaild")
    let blockRows = rows/blockSize
    let blockColumns = columns/blockSize
    
    var diffCount: Int = 0
    
    var grid = Grid(blockRows, blockColumns, (0, 0))
    
    for i in 0..<blockRows {
        for j in 0..<blockColumns {
            // grid diff, use -1 to mark uncalucated
            var gridDiff = -1.0
            // block of source
            let sourceRows = i*blockSize..<(i+1)*blockSize
            let sourceColumns = j*blockSize..<(j+1)*blockSize
            let sourceBlock = source[sourceRows, sourceColumns]
            
            for xShift in -stepSize...stepSize {
                let refRows = ( i*blockSize + xShift)..<( (i+1) * blockSize + xShift)
                // shift invadi
                if refRows.lowerBound < 0 || refRows.upperBound >= reference.rows {
                    continue
                }
                for yShift in -stepSize...stepSize {
                    // block of reference with shift pass in grid
                    let refColumns = ( j*blockSize + yShift)..<( (j+1) * blockSize + yShift)
                    /// column shift in valid
                    if refColumns.lowerBound < 0 || refColumns.upperBound >= reference.columns {
                        continue
                    }
                    let refBlock = reference[refRows, refColumns]
                    let currentDiff = diff(sourceBlock, refBlock)
                    diffCount += 1
                    if gridDiff == -1 || currentDiff < gridDiff {
                        grid[i, j] = (xShift, yShift)
                        gridDiff = currentDiff
                    }
                }
            }
        }
    }
    
    return (grid, diffCount)
}

/// three step search
/// - Parameters:
///   - source: image to be encoder
///   - reference: image to be referenced
///   - blockSize: prediction block size
///   - stepSize: step size
///   - diff: difference calculation method
/// - Returns: move vector grid and counts of diff method calling
public func threeStepSearch(from source: Matrix, to reference: Matrix, blockSize: Int, stepSize: Int,  diff: (Matrix, Matrix) -> Matrix.Element ) -> (Grid, Int) {
    precondition(source.rows == reference.rows && source.columns == reference.columns, "source and reference must be of same size")
    let rows = source.rows
    let columns = source.columns
    let blockSize = blockSize
    precondition(rows % blockSize == 0 && columns % blockSize == 0, "blockSize invaild")
    let blockRows = rows/blockSize
    let blockColumns = columns/blockSize
    
    var diffCount: Int = 0
    
    var grid = Grid(blockRows, blockColumns, (0, 0))
    
    let directions = [(0, 0), (0, 1), (0, -1), (1, 0), (1, 1), (1, -1), (-1, 0), (-1, 1), (-1, -1) ]
    
    for i in 0..<blockRows {
        for j in 0..<blockColumns {
            /// grid diff, use -1 to mark uncalucated
            var gridDiff = -1.0
            /// block of source
            let sourceRows = i*blockSize..<(i+1)*blockSize
            let sourceColumns = j*blockSize..<(j+1)*blockSize
            let sourceBlock = source[sourceRows, sourceColumns]
            
            var currentStep = stepSize
            
            // divide currentStep by two each iteration
            while currentStep > 0 {
                for direction in directions {
                    // row, column shift candiate
                    let xShift = direction.0 * currentStep
                    let yShift = direction.1 * currentStep
                    // row and column range for reference
                    let refRows = ( i*blockSize + xShift) ..< ( (i+1) * blockSize + xShift)
                    let refColumns = ( j*blockSize + yShift) ..< ( (j+1) * blockSize + yShift)
                    
                    // check if range is vaild
                    if refRows.lowerBound < 0 || refRows.upperBound >= reference.rows { continue }
                    if refColumns.lowerBound < 0 || refColumns.upperBound >= reference.columns { continue }
                    
                    // reference block
                    let refBlock = reference[refRows, refColumns]
                    // calcuate diff between source block and reference block
                    let currentDiff = diff(sourceBlock, refBlock)
                    diffCount += 1
                    // update diff and grid
                    if gridDiff == -1 || currentDiff < gridDiff {
                        grid[i, j] = (xShift, yShift)
                        gridDiff = currentDiff
                    }
                }
                // update step size
                currentStep /= 2
            }
        }
    }
    
    return (grid, diffCount)
}

