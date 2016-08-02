//
//  ViewController.swift
//  FavoriteColors
//
//  Created by Bliss Chapman on 7/31/16.
//  Copyright © 2016 Bliss Chapman. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices


final class ViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    //MARK: - Model

    var colors: [(color: UIColor, colorDescription: String)] = [
        (.black(), "Black"),
        (.darkGray(), "Dark Gray"),
        (.lightGray(), "Light Gray"),
        (.white(), "White"),
        (.gray(), "Gray"),
        (.red(), "Red"),
        (.green(), "Green"),
        (.blue(), "Blue"),
        (.cyan(), "Cyan"),
        (.yellow(), "Yellow"),
        (.magenta(), "Magenta"),
        (.orange(), "Orange"),
        (.purple(), "Purple"),
        (.brown(), "Brown"),
        (.clear(), "Clear")
    ]

    private var favoriteColorIndices: [Int]? {
        get {
            return UserDefaults.standard.value(forKey: "favoriteColorIndices") as? [Int] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "favoriteColorIndices")
        }
    }

    //MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.allowsMultipleSelection = true

        if let selectedIndices = favoriteColorIndices {
            for indice in selectedIndices {
                let indexPath = IndexPath(row: indice, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - Core Spotlight

    private func indexFavoriteColor(colorIndex: Int) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        attributeSet.title = colors[colorIndex].colorDescription
        attributeSet.contentDescription = "Favorite Color!"
        attributeSet.keywords = ["Favorite Colors", "Color", attributeSet.contentDescription!, attributeSet.title!]

        let item = CSSearchableItem(uniqueIdentifier: attributeSet.title!, domainIdentifier: "com.blissChapman", attributeSet: attributeSet)

        CSSearchableIndex.default().indexSearchableItems([item]) { error in

            guard error == nil else {
                debugPrint(error!)
                return
            }

            print("\(self.colors[colorIndex].colorDescription) was successfully indexed.")
        }
    }

    private func deindexFavoriteColor(colorIndex: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [colors[colorIndex].colorDescription]) { error in

            guard error == nil else {
                debugPrint(error!)
                return
            }

            print("\(self.colors[colorIndex].colorDescription) was successfully deindexed.")
        }
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        favoriteColorIndices?.append(indexPath.row)
        indexFavoriteColor(colorIndex: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        favoriteColorIndices = favoriteColorIndices?.filter({ $0 != indexPath.row })
        deindexFavoriteColor(colorIndex: indexPath.row)
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "colorCellReuseID", for: indexPath)

        cell.backgroundColor = colors[indexPath.row].color
        cell.textLabel?.text = colors[indexPath.row].colorDescription

        return cell
    }
}
