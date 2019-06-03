//
//  ItemStore.swift
//  Homepwner
//
//  Created by Alex on 3/6/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
class ItemStore {
    var allItems = [Item]()
    
    let itemArchiveURL: URL = {
            let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = documentsDirectories.first!
            return documentDirectory.appendingPathComponent("items.archive")
        
    }()
    
    // this annomation means that the results can be ignored, normally a function that returns a value must me store intoa a value
    @discardableResult func createdItem() -> Item {
        let newItem = Item(random: true)
        allItems.insert(newItem, at: 0)
        return newItem
    }
    @discardableResult func createDefaultItem() -> Item {
        let defaultItem = Item(name: "No more items!", valueInDollars: 0, serialNumber: "0")
//        allItems.insert(defaultItem, at: allItems.last?)
        allItems.append(defaultItem)
        return defaultItem
    }
    
    
    func removeItem(_ item: Item){
        if let index = allItems.index(of: item) {
            allItems.remove(at: index)
        }
    }
    func moveItem(from fromIndex: Int, to toIndex: Int){
        if fromIndex == toIndex {
            return
        } 
        let movedItem = allItems[fromIndex]
        allItems.remove(at: fromIndex)
        allItems.insert(movedItem, at: toIndex)
    }
    func saveChanges() -> Bool {
        print("Saving items to: \(itemArchiveURL.path)")
        return NSKeyedArchiver.archiveRootObject(allItems, toFile: itemArchiveURL.path)
    }
  init() {
    if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: itemArchiveURL.path) as? [Item] {
        allItems = archivedItems
    }
}
    
}








