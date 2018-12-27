//
//  CollectionPath.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

// swiftlint:disable force_cast

import FirebaseFirestore



public struct CollectionPath: PathType {

	/// Components forming the Path
	public let components: [Path.Component]



	// MARK: - Initialize

	public init?(pathComponents components: [String]) {

		guard components.count % 2 == 0 else { return nil }

		self.components = components
			.enumerated()
			.map { pair -> Component in
				if pair.offset % 2 == 0 { return .collection(pair.element) }
				else {
					if pair.element == "*" { return .newDocument }
					else { return .document(pair.element) }
				}
			}

	}



	// MARK: - Methods

	public func reference(with store: Firestore) -> CollectionReference {
		return typeErasedReference(with: store) as! CollectionReference
	}


	/// Adds a new document to the path
	public func newDocument() -> DocumentPath {

		var components = self.components
		components.append(.newDocument)

		return DocumentPath(pathComponents: components)!
	}

}
