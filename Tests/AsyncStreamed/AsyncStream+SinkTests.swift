//
//  AsyncStream+SinkTests.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 13.04.25.
//

import Testing

@testable import AsyncStreamed

extension AllTests {

    @Suite(
        "AsyncStreamable+Stream tests"
    ) struct AsyncStreamSinkTests {

        @Test func testCancelable() async throws {

            let streamingMock = StreamableMock()
            let observerMock = await ObserverMock(
                streamingMock: streamingMock, cancelableStrategy: .cancelable
            )

            await streamingMock.startIntStreaming(interval: .milliseconds(10))

            while await observerMock.appendCount < 5 {
                try await Task.sleep(for: .milliseconds(1))
            }

            await observerMock.resetCancelable()

            let initialAppendCount = await observerMock.appendCount
            try #require(initialAppendCount > 0, "Wrong initial append count")

            try await Task.sleep(for: .milliseconds(100))

            let appendCount = await observerMock.appendCount
            #expect(appendCount == initialAppendCount, "Append count has changed after cancelling")
        }

        @Test func testCancelableSet() async throws {

            let streamingMock = StreamableMock()
            let observerMock = await ObserverMock(
                streamingMock: streamingMock, cancelableStrategy: .cancelableSet
            )

            await streamingMock.startIntStreaming(interval: .milliseconds(10))

            while await observerMock.appendCount < 5 {
                try await Task.sleep(for: .milliseconds(1))
            }
            await observerMock.resetCancelable()

            let initialAppendCount = await observerMock.appendCount
            try #require(initialAppendCount > 0, "Wrong initial append count")

            try await Task.sleep(for: .milliseconds(100))

            let appendCount = await observerMock.appendCount
            #expect(appendCount == initialAppendCount, "Append count has changed after cancelling")
        }
    }
}
