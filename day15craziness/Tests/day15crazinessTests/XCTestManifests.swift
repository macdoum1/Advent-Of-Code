import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(day15crazinessTests.allTests),
    ]
}
#endif