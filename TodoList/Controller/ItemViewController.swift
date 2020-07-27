//
//  ItemViewController.swift
//  TodoList
//
//  Created by Walid  on 7/27/20.
//  Copyright © 2020 Walid . All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
class ItemViewController: SwipeViewController {
    
    var selectedCategory: Category?{
        didSet{
            loadData()
        }
    }
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var todoItems = [Item]()

    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Search here"
        tableView.separatorStyle = .none
        loadData()

    }
    override func viewWillAppear(_ animated: Bool) {
        if let color = selectedCategory?.color{
            title = selectedCategory?.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError()
            }
            if let navColor = UIColor(hexString: color){
                navBar.backgroundColor = navColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: navColor, returnFlat: true)]
                navBar.tintColor = ContrastColorOf(backgroundColor: navColor, returnFlat: true)
                searchBar.barTintColor = navColor
            }
        }
    }
    
   
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = todoItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        if let color = UIColor(hexString: selectedCategory?.color).darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems.count)){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
        }

        return cell
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = todoItems[indexPath.row]
        item.done = !item.done
        saveData()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - adding and loading and deleting data

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text
            newItem.done = false
            newItem.dateCreated = Date()
            newItem.parentCategory = self.selectedCategory
            self.todoItems.append(newItem)
            self.saveData()
            self.tableView.reloadData()

        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
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
    
    func loadData(request: NSFetchRequest<Item> = Item.fetchRequest(),predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
                       

                   }else{
                       request.predicate = categoryPredicate
                   }
        do{
            todoItems = try context.fetch(request)
        }catch {
            print("There is an error while loading data \(error)")

        }
        tableView.reloadData()
    }
    override func updateModel(indexPath: IndexPath) {
        context.delete(todoItems[indexPath.row])
        todoItems.remove(at: indexPath.row)
        saveData()
    }
}


// MARK: - Search bar delegate

extension ItemViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        loadData(request: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
