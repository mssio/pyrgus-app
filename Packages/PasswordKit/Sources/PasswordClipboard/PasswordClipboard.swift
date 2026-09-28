import Foundation

#if os(iOS)
import UIKit
import UniformTypeIdentifiers
#elseif os(macOS)
import AppKit
#endif

/// Copies a secret so that it does not linger: the only platform-divergent code in the app.
public enum PasswordClipboard {
    #if os(macOS)
    /// Tells clipboard-history utilities not to record the entry (nspasteboard.org convention).
    static let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
    #endif

    @MainActor
    public static func copy(_ secret: String, expiresAfter: TimeInterval = 90) {
        #if os(iOS)
        // The system removes the item at the expiration date. Universal Clipboard stays enabled.
        UIPasteboard.general.setItems(
            [[UTType.utf8PlainText.identifier: secret]],
            options: [.expirationDate: Date().addingTimeInterval(expiresAfter)]
        )
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(secret, forType: .string)
        pasteboard.setData(Data(), forType: concealedType)
        // NSPasteboard has no expiry: clear later, but only if nothing was copied since.
        let changeCount = pasteboard.changeCount
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(expiresAfter))
            if pasteboard.changeCount == changeCount { pasteboard.clearContents() }
        }
        #endif
    }
}
