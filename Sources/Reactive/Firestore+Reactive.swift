//
//  Firestore+Reactive.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

import FirebaseFirestore
import ReactiveSwift



extension Firestore: ReactiveExtensionsProvider {}

extension Reactive where Base: Firestore {

	// MARK: Read

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

	public func observe(path: DocumentPath,
						includeMetadataChanges: Bool) -> SignalProducer<DocumentSnapshot?, NSError> {

		return SignalProducer { [weak base] observer, lifetime in

			guard let base = base else { observer.sendCompleted(); return }

			let listener = base.observe(path: path,
										includeMetadataChanges: includeMetadataChanges,
										completed: { observer.send(value: $0); observer.sendCompleted() },
										failed: { observer.send(error: $0) })

			lifetime.observeEnded { listener.remove() }
		}
	}


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

	public func observe(path: CollectionPath,
						query: ((CollectionReference) -> Query)?,
						includeMetadataChanges: Bool) -> SignalProducer<QuerySnapshot?, NSError> {

		return SignalProducer { [weak base] observer, lifetime in

			guard let base = base else { observer.sendCompleted(); return }

			let listener = base.observe(path: path,
										query: query,
										includeMetadataChanges: includeMetadataChanges,
										completed: { observer.send(value: $0); observer.sendCompleted() },
										failed: { observer.send(error: $0) })

			lifetime.observeEnded { listener.remove() }
		}
	}



	// MARK: - Create

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
	public func merge(data: [String: Any],
					  fields: [String]?,
					  path: DocumentPath,
					  completed: @escaping (String) -> Void,
					  failed: @escaping (NSError) -> Void) -> SignalProducer<String, NSError> {

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

	public func delete(path: DocumentPath,
					   completed: @escaping (String) -> Void,
					   failed: @escaping (NSError) -> Void) -> SignalProducer<String, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.delete(path: path,
						completed: { observer.send(value: $0); observer.sendCompleted() },
						failed: { observer.send(error: $0) })
		}
	}



	// MARK: - Transaction

	public func runTransaction<T>(transaction: @escaping (_ transaction: Transaction, _ store: Firestore) throws -> T?) -> SignalProducer<T?, NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.runTransaction(transaction: transaction,
								completed: { observer.send(value: $0); observer.sendCompleted() },
								failed: { observer.send(error: $0) })
		}
	}


	// MARK: - Batch

	public func batchUpdate(batch: @escaping (WriteBatch) -> Void) -> SignalProducer<(), NSError> {

		return SignalProducer { [weak base] observer, _ in

			guard let base = base else { observer.sendCompleted(); return }

			base.batchUpdate(batch: batch,
							 completed: { observer.send(value: ()); observer.sendCompleted() },
							 failed: { observer.send(error: $0) })
		}
	}

}
