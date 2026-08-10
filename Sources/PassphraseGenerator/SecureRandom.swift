//
//  SecureRandom.swift
//  PassphraseGenerator
//
//  Created by David Sherlock on 2026.
//
//  Unbiased selection from a cryptographically secure source.
//

import Foundation
import Security

/// Uniform random indices backed by `SecRandomCopyBytes`.
///
/// The subtlety this exists for is the reduction step. Drawing a uniform
/// `UInt32` and returning `value % n` is *not* uniform unless `n` divides 2³²:
/// the first `2³² mod n` outcomes get one extra chance each. For a 94-character
/// alphabet that skews 42 characters by about 0.000002%, and for a 7,776-word
/// list it skews 2,560 words by 0.000181%.
///
/// Neither figure is exploitable. Both are avoidable in four lines, and in a
/// generator whose entire purpose is unpredictability, "the bias is too small to
/// matter" is a weaker guarantee than "there is no bias."
enum SecureRandom {

    /// A uniformly distributed index in `0..<upperBound`.
    ///
    /// Draws are rejected when they fall in the short tail that cannot be
    /// divided evenly, so what remains maps onto the range exactly. The expected
    /// number of draws is barely above one — for a 94-item pool, roughly one in
    /// 100 million requires a second.
    static func index(upperBound: Int) -> Int {
        precondition(upperBound > 0, "upperBound must be positive")
        let n = UInt32(upperBound)

        // 2³² mod n, computed without overflowing UInt32.
        let rejectBelow = ((UInt32.max % n) + 1) % n

        while true {
            let value = uint32()
            if value >= rejectBelow {
                return Int(value % n)
            }
        }
    }

    /// The draws discarded to remove bias, exposed for testing.
    static func rejectionThreshold(upperBound: Int) -> UInt32 {
        let n = UInt32(upperBound)
        return ((UInt32.max % n) + 1) % n
    }

    /// A cryptographically secure `UInt32`.
    ///
    /// Filled in place rather than through `Data` + `bindMemory`, which assumes
    /// a 4-byte alignment `Data` does not promise.
    static func uint32() -> UInt32 {
        var value: UInt32 = 0
        let status = withUnsafeMutableBytes(of: &value) { buffer in
            SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
        }
        guard status == errSecSuccess else {
            // Crashing is the correct failure for a security primitive: emitting
            // a password from a degraded source would be worse than not emitting
            // one at all.
            fatalError("SecRandomCopyBytes failed with status \(status)")
        }
        return value
    }
}
