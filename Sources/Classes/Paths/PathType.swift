//
//  PathType.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

// swiftlint:disable force_cast

import FirebaseFirestore



public protocol PathType: CustomStringConvertible {

	typealias Component = Path.Component

	var components: [Component] { get }

	init?(pathComponents components: [String])

}

public struct Path {
	public enum Component {

		case newDocument
		case document(String)
		case collection(String)


		var value: String {
			switch self {
			case .newDocument:
				return "*"
			case let .document(value),
				 let .collection(value):
				return value
			}
		}

	}
}


extension PathType {

	// MARK: - Initialize

	/// Create a path from a String.
	/// For example, "/countries/france/cities/" for a path to a collection,
	/// Or "/countries/france/cities/*" for a new city.
	public init?(path: String) {

		let pathComponents = path.split(separator: "/").map { String($0) }

		guard
			pathComponents.isNotEmpty
				&& !pathComponents.contains(where: { $0.isEmpty }) else {

					if pathComponents.isEmpty { assert(true, "Provided path \(path) is empty") }
					else { assert(true, "Provided path \(path) contains empty components") }

					return nil
		}

		self.init(pathComponents: pathComponents)
	}


	public init?(pathComponents components: String...) {
		self.init(pathComponents: components)
	}


	// MARK: - Methods

	public func typeErasedReference(with store: Firestore) -> Any {

		let start = store.collection(components.first!.value)

		return components
			.dropFirst()
			.reduce(start as Any, { reference, component in
				switch component {
				case .newDocument:
					return (reference as! CollectionReference).document()
				case let .document(value):
					return (reference as! CollectionReference).document(value)
				case let .collection(value):
					return (reference as! DocumentReference).collection(value)
				}
			})
	}


	public var description: String {
		return components.map { $0.value }.joined(separator: "/")
	}

}
