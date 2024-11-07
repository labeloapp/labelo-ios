import Foundation
import Speech

actor Speech {
    private let synthesizer: AVSpeechSynthesizer

    init() {
        self.synthesizer = AVSpeechSynthesizer()
    }

    func speak(_ text: String) async throws {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
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
