//
//  ViewController.swift
//  TodoList
//
//  Created by Walid  on 7/27/20.
//  Copyright © 2020 Walid . All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeViewController {
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [Category]()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.separatorStyle = .none
        loadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        navBar.backgroundColor = UIColor(hexString: "007AFF")
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        
       if let colorHex = UIColor(hexString: category.color){
            cell.backgroundColor = colorHex
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colorHex, returnFlat: true)

        }
                
        return cell
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinaton = segue.destination as! ItemViewController
       if let indexPath = tableView.indexPathForSelectedRow{
        destinaton.selectedCategory = categories[indexPath.row]
        }
    }
    // MARK: - adding and loading and deleting data

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.color = UIColor.randomFlat().hexValue()
            self.categories.append(newCategory)
            self.saveData()
            self.tableView.reloadData()

        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveData(){
        do{
            try context.save()
        }catch{
            print("There is an error while saving data \(error)")
        }
    }
    
    func loadData(request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
           categories = try context.fetch(request)
        }catch{
            print("There is an error while loading data \(error)")

        }
        tableView.reloadData()
    }
    
    override func updateModel(indexPath: IndexPath) {
          self.context.delete(self.categories[indexPath.row])
          self.categories.remove(at: indexPath.row)

          self.saveData()
    }
}

