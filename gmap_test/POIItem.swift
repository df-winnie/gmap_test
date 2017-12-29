//
//  PoIItem.swift
//  gmap_test
//
//  Created by Ziting Wei on 22/12/2017.
//  Copyright © 2017 df-dev. All rights reserved.
//

import UIKit

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
