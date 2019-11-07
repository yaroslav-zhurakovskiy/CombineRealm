//    
//  CombineRealm
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import RealmSwift
import Combine

extension Realm {
    public final class Add<Input: RealmSwift.Object>: Subscriber, Cancellable {
        public typealias Failure = Never
         
        public let combineIdentifier: CombineIdentifier
         
        private let handleFailure: ((Swift.Error) -> Void)?
        private let receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
        private let realm: Realm?
        private let updatePolicy: UpdatePolicy? = nil
        
        private var subscription: Subscription?
         
        public init(
             realm: Realm,
             handleFailure: ((Swift.Error) -> Void)? = nil
         ) {
             self.realm = realm
             self.handleFailure = handleFailure
             self.receiveCompletion = nil
             self.combineIdentifier = CombineIdentifier()
         }
        
        public init(handleFailure: ((Swift.Error) -> Void)? = nil) {
            self.realm = nil
            self.handleFailure = handleFailure
            self.receiveCompletion = nil
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
                    if let updatePolicy = updatePolicy {
                        realm.add(input, update: updatePolicy)
                    } else {
                        realm.add(input)
                    }
                }
             } catch let error {
                 handleFailure?(error)
             }
            return .unlimited
         }
        
        public func receive(completion: Subscribers.Completion<Failure>) {
             receiveCompletion?(completion)
        }
        
        public func cancel() {
            subscription?.cancel()
        }
    }
}


public extension Publisher where Output: RealmSwift.Object, Failure == Never {
    func add(to realm: Realm) -> AnyCancellable {
        let subscriber = Realm.Add<Output>(realm: realm)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
    
    func addToRealm() -> AnyCancellable {
        let subscriber = Realm.Add<Output>()
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}
