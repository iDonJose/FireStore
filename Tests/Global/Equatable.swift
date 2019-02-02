//
//  Equatable.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 01/02/2019.
//

import Foundation


public func == <Key: Hashable, Value>(lhs: [Key: Value], rhs: [Key: Value] ) -> Bool {
	return NSDictionary(dictionary: lhs).isEqual(rhs)
}

public func != <Key: Hashable, Value>(lhs: [Key: Value], rhs: [Key: Value] ) -> Bool {
	return !(lhs == rhs)
}


public func == <Key: Hashable, Value>(lhs: [Key: Value]?, rhs: [Key: Value]?) -> Bool {
	switch (lhs, rhs) {
	case (nil, nil):
		return true
	case (nil, _),
		 (_, nil):
		return false
	default:
		return lhs! == rhs!
	}
}

public func != <Key: Hashable, Value>(lhs: [Key: Value]?, rhs: [Key: Value]?) -> Bool {
	return !(lhs == rhs)
}
