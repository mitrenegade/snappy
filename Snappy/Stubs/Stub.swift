import UIKit
import SwiftUI

enum Stub: String {
    case plants
    case snaps
    case photos
    case user

    // MARK: - Properties

    var file: String {
        "\(fileName).\(fileExtension)"
    }

    private var fileName: String {
        switch self {
        case .plants:
            return "plantData"
        case .snaps:
            return "snapData"
        case .photos:
            return "photoData"
        case .user:
            return rawValue
        }
    }

    private var fileExtension: String {
        "json"
    }


    static var photoData: [Photo] { Stub.load(.photos) }
    static var plantData: [Plant] { Stub.load(.plants) }
    static var snapData: [Snap] { Stub.load(.snaps) }

    static var testUser: User = Stub.load(.user)

    static func load<T: Decodable>(_ stub: Stub) -> T {
        let filename = stub.file
        let data: Data = loadJSONData(filename: filename)
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    static func loadJSONData(filename: String) -> Data {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            let data = try Data(contentsOf: file)
            return data
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
    }
}
