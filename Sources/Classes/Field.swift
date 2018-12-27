//
//  Field.swift
//  FireStore-iOS
//
//  Created by José Donor on 26/12/2018.
//

import FirebaseFirestore



public struct Field {

	public static var documentId = FieldPath.documentID()


	public static var serverTimestamp = FieldValue.serverTimestamp()

	public static var delete = FieldValue.delete()

	public static func array(add elements: [Any]) -> FieldValue {
		return FieldValue.arrayUnion(elements)
	}

	public static func array(remove elements: [Any]) -> FieldValue {
		return FieldValue.arrayRemove(elements)
	}

}
