//
//  CombineRealmTests
//
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import XCTest
import RealmSwift

func assert(
    _ change: TodoResultsChange,
    isInitialWithValue expectedValue: [Todo],
    file: StaticString = #file,
    line: UInt = #line
) {
    switch change {
    case .initial(let values):
        assertEqual(Array(values), expectedValue, file: file, line: line)
    default:
        XCTFail(
            "Change is not .initial, but \(change)",
            file: file,
            line: line
        )
    }
}

func assertInitial(_ change: TodoResultsChange, file: StaticString = #file, line: UInt = #line) {
    guard case .initial = change else {
        XCTFail(
            "Change is not .initial, but \(change)",
            file: file,
            line: line
        
        )
        return
    }
}

func assertUpdate(_ change: TodoResultsChange, file: StaticString = #file, line: UInt = #line) {
    guard case .update = change else {
        XCTFail(
            "Change is not .update, but \(change)",
            file: file,
            line: line
        
        )
        return
    }
}


func assert(
    _ change: TodoResultsChange,
    isUpdateWithValue expectedValue: [Todo],
    file: StaticString = #file,
    line: UInt = #line
) {
    switch change {
    case .update(let values):
        assertEqual(Array(values.0), expectedValue, file: file, line: line)
    default:
         XCTFail(
           "Change is not .update, but \(change)",
           file: file,
           line: line
       )
    }
}


func assertEqual(
    _ values: [Todo],
    _ expectedValue: [Todo],
    description: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(
       values.count,
       expectedValue.count,
       "Number of items" + description,
       file: file,
       line: line
    )
    for index in 0..<values.count {
        assertEqual(
            values[index],
            expectedValue[index],
            description: "[\(index)]" + description,
            file: file,
            line: line
        )
    }
}

func assertEqual(
    _ todo1: Todo,
    _ todo2: Todo,
    description: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(
        todo1.id,
        todo2.id,
        "Id" + description,
        file: file,
        line: line
    )
    
    XCTAssertEqual(
        todo1.title,
        todo2.title,
        "Title" + description,
        file: file,
        line: line
    )
}

func assert<T: Equatable>(
    _ array: [T],
    contains subarray: [T],
    description: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertTrue(
        array.count >= subarray.count,
        "array.count(\(array.count)) >= subarray.count(\(subarray.count))" + description,
        file: file,
        line: line
    )
    for elem in subarray {
        XCTAssertTrue(
            array.contains(where: { $0 == elem }),
            "array \(array) does not contain: \(elem)" + description,
            file: file,
            line: line
        )
    }
}

func assert<T: Equatable>(
    _ array: [T],
    contains subarray: [T],
    equalAlgorithm: (T, T) -> Bool,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertTrue(
        array.count >= subarray.count,
        "array.count(\(array.count)) >= subarray.count(\(subarray.count))",
        file: file,
        line: line
    )
    for elem in subarray {
        XCTAssertTrue(
            array.contains(where: { equalAlgorithm($0, elem) }),
            "array \(array) does not contain: \(elem)",
            file: file,
            line: line
        )
    }
}
