//
//  WriteBatch.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

import FirebaseFirestore



extension WriteBatch {

	// MARK: - Create

	public func save(data: [String: Any],
					 path: DocumentPath,
					 store: Firestore) {

		let reference = path.reference(with: store)
		setData(data, forDocument: reference, merge: false)
	}

	public func merge(data: [String: Any],
					  fields: [String]?,
					  path: DocumentPath,
					  store: Firestore) {

		let reference = path.reference(with: store)

		if let fields = fields {
			setData(data, forDocument: reference, mergeFields: fields)
		}
		else {
			setData(data, forDocument: reference, merge: true)
		}

	}


	// MARK: Update

	public func updateOnly(data: [String: Any],
						   path: DocumentPath,
						   store: Firestore) {

		let reference = path.reference(with: store)
		updateData(data, forDocument: reference)
	}


	// MARK: Delete

	public func delete(path: DocumentPath,
					   store: Firestore) {

		let reference = path.reference(with: store)
		deleteDocument(reference)
	}

}
