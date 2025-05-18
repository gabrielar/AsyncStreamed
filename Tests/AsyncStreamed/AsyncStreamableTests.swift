//
//  AsyncStreamableTests.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 01.04.25.
//

import Testing
import LeakCheck
@testable import AsyncStreamed


let observerTag = "AsyncStreamed.AsyncStreamable.Observer"
let observerListTag = "AsyncStreamed.AsyncStreamable.ObserverList"

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
        
        @Test func testForMemoryLeaksWhenFeeingSource() async throws {
            
            AllocationLog.restart()
            defer {
                AllocationLog.stop()
            }
            
            try #require(try AllocationLog.countInstances(tag: observerTag) == 0)
            try #require(try AllocationLog.countInstances(tag: observerListTag) == 0)

            var mock: StreamableMock? = StreamableMock()

            #expect(try AllocationLog.countInstances(tag: observerTag) == 0)
            #expect(try AllocationLog.countInstances(tag: observerListTag) > 0)

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

            #expect(try AllocationLog.countInstances(tag: observerTag) > 0)
            #expect(try AllocationLog.countInstances(tag: observerListTag) > 0)

            mock = nil
            try await Task.sleep(for: .milliseconds(10))

            #expect(
                try AllocationLog.countInstances(tag: observerTag) == 0, "Observer object leaked.")
            #expect(
                try AllocationLog.countInstances(tag: observerListTag) == 0,
                "ObserverList object leaked.")
        }

        @Test func testForMemoryLeaksWhenStoppingObservation() async throws {

            AllocationLog.restart()
            defer {
                AllocationLog.stop()
            }
            
            try #require(try AllocationLog.countInstances(tag: observerTag) == 0)
            try #require(try AllocationLog.countInstances(tag: observerListTag) == 0)

            let mock: StreamableMock = StreamableMock()

            #expect(try AllocationLog.countInstances(tag: observerTag) == 0)
            #expect(try AllocationLog.countInstances(tag: observerListTag) > 0)

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

            #expect(try AllocationLog.countInstances(tag: observerTag) > 0)
            #expect(try AllocationLog.countInstances(tag: observerListTag) > 0)

            await task.value

            try await Task.sleep(for: .milliseconds(10))

            #expect(
                try AllocationLog.countInstances(tag: observerTag) == 0, "Observer object leaked.")
            #expect(
                try AllocationLog.countInstances(tag: observerListTag) == 1,
                "ObserverList object leaked.")
        }
    }
}
