import Foundation
import AVFoundation
import Speech

actor Speech {
    private let synthesizer: AVSpeechSynthesizer

    init() {
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.usesApplicationAudioSession = false
    }

    func speak(_ text: String) async throws {
        let utterance = AVSpeechUtterance(string: text)
        utterance.prefersAssistiveTechnologySettings = true
        synthesizer.speak(utterance)
    }
}

extension SpeechClient {
    static var live: Self {
        let speech = Speech()

        return SpeechClient {
            return true
        } speak: { text in
            try await speech.speak(text)
        }
    }
}
