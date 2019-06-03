//
//  TagDataSource.swift
//  Photorama1
//
//  Created by Alex on 4/3/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import UIKit
import CoreData
class TagDataSource: NSObject, UITableViewDataSource {
  
    
    var tags: [Tag] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name
        cell.accessibilityHint = "Double tap to toggle selected"
        return cell
    }
    
}
