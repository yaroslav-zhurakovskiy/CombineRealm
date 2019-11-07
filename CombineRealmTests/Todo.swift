//
//  CombineRealmTests
//
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var isDone: Bool = false
    @objc dynamic var title: String = ""
    
    convenience init(_ title: String) {
        self.init()
        self.title = title
    }
}

extension Todo {
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Todo else {
            return false
        }
        
        return id == other.id
    }
}
