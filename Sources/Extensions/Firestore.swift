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

	/// Gets the data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - source: Source where to fetch data
	///   - completed: Completion callback
	///   - failed: Failure callback
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

	/// Observes data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - includeMetadataChanges: Whether metadata-only changes should trigger events
	///   - completed: Completion callback
	///   - failed: Failure callback
	/// - Returns: A listener for canceling observation
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


	/// Gets collection of data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - query: Block generating the query
	///   - source: Source where to fetch data
	///   - completed: Completion callback
	///   - failed: Failure callback
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

	/// Observes data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - query: Block generating the query
	///   - includeMetadataChanges: Source where to fetch dataWhether metadata-only changes should trigger events.
	///   - completed: Completion callback
	///   - failed: Failure callback
	/// - Returns: A listener for canceling observation
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

	/// Saves data to the given path.
	///
	/// - Parameters:
	///   - data: Data
	///   - path: Path
	///   - completed: Completion callback
	///   - failed: Failure callback
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
	///
	/// - Parameters:
	///   - data: Data
	///   - fields: Fields to be merged
	///   - path: Path
	///   - completed: Completion callback
	///   - failed: Failure callback
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

	/// Updates with data if there is already some existing data at the given path.
	///
	/// - Parameters:
	///   - data: Data
	///   - path: Path
	///   - completed: Completion callback
	///   - failed: Failure callback
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

	/// Deletes data at the given path
	///
	/// - Parameters:
	///   - path: Path
	///   - completed: Completion callback
	///   - failed: Failure callback
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

    /// Makes changes atomically.
    ///
    /// - Parameters:
    ///   - transaction: A block providing a store reference and a transaction object used to make changes atomically
    ///   - completed: Completion callback
    ///   - failed: Failure callback
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

    /// Performs multiple write in a single atomic operation.
    ///
    /// - Parameters:
    ///   - batch: A block providing a store reference and a batch object on which writes are done
    ///   - completed: Completion callback
    ///   - failed: Failure callback
	public func batchUpdate<T>(batch: (_ batch: WriteBatch, _ store: Firestore) throws -> T,
                               completed: @escaping (T) -> Void,
                               failed: @escaping (NSError) -> Void) {

		let _batch = self.batch()

        do {
            let result = try batch(_batch, self)

            _batch.commit { error in
                if let error = error as NSError? { failed(error) }
                else { completed(result) }
            }
        }
        catch let error as NSError {
            failed(error)
        }
	}

    /// Performs deletions in a single atomic operation.
    ///
    /// - Parameters:
    ///   - path: Path
    ///   - query: Block generating the query
    ///   - batchSize: Number of deletions per batch
    ///   - source: Where to fecth data object on which writes are done
    ///   - completed: Completion callback
    ///   - failed: Failure callback
	public func batchDelete(path: CollectionPath,
                            query: ((CollectionReference) -> Query)?,
                            batchSize: Int,
                            source: FirestoreSource,
                            completed: @escaping ([String]) -> Void,
                            failed: @escaping (NSError) -> Void) {

		let reference = path.reference(with: self)
		let query = query ?? { $0.order(by: .documentID()) }

		let batchQuery = query(reference)
			.limit(to: batchSize.min(1))


        var deletedDocuments = [String]()

		func batchDelete() {
			batchQuery.getDocuments(source: source) { snapshot, error in

				if let error = error as NSError? {
					failed(error)
					return
				}

				guard
					let snapshot = snapshot,
					!snapshot.isEmpty
					else { completed(deletedDocuments); return }


				let batch = self.batch()

                let references = snapshot.documents.map { $0.reference }
                deletedDocuments.append(contentsOf: references.map { $0.documentID })

				references.forEach { batch.deleteDocument($0) }

				batch.commit { error in
					if let error = error as NSError? { failed(error) }
					else if snapshot.isEmpty { completed(deletedDocuments) }
					else { batchDelete() }
				}

			}
		}

		batchDelete()

	}

}
