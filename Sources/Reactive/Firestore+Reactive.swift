//
//  Firestore+Reactive.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

#if USE_REACTIVESWIFT
import FirebaseFirestore
import ReactiveSwift



extension Firestore: ReactiveExtensionsProvider {}

extension Reactive where Base: Firestore {

	// MARK: Read

	/// Gets the data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - source: Source where to fetch data
	/// - Returns: A signal producer of a document snapshot
	public func get(path: DocumentPath,
					source: FirestoreSource) -> SignalProducer<DocumentSnapshot?, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.get(path: path,
					 source: source,
					 completed: { observer.send(value: $0); observer.sendCompleted() },
					 failed: { observer.send(error: $0) })
		}
	}

	/// Observes data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - includeMetadataChanges: Whether metad
	/// - Returns: A signal producer of document snapshots
	public func observe(path: DocumentPath,
						includeMetadataChanges: Bool) -> SignalProducer<DocumentSnapshot?, NSError> {

		return SignalProducer { [weak base] observer, lifetime in

			guard let base = base else { observer.sendCompleted(); return }

			let listener = base.observe(path: path,
										includeMetadataChanges: includeMetadataChanges,
										completed: { observer.send(value: $0) },
										failed: { observer.send(error: $0) })

			lifetime.observeEnded { listener.remove() }
		}
	}


	/// Gets collection of data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - query: Block generating the query
	///   - source: Source where to fetch data
	/// - Returns: A signal producer of a query snapshot
	public func get(path: CollectionPath,
					query: ((CollectionReference) -> Query)?,
					source: FirestoreSource) -> SignalProducer<QuerySnapshot?, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.get(path: path,
					 query: query,
					 source: source,
					 completed: { observer.send(value: $0); observer.sendCompleted() },
					 failed: { observer.send(error: $0) })
		}
	}

	/// Observes data at the given path.
	///
	/// - Parameters:
	///   - path: Path
	///   - query: Block generating the query
	///   - includeMetadataChanges: Source where to fetch dataWhether metadata-only changes should trigger events.
	/// - Returns: A signal producer of query snapshots
	public func observe(path: CollectionPath,
						query: ((CollectionReference) -> Query)?,
						includeMetadataChanges: Bool) -> SignalProducer<QuerySnapshot?, NSError> {

		return SignalProducer { [weak base] observer, lifetime in

			guard let base = base else { observer.sendCompleted(); return }

			let listener = base.observe(path: path,
										query: query,
										includeMetadataChanges: includeMetadataChanges,
										completed: { observer.send(value: $0) },
										failed: { observer.send(error: $0) })

			lifetime.observeEnded { listener.remove() }
		}
	}



	// MARK: - Create

	/// Saves data to the given path.
	///
	/// - Parameters:
	///   - data: Data
	///   - path: Path
	/// - Returns: A signal producer of the identifier of the data that was saved
	public func save(data: [String: Any],
					 path: DocumentPath) -> SignalProducer<String, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.save(data: data,
					  path: path,
					  completed: { observer.send(value: $0); observer.sendCompleted() },
					  failed: { observer.send(error: $0) })
		}
	}

	/// Merges data to existing data.
	/// If no previous data exists, it will create a document with the provided data.
	///
	/// - Parameters:
	///   - data: Data
	///   - fields: Fields to be merged
	///   - path: Path
	/// - Returns: A signal producer of the identifier of the data that was merged
	public func merge(data: [String: Any],
					  fields: [String]?,
					  path: DocumentPath) -> SignalProducer<String, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.merge(data: data,
					   fields: fields,
					   path: path,
					   completed: { observer.send(value: $0); observer.sendCompleted() },
					   failed: { observer.send(error: $0) })
		}
	}


	// MARK: Update

	/// Updates with data if there is already some existing data at the given path.
	///
	/// - Parameters:
	///   - data: Data
	///   - path: Path
	/// - Returns: A signal producer of the identifier of the data that was updated
	public func updateOnly(data: [String: Any],
						   path: DocumentPath) -> SignalProducer<String, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.updateOnly(data: data,
							path: path,
							completed: { observer.send(value: $0); observer.sendCompleted() },
							failed: { observer.send(error: $0) })
		}
	}


	// MARK: Delete

	/// Deletes data at the given path
	///
	/// - Parameters:
	///   - path: Path
	/// - Returns: A signal producer of the identifier of the data that was deleted
	public func delete(path: DocumentPath) -> SignalProducer<String, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.delete(path: path,
						completed: { observer.send(value: $0); observer.sendCompleted() },
						failed: { observer.send(error: $0) })
		}
	}



	// MARK: - Transaction

	/// Makes changes atomically.
	///
	/// - Parameters:
	///   - transaction: A block providing a store reference and a transaction object used to make changes atomically
	/// - Returns: A signal producer with the result of transaction block
	public func runTransaction<T>(transaction: @escaping (_ transaction: Transaction, _ store: Firestore) throws -> T) -> SignalProducer<T, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.runTransaction(transaction: transaction,
								completed: { observer.send(value: $0); observer.sendCompleted() },
								failed: { observer.send(error: $0) })
		}
	}


	// MARK: - Batch

	/// Performs multiple write in a single atomic operation.
	///
	/// - Parameters:
	///   - batch: A block providing a store reference and a batch object on which writes are done
	/// - Returns: A signal producer with the result of batch block
	public func batchUpdate<T>(batch: @escaping (_ batch: WriteBatch, _ store: Firestore) throws -> T) -> SignalProducer<T, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.batchUpdate(batch: batch,
							 completed: { observer.send(value: $0); observer.sendCompleted() },
							 failed: { observer.send(error: $0) })
		}
	}

	/// Performs deletions in a single atomic operation.
	///
	/// - Parameters:
	///   - path: Path
	///   - query: Block generating the query
	///   - batchSize: Number of deletions per batch
	///   - source: Where to fecth data object on which writes are done
	/// - Returns: A signal producer of the identifiers of the data that were deleted
    public func batchDelete(path: CollectionPath,
                            query: ((CollectionReference) -> Query)?,
                            batchSize: Int,
                            source: FirestoreSource) -> SignalProducer<[String], NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.batchDelete(path: path,
							 query: query,
							 batchSize: batchSize,
							 source: source,
							 completed: { observer.send(value: $0); observer.sendCompleted() },
							 failed: { observer.send(error: $0) })
		}
	}

}
#endif
