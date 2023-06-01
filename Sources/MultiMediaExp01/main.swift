//
//  File.swift
//  
//
//  Created by 蒋艺 on 2023/6/1.
//

//import Foundation
import MEQT

let steps = [2, 4, 5, 6, 7, 8, 9, 10, 16, 24, 32]
var fullPathExp = SearchExp(name: "Full Path", steps: steps, searchMethod: fullPathSearch)
var threeStepExp = SearchExp(name: "Three Step", steps: steps, searchMethod: threeStepSearch)

let imgSrc = grayMatrix(of: "21.png")!
let imgRef = grayMatrix(of: "22.png")!

fullPathExp.measure(source: imgSrc, reference: imgRef)
threeStepExp.measure(source: imgSrc, reference: imgRef)
print(fullPathExp.report)
print(threeStepExp.report)

#if canImport(PlaygroundSupport)
let (mvFPS, _) = fullPathSearch(from: imgSrc, to: imgRef, blockSize: 8, stepSize: 8, diff: sad)
let imgCmpFPS = motionCompensation(with: imgRef, grid: mvFPS, blockSize: 8)
absolute(imgCmpFPS - imgSrc)

let (mvTSS, _) = fullPathSearch(from: imgSrc, to: imgRef, blockSize: 8, stepSize: 8, diff: sad)
let imgCmpTSS = motionCompensation(with: imgRef, grid: mvFPS, blockSize: 8)
absolute(imgCmpTSS - imgSrc)

import PlaygroundSupport
PlaygroundPage.current.setLiveView(
    ContentView(blockSize: 8, grid: mvTSS)
)
#endif
