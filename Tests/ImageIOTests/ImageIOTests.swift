import XCTest
@testable import MyImageIO

final class ImageIOTests: XCTestCase {
    func testExample() throws {
        let fileManager = FileManager.default
        let mainURL = URL(filePath: #file).deletingLastPathComponent()
        let resultDirectory = mainURL.appending(path: "Results/")
        
        let srcURL = Bundle.module.url(forResource: "22", withExtension: "png", subdirectory: "Resources")
        let destURL = resultDirectory.appending(component: "fig02.png")
        
        if let src = srcURL {
            fileManager.createFile(atPath: destURL.relativePath, contents: try? Data(contentsOf: src))
        }
        
        guard var urls = try? fileManager.contentsOfDirectory(at: destURL.deletingLastPathComponent(), includingPropertiesForKeys: nil) else {
            fatalError("file write error")
        }
        XCTAssertEqual(destURL, urls.first)
        
        try fileManager.removeItem(at: destURL)
        urls = try! fileManager.contentsOfDirectory(at: destURL.deletingLastPathComponent(), includingPropertiesForKeys: nil)
        XCTAssertTrue(urls.isEmpty)
    }
    
    func testGetImage() throws {
        guard let srcURL = Bundle.module.url(forResource: "22", withExtension: "png", subdirectory: "Resources") else {
            fatalError("Can't locate Image")
        }
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTClockMetric(), XCTStorageMetric()]) {
            guard let image = getImageFrom(contentsOf: srcURL) else{
                fatalError("Can't get image")
            }
            let _ = grayMatrix(of: image)
        }
    }
    
    
}
