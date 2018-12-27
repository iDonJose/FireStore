//
//  Firestore.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

// swiftlint:disable force_cast

import FirebaseFirestore



extension Firestore {

	// MARK: Read

	public func get(path: DocumentPath,
					source: FirestoreSource,
					completed: @escaping (DocumentSnapshot?) -> Void,
					failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)

		reference.getDocument(source: source) { snapshot, error in
			if let error = error as NSError? { failed(error) }
			else { completed(snapshot) }
		}

	}

	public func observe(path: DocumentPath,
						includeMetadataChanges: Bool,
						completed: @escaping (DocumentSnapshot?) -> Void,
						failed: @escaping (NSError) -> Void) -> ListenerRegistration {

		let reference = path.reference(with: self)

		return reference.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
			if let error = error as NSError? { failed(error) }
			else { completed(snapshot) }
		}

	}


	public func get(path: CollectionPath,
					query: ((CollectionReference) -> Query)?,
					source: FirestoreSource,
					completed: @escaping (QuerySnapshot?) -> Void,
					failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)

		let completion: (QuerySnapshot?, Error?) -> Void = { snapshot, error in
			if let error = error as NSError? { failed(error) }
			else { completed(snapshot) }
		}


		if let query = query {
			query(reference).getDocuments(source: source, completion: completion)
		}
		else {
			reference.getDocuments(source: source, completion: completion)
		}

	}

	public func observe(path: CollectionPath,
						query: ((CollectionReference) -> Query)?,
						includeMetadataChanges: Bool,
						completed: @escaping (QuerySnapshot?) -> Void,
						failed: @escaping (NSError) -> Void) -> ListenerRegistration {

		let reference = path.reference(with: self)

		let listener: (QuerySnapshot?, Error?) -> Void = { snapshot, error in
			if let error = error as NSError? { failed(error) }
			else { completed(snapshot) }
		}


		if let query = query {
			return query(reference).addSnapshotListener(includeMetadataChanges: includeMetadataChanges, listener: listener)
		}
		else {
			return reference.addSnapshotListener(includeMetadataChanges: includeMetadataChanges, listener: listener)
		}

	}



	// MARK: - Create

	public func save(data: [String: Any],
					 path: DocumentPath,
					 completed: @escaping (String) -> Void,
					 failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)

		reference.setData(data, merge: false) { error in
			if let error = error as NSError? { failed(error) }
			else { completed(reference.documentID) }
		}

	}

	/// Merges data to existing data.
	/// If no previous data exists, it will create a document with the provided data.
	public func merge(data: [String: Any],
					  fields: [String]?,
					  path: DocumentPath,
					  completed: @escaping (String) -> Void,
					  failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)

		let completion: (Error?) -> Void = { error in
			if let error = error as NSError? { failed(error) }
			else { completed(reference.documentID) }
		}

		if let fields = fields {
			reference.setData(data, mergeFields: fields, completion: completion)
		}
		else {
			reference.setData(data, merge: true, completion: completion)
		}

	}


	// MARK: Update

	public func updateOnly(data: [String: Any],
						   path: DocumentPath,
						   completed: @escaping (String) -> Void,
						   failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)

		reference.updateData(data) { error in
			if let error = error as NSError? { failed(error) }
			else { completed(reference.documentID) }
		}

	}


	// MARK: Delete

	public func delete(path: DocumentPath,
					   completed: @escaping (String) -> Void,
					   failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)

		reference.delete { error in
			if let error = error as NSError? { failed(error) }
			else { completed(reference.documentID) }
		}

	}



	// MARK: - Transaction

	public func runTransaction<T>(transaction: @escaping (_ transaction: Transaction, _ store: Firestore) throws -> T,
								  completed: @escaping (T) -> Void,
								  failed: @escaping (NSError) -> Void) {

		let _transaction: (Transaction, ErrorPointer) -> Any? = { _transaction, error in
			do {
				return try transaction(_transaction, self)
			}
			catch let _error as NSError {
				error?.pointee = _error
				return nil
			}
		}

		let completion: (Any?, Error?) -> Void = { value, error in
			if let error = error as NSError? { failed(error) }
			else { completed(value as! T) }
		}

		runTransaction(_transaction, completion: completion)

	}


	// MARK: - Batch

	public func batchUpdate(batch: (_ batch: WriteBatch, _ store: Firestore) -> Void,
							completed: @escaping () -> Void,
							failed: @escaping (NSError) -> Void) {

		let _batch = self.batch()

		batch(_batch, self)

		_batch.commit { error in
			if let error = error as NSError? { failed(error) }
			else { completed() }
		}

	}

}
