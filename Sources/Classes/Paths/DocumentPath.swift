//
//  DocumentPath.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

// swiftlint:disable force_cast

import FirebaseFirestore



public struct DocumentPath: PathType {

	/// Components forming the Path
	public let components: [Path.Component]



	// MARK: - Initialize

	public init?(pathComponents components: [String]) {

		guard components.count % 2 == 1 else { return nil }

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

	init?(pathComponents components: [Path.Component]) {

		guard components.count % 2 == 1 else { return nil }

		self.components = components
	}



	// MARK: - Methods

	public func reference(with store: Firestore) -> DocumentReference {
		return typeErasedReference(with: store) as! DocumentReference
	}

}
