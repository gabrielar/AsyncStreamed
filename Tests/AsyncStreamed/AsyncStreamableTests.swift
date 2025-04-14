//
//  AsyncStreamableTests.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 01.04.25.
//

import Testing
@testable import AsyncStreamed

@Suite(
    "All  tests", .serialized, .timeLimit(.minutes(2))
) struct AllTests {}

extension AllTests {

    @Suite(
        "AsyncStreamable tests"
    ) struct AsyncStreamableTests {

        @Test func testIntStreaming() async throws {

            let mock = StreamableMock()

            let task = Task {
                var elements: [Int] = []
                for await element in await mock.$intWithStream {
                    elements.append(element)
                    if element == 5 {
                        break
                    }
                }
                return elements
            }

            await mock.startIntStreaming(interval: .milliseconds(10))
            #expect(await task.value == [1, 2, 3, 4, 5])
        }

        #if MEMORY_LEAKS_TESTING

            @Test func testForMemoryLeaksWhenFeeingSource() async throws {

                try #require(await __AsyncStreamable_Observer_objectCount == 0)
                try #require(await __AsyncStreamable_ObserverList_objectCount == 0)

                var mock: StreamableMock? = StreamableMock()

                #expect(await __AsyncStreamable_Observer_objectCount == 0)
                #expect(await __AsyncStreamable_ObserverList_objectCount > 0)

                Task { [weak mock] in
                    guard let stream = await mock?.$intWithStream else {
                        Issue.record("Mock not found")
                        return
                    }
                    for await element in stream {
                        if element == 1000 {
                            break
                        }
                    }
                }

                await mock?.startIntStreaming(interval: .milliseconds(5))

                try await Task.sleep(for: .milliseconds(10))

                #expect(await __AsyncStreamable_Observer_objectCount > 0)
                #expect(await __AsyncStreamable_ObserverList_objectCount > 0)

                mock = nil
                try await Task.sleep(for: .milliseconds(10))

                #expect(
                    await __AsyncStreamable_Observer_objectCount == 0, "Observer object leaked.")
                #expect(
                    await __AsyncStreamable_ObserverList_objectCount == 0,
                    "ObserverList object leaked.")
            }

            @Test func testForMemoryLeaksWhenStoppingObservation() async throws {

                try #require(await __AsyncStreamable_Observer_objectCount == 0)
                try #require(await __AsyncStreamable_ObserverList_objectCount == 0)

                let mock: StreamableMock = StreamableMock()

                #expect(await __AsyncStreamable_Observer_objectCount == 0)
                #expect(await __AsyncStreamable_ObserverList_objectCount > 0)

                let task = Task { [weak mock] in
                    guard let stream = await mock?.$intWithStream else {
                        Issue.record("Mock not found")
                        return
                    }
                    for await element in stream {
                        if element == 10 {
                            break
                        }
                    }
                }

                await mock.startIntStreaming(interval: .milliseconds(5))

                try await Task.sleep(for: .milliseconds(10))

                #expect(await __AsyncStreamable_Observer_objectCount > 0)
                #expect(await __AsyncStreamable_ObserverList_objectCount > 0)

                await task.value

                try await Task.sleep(for: .milliseconds(10))

                #expect(
                    await __AsyncStreamable_Observer_objectCount == 0, "Observer object leaked.")
                #expect(
                    await __AsyncStreamable_ObserverList_objectCount == 1,
                    "ObserverList object leaked.")
            }

        #endif
    }
}