//
//  ToDoListViewController.swift
//  ToDo
//
//
//

import UIKit

class ToDoListTableViewCell: UITableViewCell {
    
    @IBOutlet var btn_chkbox: UIButton!
    @IBOutlet var lbl_todoList: UILabel!
    @IBOutlet var btn_edit: UIButton!
    @IBOutlet var btn_delete: UIButton!
    
    @IBOutlet var lbl_date: UILabel!
    
    var chkBox: (() -> Void)?
    
    @IBAction func btn_checkBox(_ sender: UIButton) {
        
        chkBox?()
        
    }
    
    var editTask: (() -> Void)?
    
    @IBAction func btn_edit(_ sender: Any) {
        
        editTask?()
        
    }
    
    var deleteTask: (() -> Void)?
    
    @IBAction func btn_delete(_ sender: UIButton) {
        
        deleteTask?()
        
    }
    
}

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var vw_header: UIView!
    @IBOutlet var lbl_todo: UILabel!
    @IBOutlet var vw_task: UIView!
    @IBOutlet var txt_todoList: UITextField!
    @IBOutlet var btn_Add: UIButton!
    @IBOutlet var tv_todoList: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    var listArr: [(String,String,String)] = []
    var cpy_listArr: [(String,String,String)] = []
    var toast = Toast()
    var isChecked = false
    
    @IBAction func btn_Add(_ sender: UIButton)  {
        
        
        guard let newItem = txt_todoList.text, !newItem.isEmpty else {
            
            //Show Toast message when text field is empty
            self.toast.show(message: "Please Enter the text", controller: self)
            return
        }
        
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy hh:mm a"
        let formattedDate = dateFormatter.string(from: dt)

        listArr.append((newItem, "N", formattedDate)) //"N" for strike line want yes or no(N)

        saveData()
        
        
        //Clear text field
        txt_todoList.text = ""
        
        tv_todoList.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //count of array
        return listArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv_todoList.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! ToDoListTableViewCell
        
        let todolist = listArr[indexPath.row]
        
        //        cell.chkBox = {
        //
        //            self.checkedStates[indexPath.row].toggle()
        //            let isChecked = self.checkedStates[indexPath.row]
        //            let checkboxImage = isChecked ? UIImage(named: "checkbox_blue") : UIImage(named: "checkbox_black")
        //            cell.btn_chkbox.setImage(checkboxImage, for: .normal)
        //        }
        
        
        if todolist.1 == "N" { //check if striked N(means Not Strike)
            let image = UIImage(named: "checkbox_black")
            cell.btn_chkbox.setImage(image, for: .normal)
            cell.btn_chkbox.isSelected = false
            cell.btn_edit.isHidden = false
            cell.lbl_todoList.attributedText = NSAttributedString(string: todolist.0)
            
        } else {
            let image = UIImage(named: "checkbox_blue")
            cell.btn_chkbox.setImage(image, for: .normal)
            cell.btn_chkbox.isSelected = true
            cell.btn_edit.isHidden = true
            
            let attributeString = NSMutableAttributedString(string: todolist.0)
            
            //Set Strike Line
            //  let attributeString = NSMutableAttributedString(string: self.listArr[indexPath.row])
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSMakeRange(0, attributeString.length)
            )
            cell.lbl_todoList.attributedText = attributeString
        }
        
       
        cell.lbl_date.text = todolist.2
        
        //for delete task
        cell.deleteTask = {
            
            //delete task
            print(indexPath.row)
            
            self.listArr.remove(at: indexPath.row)
            self.tv_todoList.deleteRows(at: [indexPath], with: .fade)
            self.saveData()
            self.tv_todoList.reloadData()
        }
        
        //for edit task
        cell.editTask = {
            
            self.editTask(at: indexPath.row)
            
        }
        
        return cell
        
    }
    
    func editTask(at index: Int) {
        let alertController = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = self.listArr[index].0 //Enter Default Value to TextField
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let newText = alertController.textFields?.first?.text, !newText.isEmpty {
                self?.listArr[index].0 = newText
                self?.tv_todoList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                self?.saveData()
            }
        }
        alertController.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tv_todoList.cellForRow(at: indexPath) as! ToDoListTableViewCell
        //cell.chkBox?()
        let attributeString = NSMutableAttributedString(string: self.listArr[indexPath.row].0)
        
        if cell.btn_chkbox.isSelected == false { // when button is not selected
            
            cell.btn_chkbox.isSelected.toggle() // then button is selected
            let image = UIImage(named: "checkbox_blue")
            cell.btn_chkbox.setImage(image, for: .normal)
            //Set Strike Line
            //  let attributeString = NSMutableAttributedString(string: self.listArr[indexPath.row])
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSMakeRange(0, attributeString.length)
            )
            cell.lbl_todoList.attributedText = attributeString
            cell.btn_edit.isHidden.toggle() // hide edit button
            self.listArr[indexPath.row].1 = "Y" // Set Strike line
            
            
        } else {
            
            cell.btn_chkbox.isSelected.toggle() //button is not selected
            let image = UIImage(named: "checkbox_black")
            cell.btn_chkbox.setImage(image, for: .normal)
            attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
            
            cell.lbl_todoList.attributedText = attributeString
            cell.btn_edit.isHidden.toggle() // Not hide edit button
            self.listArr[indexPath.row].1 = "N" // Remove Strike Line
        }
        
        saveData()  // Save Changes into UserDefaults
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let text = self.listArr[indexPath.row].0
        // Calculate the height required for the label with the given text
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0 // Allows label to have multiple lines
        label.lineBreakMode = .byWordWrapping
        let maxSize = CGSize(width: tableView.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let requiredSize = label.sizeThatFits(maxSize)
        // Add padding or other adjustments to the height if necessary
        let rowHeight = requiredSize.height + 80 // 20 is an example padding value
        return rowHeight
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_todo.text = "ToDo List"
        txt_todoList.placeholder = "Enter Task"
        btn_Add.layer.cornerRadius = btn_Add.frame.height / 2
        btn_Add.setTitle("ADD", for: .normal)
        txt_todoList.setPlaceholderColor(UIColor.lightText)
        txt_todoList.layer.borderWidth = 1.0
        txt_todoList.layer.borderColor = UIColor(hexString: "#2A2A2A").cgColor
        txt_todoList.layer.cornerRadius = 5
        
        if let storeList = UserDefaults.standard.array(forKey: "todolist") as? [[String: String]] {
            
            //Convert Map into normal array
            let Arr: [(String, String, String)] = storeList.compactMap { dict in
                if let item = dict["item"], let status = dict["status"] , let currdt = dict["date"] {
                    return (item, status, currdt)
                }
                return nil
            }
            listArr = Arr
            cpy_listArr = Arr
        }
        
        
        if let txt_srchFld = searchBar.value(forKey: "searchField") as? UITextField {
            
            txt_srchFld.textColor = UIColor.white
            
            if let clearButton = txt_srchFld.value(forKey: "clearButton") as? UIButton {
                // Set the color of the clear button image
                let tintedImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(tintedImage, for: .normal)
                clearButton.tintColor = UIColor.white // Set your desired color
            }
            if let searchIconView = txt_srchFld.leftView as? UIImageView {
                searchIconView.image = searchIconView.image?.withRenderingMode(.alwaysTemplate)
                searchIconView.tintColor = UIColor.green // Set your desired color
                searchIconView.isUserInteractionEnabled = false
            }
            
        }
        
        
        
        tv_todoList.delegate = self
        tv_todoList.dataSource = self
        searchBar.delegate = self
        
    }
    
    func saveData() {
        
        for i in 0..<listArr.count {
            
            
            
            
        }

        let todoListData = listArr.map { ["item": $0.0, "status": $0.1, "date": $0.2] }
        UserDefaults.standard.set(todoListData, forKey: "todolist")
        
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if searchText == "" {
            listArr = cpy_listArr
        } else {
        
        listArr = []
        
        for i in 0..<cpy_listArr.count {
            
            if cpy_listArr[i].0.contains(searchText) {
                
                listArr.append(cpy_listArr[i])
            }
        }
    }
        tv_todoList.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        listArr = cpy_listArr
    }
    
}

extension UITextField {
    
    //Set color for placeholder
    func setPlaceholderColor(_ color: UIColor) {
        guard let placeholder = self.placeholder else { return }
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
        
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }}
