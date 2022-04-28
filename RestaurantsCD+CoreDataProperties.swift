//
//  RestaurantsCD+CoreDataProperties.swift
//  myClassProject
//
//  Created by Travis howard on 4/20/22.
//
//

import Foundation
import CoreData


extension RestaurantsCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RestaurantsCD> {
        return NSFetchRequest<RestaurantsCD>(entityName: "RestaurantsCD")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var price: String?
    @NSManaged public var phone: String?
    @NSManaged public var rating: Float
    @NSManaged public var distance: Float
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var image_index: Int32
    @NSManaged public var category: String?
    @NSManaged public var images: [Data]?

}

extension RestaurantsCD : Identifiable {

}
