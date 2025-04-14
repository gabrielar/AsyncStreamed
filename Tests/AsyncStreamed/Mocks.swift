//
//  Mocks.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 03.04.25.
//

import AsyncStreamed

actor StreamableMock {
    
    private var tasks: [Task<(), any Error>] = []
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
    
    @AsyncStreamable
    var intWithStream: Int = 0
    
    func startIntStreaming(interval: Duration = .milliseconds(500)) async {
        tasks.append(Task { [weak self] in
            while !Task.isCancelled {
                try await Task.sleep(for: interval)
                await self?.incrementIntWithStream()
            }
        })
    }
    
    private func incrementIntWithStream() {
        self.intWithStream += 1
    }
}

// MARK: -

@MainActor
class ObserverMock {

    enum CancelableStrategy {
        case cancelable, cancelableSet
    }

    var integers: [Int] = []
    var appendCount = 0

    var cancelable: Cancellable?
    private var cancelableSet: CancellableSet = []

    private let cancelableStrategy: CancelableStrategy

    init(streamingMock: StreamableMock, cancelableStrategy: CancelableStrategy) async {

        self.cancelableStrategy = cancelableStrategy

        switch cancelableStrategy {

        case .cancelable:
            cancelable = await streamingMock.$intWithStream.sink {
                @MainActor @Sendable [weak self] i in
                self?.integers.append(i)
                self?.appendCount += 1
            }

        case .cancelableSet:
            await streamingMock.$intWithStream
                .sink { @MainActor @Sendable [weak self] i in
                    self?.integers.append(i)
                    self?.appendCount += 1
                }
                .addTo(&cancelableSet)
        }
    }

    func resetCancelable() async {
        switch cancelableStrategy {

        case .cancelable:
            cancelable = nil
        case .cancelableSet:
            cancelableSet.removeAll()
        }

    }
}
