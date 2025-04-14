# AsyncStreamed

AsyncStreamed is a Swift library that simplifies working with `AsyncStream`.

[![Swift][swift-badge]][swift-url]
[![License][mit-badge]][mit-url]
[![GitHub Actions][gh-actions-badge]][gh-actions-url]

## Getting started

Inspired by the `@Published` property wrapper, this package introduces the `@AsyncStreamable` property wrapper. However, its projected value returns an `AsyncStream` instead of a publisher. When the property is updated, a new element is emitted through the `AsyncStream`. 

### Using Asyncstreamed

```swift
import AsyncStreamed

actor Streamer {
        
    @AsyncStreamable
    var streamedIn: Int = 0
    
    /**
    A task that updates `streamedIn` over time.
    */
    func startIntStreaming() async {
        Task { [weak self] in
            while !Task.isCancelled {
                try await Task.sleep(for: .milliseconds(500))
                await self?.incrementIntWithStream()
            }
        }
    }
    
    private func incrementIntWithStream() {
        self.streamedIn += 1
    }
}

        
let streamer = Streamer()

let task = Task {
    for await streamElement in await streamer.$streamedIn {
        // `streamElement is 
    }
}
```

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat
[swift-url]: https://swift.org

[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license

[gh-actions-badge]: https://github.com/gabrielar/AsyncStreamed/actions/workflows/build.yml/badge.svg?branch=main
[gh-actions-url]: https://github.com/gabrielar/AsyncStreamed/actions?query=branch%3Amain++