[![License](https://img.shields.io/github/license/yaroslav-zhurakovskiy/CombineRealm)](https://raw.githubusercontent.com/yaroslav-zhurakovskiy/CombineRealm/master/LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

[![Build Status](https://travis-ci.org/yaroslav-zhurakovskiy/CombineRealm.svg?branch=master)](https://travis-ci.org/yaroslav-zhurakovskiy/CombineRealm) [![codecov](https://codecov.io/gh/yaroslav-zhurakovskiy/CombineRealm/branch/master/graph/badge.svg)](https://codecov.io/gh/yaroslav-zhurakovskiy/CombineRealm)

# CombineRealm
Combine is a lightweight framework that is written is pure [Swift](https://swift.org/).
It allows to seamlessly use [Apple Combine Framework](https://developer.apple.com/documentation/combine) with [Realm](https://github.com/realm/realm-cocoa).


# Installation
CombineRealm is avaialble via [Carthage](https://github.com/Carthage/Carthage) or [Swift Package Manager](https://swift.org/package-manager/).
## Requirements
* iOS 13.0+
* Swift 5+
* Realm 3.21.0+
* Carthage 0.18+ (if you use)
## Carthage
To install CombineRealm with Carthage, add the following line to your Cartfile.
```
github "yaroslav-zhurakovskiy/CombineRealm"
```
## Swift Package Manager
You can use The Swift Package Manager to install CombineRealm by adding the proper description to your Package.swift file:
```swift
// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "YOUR_PROJECT_NAME",
	dependencies: [
		.package(url: "https://github.com/yaroslav-zhurakovskiy/CombineRealm.git", from: "1.2.1"),
	]
)
```

# Usage
## Observing changes
### Some "Message" type that will be used in the examples
```swift
class Message: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var body: String = ""
    
    convenience init(_ text: String) {
        self.init()

        body = text
    }
}
```

### Observe objects
```swift
let realm = try Realm()
let infoLabel = UILabel()
var cancelSet = Set<AnyCancellable>()

realm.objectsPublisher(Message.self)
	.map { list in "You have \(list.count) messages!" }
	.catch { error in Just("Realm error: \(error.localizedDescription)") }
	.assign(to: \.text, on: infoLabel)
	.store(in: &cancelSet)
```

### Observe collection changes
```swift
let realm = try Realm()
let infoLabel = UILabel()
var cancelSet = Set<AnyCancellable>()

realm.objects(Message.self).observeChangePublisher()
	.map { changes in
		switch changes {
		case .initial(let messages):
			return "Initial \(messages.count)"
		case let .update(messages, deletions, insertions, modifications):
			var text =  "Update \(messages.count)."
			text += "\nDeletions: \(deletions)"
			text += "\nInsertions: \(insertions)"
			text += "\nModifications: \(modifications)"
			return text
		case .error(let error):
			return "Realm error: \(error.localizedDescription)"
		}
	}
	.assign(to: \.text, on: infoLabel)
	.store(in: &cancelSet)
}
```

### Observe changes in an object
```swift
class UserSettings: Object {
	@objc dynamic var email: String = ""
	@objc dynamic var company: String = ""
}

let userSettings = UserSettings()
let infoLabel = UILabel()
var cancelSet = Set<AnyCancellable>()

userSettings.observePublisher()
	.map { change in
		switch change {
		case .change(let properties):
			let settings = properties.map { $0.name }.joined(separator: "")
			return "User changed settings: \(settings)"
		case .deleted:
			return "User deleted the settings."
		}
	}
	.catch { error in Just("Realm error: \(error.localizedDescription)") }
	.assign(to: \.text, on: infoLabel)
	.store(in: &cancelSet)

```

## Writing changes
```swift
let realm = try Realm()
let currentMessage = Message("Some message to edit...")
try realm.write {
	realm.add(currentMessage)
}
let editMessageField =  UITextField()
var cancellableSet = Set<AnyCancellable>()

editMessageField.publisher(for: \.text)
	.map { $0 ?? "" }
	.write(to: realm) { _, newMessageText in
		currentMessage.body = newMessageText
	}
	.store(in: &cancellableSet)
```

## Adding objects
```swift
let realm = try Realm()
var cancelSet = Set<AnyCancellable>()
let messageField =  UITextField()
let sendButton = UIButton()

sendButton.publisher(for: .touchUpInside) 
	.compactMap { messageField.text }
	.filter { text in !text.isEmpty }
	.map { text in Message(text) }
	.add(to: realm)
	.store(in: &cancelSet)

Just(Message("I am great!"))
	.add(to: realm)
	.store(in: &cancelSet)
```

## Deleting objects
```swift
let realm = try Realm()
var cancelSet = Set<AnyCancellable>()

Publishers.Sequence(sequence: ["message-id#1", "message-id#2"])
	.compactMap { messageID in
		return realm.object(ofType: Message.self, forPrimaryKey: messageID)
	}
	.delete(from: realm)
	.store(in: &cancelSet)
```

# Note
## Instead of sugar syntax you can always use the coresponding types:
```swift
// Publishers
ObserveChangePublisher
ObserveElementsPublisher
ObserveObjectPublisher

// Subscribers
Realm.Add
Realm.Write
Realm.TryWrite
Realm.Delete
```
