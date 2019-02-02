//
//  Firebase.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 01/02/2019.
//

import FirebaseCore
import FirebaseFirestore
import Foundation



private final class Mock {}

private let app: FirebaseApp = {

	let path = Bundle(for: Mock.self)
		.path(forResource: "GoogleService-Info", ofType: "plist")!

	let options = FirebaseOptions(contentsOfFile: path)!
	FirebaseApp.configure(options: options)

	return FirebaseApp.app()!
}()


let store: Firestore = {

	let settings = FirestoreSettings()
	settings.dispatchQueue = DispatchQueue(label: "Firestore",
										   qos: .default)
	settings.isPersistenceEnabled = true
	settings.areTimestampsInSnapshotsEnabled = true

	let store = Firestore.firestore(app: app)
	store.settings = settings

	return store
}()
