//
//  UserPrefs+CoreDataProperties.swift
//  myClassProject
//
//  Created by Travis howard on 4/21/22.
//
//

import Foundation
import CoreData


extension UserPrefs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPrefs> {
        return NSFetchRequest<UserPrefs>(entityName: "UserPrefs")
    }

    @NSManaged public var location: String?
    @NSManaged public var sortType: String?
    @NSManaged public var showCategories: Bool

}

extension UserPrefs : Identifiable {

}
