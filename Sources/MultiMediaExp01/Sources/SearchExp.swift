//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/6/1.
//

import Foundation

public struct SearchExp {
    let searchMethod: (Matrix, Matrix, Int, Int, (Matrix, Matrix) -> Matrix.Element ) -> (Grid, Int)
    let diffMethod: (Matrix, Matrix) -> Double = sad
    let blockSize = 8
    
    public init(name: String, steps: [Int], searchMethod: @escaping (Matrix, Matrix, Int, Int, (Matrix, Matrix) -> Double ) -> (Grid, Int)) {
        self.name = name
        self.steps = steps
        self.searchMethod = searchMethod
    }
    
    let steps: [Int]
    let name: String
    var counts: [Int] = []
    var times: [SuspendingClock.Duration] = []
    var diffs: [Double] = []
    
    public mutating func measure(source: Matrix, reference: Matrix) {
        // clear result
        counts = []
        times = []
        diffs = []
        let clock = SuspendingClock()
        for step in steps {
            let timeFPS = clock.measure {
                let (motionVector, count) = searchMethod(source, reference, blockSize, step, diffMethod)
                let imgCompensation = motionCompensation(with: reference, grid: motionVector, blockSize: blockSize)
                let diff = diffMethod(source, imgCompensation)
                counts.append(count)
                diffs.append(diff)
            }
            times.append(timeFPS)
        }
    }
    
    public var report: String {
        var result = name + "\n"
        result += "\tsize count\tdiff\t\ttime\n"
        for i in steps.indices {
            result += "\t\(steps[i])\t \(counts[i])\t\(diffs[i])\t\(times[i])\n"
        }
        return result
    }
}
