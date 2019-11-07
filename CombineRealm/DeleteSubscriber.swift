//    
//  CombineRealm
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import RealmSwift
import Combine

public extension Realm {
    final class Delete<Input: RealmSwift.Object>: Subscriber, Cancellable {
        public typealias Failure = Never
         
        public let combineIdentifier: CombineIdentifier
         
        private let handleFailure: ((Swift.Error) -> Void)?
        private let realm: Realm?
        
        private var subscription: Subscription?
         
        public init(
             realm: Realm?,
             handleFailure: ((Swift.Error) -> Void)? = nil
         ) {
             self.realm = realm
             self.handleFailure = handleFailure
             self.combineIdentifier = CombineIdentifier()
         }
        
        public init(handleFailure: ((Swift.Error) -> Void)? = nil) {
             self.realm = nil
             self.handleFailure = handleFailure
             self.combineIdentifier = CombineIdentifier()
         }
        
         public func receive(subscription: Subscription) {
            self.subscription = subscription
            
            subscription.request(.unlimited)
         }
        
         public func receive(_ input: Input) -> Subscribers.Demand {
             do {
                let realm = try self.realm ?? Realm()
                try realm.write {
                    realm.delete(input)
                }
             } catch let error {
                 handleFailure?(error)
             }
            return .unlimited
         }
        
        public func receive(completion: Subscribers.Completion<Failure>) {
             
        }
        
        public func cancel() {
            subscription?.cancel()
        }
    }
}

public extension Publisher where Output: Object, Failure == Never {
    func delete(from realm: Realm) -> AnyCancellable {
        let subscriber = Realm.Delete<Output>(realm: realm)
        subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
    
    func deleteFromRealm() -> AnyCancellable {
        let subscriber = Realm.Delete<Output>(realm: nil)
        subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}

