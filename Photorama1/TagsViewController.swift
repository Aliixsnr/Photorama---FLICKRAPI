//
//  TagsViewController.swift
//  Photorama1
//
//  Created by Alex on 4/3/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import UIKit
import CoreData
class TagsViewController: UITableViewController {
    var store: PhotoStore!
    var photo : Photo!
    
    var selectedIndexPaths = [IndexPath]()
    
    let tagDataSource = TagDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = tagDataSource
        updateTags()
    }
    
    @IBAction func done(_ sender: UIBarButtonItem){
        presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func addNewTag(_ sender: UIBarButtonItem){
        let alerController = UIAlertController(title: "Add Tag", message: nil, preferredStyle: .alert)
         alerController.addTextField { (textfield) in
            textfield.placeholder = "tag Name"
            textfield.autocorrectionType = .yes
            textfield.autocapitalizationType = .words
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
            if let tagName = alerController.textFields?.first?.text {
                let context = self.store.persistentContainer.viewContext
                let newTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)
                newTag.setValue(tagName, forKey: "name")
                
                do {
                    try self.store.persistentContainer.viewContext.save()
                } catch let error {
                    print("Core Data save failed: \(error)")
                }
                self.updateTags()
            }
            
        }
        alerController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alerController.addAction(cancelAction)
        present(alerController, animated: true, completion: nil)
    }
    
    
    
    
  override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let tag = tagDataSource.tags[indexPath.row]
    if let index = selectedIndexPaths.index(of: indexPath){
        selectedIndexPaths.remove(at: index)
        photo.removeFromTags(tag)
    } else {
        selectedIndexPaths.append(indexPath)
        photo.addToTags(tag)
    }
    do {
        try store.persistentContainer.viewContext.save()
    } catch  {
        print("Core Data save failed: \(error).")
    }
    tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
   override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if selectedIndexPaths.index(of: indexPath) != nil {
        cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
    }
}
    
    
    
    
    func updateTags(){
        store.fetchAllTags { (tagResult) in
            switch tagResult {
            case let .success(tags):
                self.tagDataSource.tags = tags
            case let .failure(error):
                print("Error fetching tags: \(error)")
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
