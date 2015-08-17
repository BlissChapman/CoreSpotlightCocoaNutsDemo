//
//  ColorTableViewController.swift
//  CoreSpotlightPracticeCocoaNuts
//
//  Created by Bliss Chapman on 8/15/15.
//  Copyright (c) 2015 Bliss Chapman. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class ColorTableViewController: UITableViewController {
    
    private let colors: [UIColor] = [
        .blackColor(),
        .darkGrayColor(),
        .lightGrayColor(),
        .whiteColor(),
        .grayColor(),
        .redColor(),
        .greenColor(),
        .blueColor(),
        .cyanColor(),
        .yellowColor(),
        .magentaColor(),
        .orangeColor(),
        .purpleColor(),
        .brownColor(),
        .clearColor()
    ]
    
    private let correspondingColorDescriptions: [String] = [
        "Black",
        "Dark Gray",
        "Light Gray",
        "White",
        "Gray",
        "Red",
        "Green",
        "Blue",
        "Cyan",
        "Yellow",
        "Magenta",
        "Orange",
        "Purple",
        "Brown",
        "Clear",
    ]
    
    private var favoriteColorIndices: [Int]? {
        get { return NSUserDefaults.standardUserDefaults().valueForKey("favoriteColorIndices") as? [Int] }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "favoriteColorIndices")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        if favoriteColorIndices == nil { favoriteColorIndices = [] }
        
        for indice in favoriteColorIndices! {
            let indexPath = NSIndexPath(forRow: indice, inSection: 0)
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: indice, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return colors.count }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("colorCellReuseID", forIndexPath: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = correspondingColorDescriptions[indexPath.row]
        cell.backgroundColor = colors[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        do {
            try indexFavoriteColor(indexPath.row)
            
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            print(tableView.cellForRowAtIndexPath(indexPath)?.selected)
            favoriteColorIndices?.append(indexPath.row)
            
        } catch IndexingError.OperatingSystem {
            fatalError("Failed to index the selected color because Core Spotlight is not supported on this version of iOS.")
        } catch {
            print("Indexing failed.")
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        do {
            try deindexColor(indexPath.row)
            
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            
            //removes any elements of value 'indexPath.row' from the array
            favoriteColorIndices = favoriteColorIndices?.filter({$0 != indexPath.row})
            
        } catch IndexingError.OperatingSystem {
            fatalError("Failed to index the selected color because Core Spotlight is not supported on this version of iOS.")
        } catch {
            print("Indexing failed.")
        }
    }
    
    
    //MARK: Spotlight Indexing
    enum IndexingError: ErrorType {
        case OperatingSystem
    }
    
    func indexFavoriteColor(colorIndex: Int) throws {
        if #available(iOS 9.0, *) {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            attributeSet.title = correspondingColorDescriptions[colorIndex]
            attributeSet.contentDescription = "Favorite Color!"
            
            let keywords = ["Favorite Colors", "Color", correspondingColorDescriptions[colorIndex]]
            attributeSet.keywords = keywords
            
            let item = CSSearchableItem(uniqueIdentifier: correspondingColorDescriptions[colorIndex], domainIdentifier: "com.blissChapman", attributeSet: attributeSet)
            
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item], completionHandler: { (error) -> Void in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                
                print("The new favorite color was successfully indexed.")
            })
        } else {
            //Core Spotlight apis are not available on iOS versions under 9.0
            throw IndexingError.OperatingSystem
        }
    }
    
    
    func deindexColor(colorIndex: Int) throws {
        if #available(iOS 9.0, *) {
            CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers([correspondingColorDescriptions[colorIndex]]) { (error: NSError?) -> Void in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }
                
                print("The color was successfully deindexed.")
            }
        } else {
            throw IndexingError.OperatingSystem
        }
    }
}
