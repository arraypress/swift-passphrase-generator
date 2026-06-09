# Swift Passphrase Generator

A modern Swift package for generating cryptographically secure passphrases using the EFF Large Wordlist (7,776 words). Create memorable yet strong passphrases — like `correct-horse-battery-staple` — with control over word count, separator, and capitalization style. Perfect for password managers, onboarding flows, and any app that needs human-friendly secrets.

## Features

- 🔐 **Cryptographically secure** — Word selection uses `SecRandomCopyBytes` for true, unbiased randomness.
- 📖 **EFF Large Wordlist** — Ships with the 7,776-word list curated by the Electronic Frontier Foundation (~12.92 bits per word).
- 🎯 **Sensible defaults** — `generate()` returns a 4-word, hyphen-separated, lowercase passphrase (~52 bits of entropy).
- ⚙️ **Configurable** — Choose word count (2–10), separator, and casing style.
- 🔤 **Five casing styles** — Lowercase, uppercase, capitalize, sentence case, and alternating.
- 📦 **Batch generation** — `generateMultiple` produces 1–1000 passphrases in one call.
- 📝 **Custom word lists** — Supply your own words for non-English or specialized passphrases.
- 📊 **Entropy calculation** — `entropy(wordCount:wordListSize:)` reports passphrase strength in bits.
- ℹ️ **Wordlist metadata** — `wordListInfo()` exposes name, size, and per-word entropy.
- 🛡️ **Safe bounds** — Word counts and batch sizes are automatically clamped.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-passphrase-generator.git", from: "1.0.0")
]
```

## Usage

### Quick start

```swift
import PassphraseGenerator

let passphrase = PassphraseGenerator.generate()
// "correct-horse-battery-staple"
```

### Custom options

```swift
import PassphraseGenerator

let passphrase = PassphraseGenerator.generate(
    wordCount: 5,
    separator: ".",
    casing: .capitalize
)
// "Aluminum.Beacon.Cluster.Devoted.Examine"
```

### Casing styles

```swift
import PassphraseGenerator

PassphraseGenerator.generate(casing: .lowercase)     // correct-horse-battery-staple
PassphraseGenerator.generate(casing: .uppercase)     // CORRECT-HORSE-BATTERY-STAPLE
PassphraseGenerator.generate(casing: .capitalize)    // Correct-Horse-Battery-Staple
PassphraseGenerator.generate(casing: .sentenceCase)  // Correct-horse-battery-staple
PassphraseGenerator.generate(casing: .alternating)   // correct-HORSE-battery-STAPLE
```

### Generating multiple passphrases

```swift
import PassphraseGenerator

// Defaults: 10 passphrases, 4 words, "-", lowercase
let many = PassphraseGenerator.generateMultiple(count: 5)

// Custom configuration
let custom = PassphraseGenerator.generateMultiple(
    count: 3,
    wordCount: 5,
    separator: ".",
    casing: .capitalize
)

// Using a custom word list
let words = ["apple", "banana", "cherry", "dog", "elephant"]
let fromCustom = PassphraseGenerator.generateMultiple(
    count: 3,
    wordCount: 3,
    customWords: words
)
```

### Custom word lists

```swift
import PassphraseGenerator

let words = ["apple", "banana", "cherry", "dog", "elephant"]
let passphrase = PassphraseGenerator.generate(
    wordCount: 3,
    separator: "_",
    casing: .uppercase,
    customWords: words
)
// "APPLE_CHERRY_DOG"
```

### Measuring strength

```swift
import PassphraseGenerator

let bits = PassphraseGenerator.entropy(wordCount: 4, wordListSize: 7776)
// ~51.7

let info = PassphraseGenerator.wordListInfo()
print(info.wordCount)        // 7776
print(info.entropyPerWord)   // ~12.92
```

## Models

| Type | Description |
|------|-------------|
| `CasingStyle` | `.lowercase`, `.uppercase`, `.capitalize`, `.sentenceCase`, `.alternating`. |
| `WordListInfo` | Wordlist `name`, `wordCount`, `entropyPerWord`, and `description`. |

## How It Works

Each word is chosen by drawing four cryptographically secure random bytes via `SecRandomCopyBytes` and reducing them modulo the word-list size, giving a uniform, unbiased selection. The built-in EFF Large Wordlist is loaded once and cached for thread-safe reuse. Word counts are clamped to 2–10 and batch sizes to 1–1000 for security and performance.

## Testing

```bash
swift test
```

The test suite covers default and custom generation, casing styles, batch generation, custom word lists, and entropy calculations.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
