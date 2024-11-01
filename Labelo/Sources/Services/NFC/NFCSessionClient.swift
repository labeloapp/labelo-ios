import Foundation
import ComposableArchitecture
import SwiftData

@DependencyClient
struct NFCSessionClient {
    var write: @Sendable (_ tag: Tag) async throws -> Void
    var read: @Sendable () async throws -> ReadResult
}

extension NFCSessionClient {
    enum ReadResult: Equatable {
        case text(String)
        case url(URL)
        case unknown
        case empty
    }
}

enum NFCSessionClientError: Swift.Error {
    case tagNumberNotOne
    case failed(_ underlayingError: Swift.Error)
    case tagIsReadOnly
    case tagIsNotSupported
    case dataTooLarge
    case deviceNoSupported
    case tagIsNotValid
    case connectionError
    case readError
    case failedToCreateSession
    case invalidWriteData
}

extension NFCSessionClient: DependencyKey {
    static let liveValue = NFCSessionClient.live
}

extension DependencyValues {
    var nfcSession: NFCSessionClient {
        get { self[NFCSessionClient.self] }
        set { self[NFCSessionClient.self] = newValue }
    }
}


