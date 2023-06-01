//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/6/1.
//

import SwiftUI

public struct QuiverView: View {
    public let startPoint: CGPoint
    public let endPoint: CGPoint
    public let length: Double
    
    public var body: some View {
        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            let arrowWidth: CGFloat = 3.0
            let arrowHeight: CGFloat = 6.0
            
            let angle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
            
            let arrowPoint1 = CGPoint(x: endPoint.x - arrowWidth * cos(angle - .pi/4), y: endPoint.y - arrowHeight * sin(angle - .pi/4))
            let arrowPoint2 = CGPoint(x: endPoint.x - arrowWidth * cos(angle + .pi/4), y: endPoint.y - arrowHeight * sin(angle + .pi/4))
            
            path.move(to: endPoint)
            path.addLine(to: arrowPoint1)
            
            path.move(to: endPoint)
            path.addLine(to: arrowPoint2)
        }
        .stroke(lineWidth: 1)
        .foregroundColor(colorForLength(length))
    }
    
    private func colorForLength(_ length: Double) -> Color {
        let normalizedLength = (length + 10) / 20 // Normalize the length to the range of 0 to 1
        let hue = CGFloat(normalizedLength) // Set the hue value based on the normalized length
        
        return Color(hue: hue, saturation: 1.0, brightness: 1.0)
    }
}

public struct GridView: View {
    public let grid: Grid
    public let blockSize: CGFloat
    
    public var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(grid.columns)
            let cellHeight = geometry.size.height / CGFloat(grid.rows)
            ForEach(0..<grid.rows, id: \.self) { row in
                ForEach(0..<grid.columns, id: \.self) { column in
                    let element = grid[row, column]
                    let startPoint = CGPoint(x: CGFloat(column) * cellWidth + cellWidth / 2, y: CGFloat(row) * cellHeight + cellHeight / 2)
                    let endPoint = CGPoint(x: startPoint.x + CGFloat(element.0) * cellWidth / blockSize , y: startPoint.y + CGFloat(element.1) * cellHeight / blockSize )
                    
                    QuiverView(startPoint: startPoint, endPoint: endPoint, length: sqrt(Double(element.0 * element.0 + element.1 * element.1)) * cellHeight / blockSize )
                        .frame(width: cellWidth, height: cellHeight)
                }
            }
        }
    }
}

public struct ContentView: View {
    public let blockSize: CGFloat
    public let grid: Grid
    public init(blockSize: Int, grid: Grid) {
        self.blockSize = CGFloat(blockSize)
        self.grid = grid
    }
    
    public var body: some View {
        GridView(grid: grid, blockSize: blockSize)
            .frame(width: 600, height: 400)
    }
}
