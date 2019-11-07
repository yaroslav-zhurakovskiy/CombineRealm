//
//  CombineRealmTests
//
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import XCTest
import RealmSwift

extension XCTestCase {
    func waitForExpectations(handler: XCWaitCompletionHandler? = nil) {
        waitForExpectations(timeout: 60, handler: handler)
    }
}

extension String {
    init<Root, Value>(from keyPath: KeyPath<Root, Value>) {
        self.init(NSExpression(forKeyPath: keyPath).keyPath)
    }
}

func createTestRealm(identifier: String = "TestRealm") throws -> Realm {
    return try Realm(configuration: Realm.Configuration(inMemoryIdentifier: identifier))
}

func throwErrorDummy() throws {
    
}
