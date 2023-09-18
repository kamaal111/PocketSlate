//
//  AsyncSynthesizer.swift
//
//
//  Created by Kamaal M Farah on 18/09/2023.
//

import Foundation
import AVFoundation

public enum AsyncSynthesizer {
    public static func speak(string: String, locale: Locale) async {
        let utterance = AVSpeechUtterance(string: string)
        let voice = AVSpeechSynthesisVoice(language: locale.identifier)
        utterance.voice = voice
        utterance.rate = 0.2

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        while synthesizer.isSpeaking {
            try? await Task.sleep(seconds: 0.2)
        }
    }
}

extension Task where Success == Never, Failure == Never {
    fileprivate static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
