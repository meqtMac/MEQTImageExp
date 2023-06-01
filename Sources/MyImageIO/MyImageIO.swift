import Accelerate
import CoreGraphics
import MEQT

/// local an image inside's swift package manager's target's resource ( passed in using parameter resources: [])
/// - Parameters: url of the image
/// - Returns: cgImage
public func getImageFrom(contentsOf url: URL) -> CGImage? {
    if url.pathExtension == "png" {
        if let dataProvider = CGDataProvider(url: url as CFURL) {
            return CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        }
    }else{
        print("\(url.pathExtension) unsupported yet")
        return nil
    }
    return nil
}

/// create an matirx of double containing gray information of the cgImage, the val ranges from 0.0 to 255.0
/// - Parameter cgImage: image source of width\* height
/// - Returns: gray scale matrix where `rows` = `height`, `columns`=`width`
public func grayMatrix(of cgImage: CGImage) -> MEQTMatrix<Double>? {
   guard let format = vImage_CGImageFormat(cgImage: cgImage) else {
        return nil
    }
    
    guard var sourceImageBuffer = try? vImage_Buffer(cgImage: cgImage, format: format) else {
        return nil
    }
    
    defer {
        sourceImageBuffer.free()
    }
    
    let width = Int(sourceImageBuffer.width)
    let height = Int(sourceImageBuffer.height)
    
    guard var destinationBuffer = try? vImage_Buffer(
        width: Int(sourceImageBuffer.width),
        height: Int(sourceImageBuffer.height),
        bitsPerPixel: 8) else {
        return nil
    }
    
    defer {
        destinationBuffer.free()
    }
    
    // Declare the three coefficients that model the eye's sensitivity
    // to color.
    let redCoefficient: Float = 0.2126
    let greenCoefficient: Float = 0.7152
    let blueCoefficient: Float = 0.0722
    
    // Create a 1D matrix containing the three luma coefficients that
    // specify the color-to-grayscale conversion.
    let divisor: Int32 = 0x1000
    let fDivisor = Float(divisor)
    
    var coefficientsMatrix = [
        Int16(redCoefficient * fDivisor),
        Int16(greenCoefficient * fDivisor),
        Int16(blueCoefficient * fDivisor)
    ]
    
    let preBias: [Int16] = [0, 0, 0, 0]
    let postBias: Int32 = 0
    
    vImageMatrixMultiply_ARGB8888ToPlanar8(
        &sourceImageBuffer,
        &destinationBuffer,
        &coefficientsMatrix,
        divisor,
        preBias,
        postBias,
        vImage_Flags(kvImageNoFlags)
    )
    
    let mat = MEQTMatrix<Double>(rows: height, columns: destinationBuffer.rowBytes) { buffer in
        // mind that the vImage buffer's alignment, rowBytes may not be equal to width
        let unsafeBufferPointer = UnsafeMutableBufferPointer<UInt8>(
            start: destinationBuffer.data.bindMemory(
                to: UInt8.self,
                capacity: destinationBuffer.rowBytes*height
            ),
            count: destinationBuffer.rowBytes*height
        )
        
        vDSP.convertElements(of: unsafeBufferPointer, to: &buffer)
    }
    // cut row bytes padding
    return mat[0..<height, 0..<width]
}

/// image grayscale information visualization
extension MEQTMatrix<Double>: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        grayImage as Any
    }
    
    /// visual matrix with gray scale image, double value are converted to UInt8 with `towardNearestInteger` rounding.
    var grayImage: CGImage? {
        
        guard let monoFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            renderingIntent: .defaultIntent) else {
            return nil
        }
        
        var tempPtr = [UInt8](unsafeUninitializedCapacity: self.rows * self.columns) { buffer, initializedCount in
            initializedCount = self.rows * self.columns
        }
        
        vDSP.convertElements(of: self.data, to: &tempPtr, rounding: .towardNearestInteger)
        
        return tempPtr.withUnsafeMutableBytes { buffer in
            let ptr = buffer.baseAddress!
            
            let imageBuffer = vImage_Buffer(data: ptr,
                                            height: UInt(self.rows),
                                            width: UInt(self.columns),
                                            rowBytes: self.columns
            )
            
            return try? imageBuffer.createCGImage(format: monoFormat)
        }
    }
    
}
