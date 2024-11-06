import Foundation
import CoreNFC
import ComposableArchitecture

extension NFCSessionClient {
    static var live: NFCSessionClient {
        let liveNFCSession = LiveNFCSession()

        return NFCSessionClient { data in
            try await liveNFCSession.write(data)
        } read: {
            let string = try await liveNFCSession.read()
            return string
        }
    }
}

final class LiveNFCSession: NSObject {
    private var writerSession: NFCNDEFReaderSession!
    private var readerSession: NFCTagReaderSession!
    private var continuation: UnsafeContinuation<Void, Swift.Error>?
    private var readerContinuation: UnsafeContinuation<NFCSessionClient.ReadResult, Swift.Error>?
    private var tagToWrite: Tag?

    override init() {
        super.init()
    }

    func write(_ tag: Tag) async throws -> Void {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NFCSessionClientError.deviceNoSupported
        }

        writerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        tagToWrite = tag

        try await withUnsafeThrowingContinuation { continuation in
            self.continuation = continuation
            self.writerSession.begin()
        }

        writerSession.alertMessage = "Tag write success."
        writerSession.invalidate()
        tagToWrite = nil
    }

    func read() async throws -> NFCSessionClient.ReadResult {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NFCSessionClientError.deviceNoSupported
        }

        guard let session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self) else {
            throw NFCSessionClientError.failedToCreateSession
        }

        self.readerSession = session

        let result: NFCSessionClient.ReadResult = try await withUnsafeThrowingContinuation { continuation in
            self.readerContinuation = continuation
            self.readerSession.begin()
        }

        readerSession.alertMessage = "Tag read success."
        readerSession.invalidate()

        return result
    }
}

// MARK: NFCNDEFReaderSessionDelegate
extension LiveNFCSession: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Become active
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Do not add code in this function. This method isn't called
        // when you provide `reader(_:didDetect:)`.
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Detected more than one tag")
            continuation?.resume(throwing: NFCSessionClientError.tagNumberNotOne)
            continuation = nil
            tagToWrite = nil
            return
        }

        let tag = tags.first!

        session.connect(to: tag) { error in
            if error != nil  {
                session.restartPolling()
                return
            }

            tag.queryNDEFStatus { [weak self] status, capacity, error in

                guard let self else { return }

                if let error {
                    session.invalidate()
                    self.continuation?.resume(throwing: NFCSessionClientError.failed(error))
                    self.continuation = nil
                    tagToWrite = nil
                    return
                }

                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                    self.continuation?.resume(throwing: NFCSessionClientError.tagIsNotSupported)
                    self.continuation = nil
                    tagToWrite = nil
                case .readWrite:
                    guard let tagToWrite else {
                        session.invalidate(errorMessage: "Invalid write data.")
                        self.continuation?.resume(throwing: NFCSessionClientError.invalidWriteData)
                        self.continuation = nil
                        return
                    }

                    guard let payload = nfcNDEFPayload(from: tagToWrite) else {
                        session.invalidate(errorMessage: "Invalid write data.")
                        self.continuation?.resume(throwing: NFCSessionClientError.invalidWriteData)
                        self.continuation = nil
                        self.tagToWrite = nil
                        return
                    }

                    let message = NFCNDEFMessage(records: [payload])

                    guard message.length <= capacity else {
                        session.invalidate(errorMessage: "Tag capacity is too small. Minimum size requirement is \(message.length) bytes.")
                        self.continuation?.resume(throwing: NFCSessionClientError.dataTooLarge)
                        self.continuation = nil
                        self.tagToWrite = nil
                        return
                    }

                    tag.writeNDEF(message) { [weak self] error in
                        guard let self else { return }
                        if let error {
                            session.invalidate(errorMessage: "Error writing to tag: \(error.localizedDescription)")
                            self.continuation?.resume(throwing: NFCSessionClientError.failed(error))
                            self.continuation = nil
                            return
                        }

                        self.continuation?.resume()
                        self.continuation = nil
                        self.tagToWrite = nil
                    }
                case .readOnly:
                    session.invalidate(errorMessage: "Tag is not writable.")
                    self.continuation?.resume(throwing: NFCSessionClientError.tagIsReadOnly)
                    self.continuation = nil
                    self.tagToWrite = nil
                default:
                    session.invalidate(errorMessage: "Invalid tag status.")
                    self.continuation?.resume(throwing: NFCSessionClientError.tagIsReadOnly)
                    self.continuation = nil
                    self.tagToWrite = nil
                }
            }
        }
    }

    private func nfcNDEFPayload(from tag: Tag) -> NFCNDEFPayload? {
        let jsonEncoder = JSONEncoder()

        if let tagData = try? jsonEncoder.encode(tag) {
            let payload = NFCNDEFPayload(
                format: .nfcExternal,
                type: tagData,
                identifier: "app.labelo".data(
                    using: .utf8
                )!,
                payload: tagData
            )
            return payload
        }

        return nil
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        if let continuation {
            continuation.resume(throwing: NFCSessionClientError.failed(error))
            self.continuation = nil
        }
    }
}

// MARK: NFCTagReaderSession
extension LiveNFCSession: NFCTagReaderSessionDelegate {

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // Become active
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard tags.count == 1 else {
            session.alertMessage = "More than 1 tags was found. Please present only 1 tag."
            session.restartPolling()
            return
        }

        let tag = tags.first!

        var ndefTag: NFCNDEFTag

        switch tags.first! {
        case let .iso7816(tag):
            ndefTag = tag
        case let .feliCa(tag):
            ndefTag = tag
        case let .iso15693(tag):
            ndefTag = tag
        case let .miFare(tag):
            ndefTag = tag
        @unknown default:
            session.invalidate(errorMessage: "Tag not valid.")
            readerContinuation?.resume(throwing: NFCSessionClientError.tagIsNotValid)
            readerContinuation = nil
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self else { return }

            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                self.readerContinuation?.resume(throwing: NFCSessionClientError.connectionError)
                self.readerContinuation = nil
                return
            }

            ndefTag.queryNDEFStatus { status, capacity, error in
                guard status != .notSupported else {
                    session.invalidate(errorMessage: "Tag not valid.")
                    self.readerContinuation?.resume(throwing: NFCSessionClientError.tagIsNotValid)
                    self.readerContinuation = nil
                    return
                }

                ndefTag.readNDEF { message, error in
                    guard error == nil, let message, let record = message.records.first else {
                        session.invalidate(errorMessage: "Read error. Please try again.")
                        self.readerContinuation?.resume(throwing: NFCSessionClientError.readError)
                        self.readerContinuation = nil
                        return
                    }

                    switch record.typeNameFormat {
                    case .empty:
                        self.readerContinuation?.resume(returning: .empty)
                    case .nfcWellKnown:
                        let (text, _) = record.wellKnownTypeTextPayload()
                        if let text {
                            self.readerContinuation?.resume(returning: .text(text))
                        } else if let url = record.wellKnownTypeURIPayload() {
                            self.readerContinuation?.resume(returning: .url(url))
                        }
                    case .nfcExternal:
                        let decoder = JSONDecoder()

                        guard let tag = try? decoder.decode(Tag.self, from: record.payload) else {
                            session.invalidate(errorMessage: "Read error. Please try again.")
                            self.readerContinuation?.resume(throwing: NFCSessionClientError.readError)
                            self.readerContinuation = nil
                            return
                        }

                        self.readerContinuation?.resume(returning: .tag(tag))

                    default:
                        self.readerContinuation?.resume(returning: .unknown)
                    }

                    self.readerContinuation = nil
                }
            }
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: any Error) {
        if let readerContinuation {
            readerContinuation.resume(throwing: NFCSessionClientError.failed(error))
        }
    }
}

