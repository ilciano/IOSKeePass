/*
 * Copyright 2016 Jason Rush and John Flanagan. All rights reserved.
 * Mdified by Frank Hausmann 2020-2021
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit
import KeyboardGuide

class FilesViewController: UITableViewController, NewDatabaseDelegate,ImportDatabaseDelegate, UIDocumentBrowserViewControllerDelegate {
    private let databaseReuseIdentifier = "DatabaseCell"
    private let keyFileReuseIdentifier = "KeyFileCell"

    lazy var documentBrowser: DocumentBrowserViewController = {
      return DocumentBrowserViewController()
    }()

    private enum Section : Int {
        case databases = 0
        case keyFiles = 1
        static let AllValues = [Section.databases, Section.keyFiles]
    }

    var databaseFiles: [String] = []
    var keyFiles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Activate KeyboardGuide at the beginning of application life cycle.
        KeyboardGuide.shared.activate()
        
        let appSettings = AppSettings.sharedInstance() as AppSettings
        
        if #available(iOS 13.0, *) {
            if (appSettings.darkEnabled()) {
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                    print("Dark mode")
                    self.navigationController?.overrideUserInterfaceStyle = .dark
                }
            }else{
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                    print("Light mode")
                }
            }
        }
   
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
      
       
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        updateFiles();
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "newDatabase"?:
            guard let navigationController = segue.destination as? UINavigationController,
                let newDatabaseViewController = navigationController.topViewController as? NewDatabaseViewController else {
                    return
            }

            newDatabaseViewController.delegate = self
        case "fileOpened"?:
            guard let groupViewController = segue.destination as? GroupViewController else {
                return
            }
            
            
            let appDelegate = AppDelegate.getDelegate()
            let document = appDelegate?.getOpenDataBase()//appDelegate?.databaseDocument
            let adb = AutoFillDB()
            let dname = URL(fileURLWithPath: document!.filename).lastPathComponent
            if(!adb.IsKeePassInAutoFill(dbname: dname)){
                
            
            
                let group = DispatchGroup()
                    group.enter()

                    // avoid deadlocks by not using .main queue here
                DispatchQueue.global(qos: .default).async {
                    appDelegate?.buildAutoFillIfNeeded(dname)
                    
                        group.leave()
                    }

                // wait ...
                group.wait()
            }
            
           
            
            groupViewController.parentGroup = document?.kdbTree.root
            groupViewController.title = URL(fileURLWithPath: document!.filename).lastPathComponent
            groupViewController.tagid = 1;
            
           
        case "importDatabase"?:
           displayDocumentBrowser()
            


        default:
            break
        }
    }
    
    
    
    func displayDocumentBrowser(inboundURL: URL? = nil, importIfNeeded: Bool = true) {
      //if presentationContext == .launched {
        documentBrowser.impDBdelegate = self;
        present(documentBrowser, animated: false)
      //}
      //presentationContext = .browsing
    }

    @objc func updateFiles() {
        if let databaseManager = DatabaseManager.sharedInstance() {
            databaseFiles = databaseManager.getDatabases() as! [String]
            keyFiles = databaseManager.getKeyFiles() as! [String]
        }
    }
    
    // MARK: - Empty State

    func toggleEmptyState() {
        if (databaseFiles.count == 0 && keyFiles.count == 0) {
            let emptyStateLabel = UILabel()
            emptyStateLabel.text = NSLocalizedString("Tap the + button to add a new KeePass file.", comment: "")
            emptyStateLabel.textAlignment = .center
            emptyStateLabel.textColor = UIColor.gray
            emptyStateLabel.numberOfLines = 0
            emptyStateLabel.lineBreakMode = .byWordWrapping

            tableView.backgroundView = emptyStateLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    // MARK: - UITableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.AllValues.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section.AllValues[section] {
        case .databases:
            return NSLocalizedString("Databases", comment: "")
        case .keyFiles:
            return NSLocalizedString("Key Files", comment: "")
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Hide the section titles if there are no files in a section
        switch Section.AllValues[section] {
        case .databases:
            if (databaseFiles.count == 0) {
                return 0
            }
        case .keyFiles:
            if (keyFiles.count == 0) {
                return 0
            }
        }

        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toggleEmptyState()

        switch Section.AllValues[section] {
        case .databases:
            return databaseFiles.count
        case .keyFiles:
            return keyFiles.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let filename: String

        // Get the cell and filename
        switch Section.AllValues[indexPath.section] {
        case .databases:
            cell = tableView.dequeueReusableCell(withIdentifier: databaseReuseIdentifier, for: indexPath)
            filename = databaseFiles[indexPath.row]
        case .keyFiles:
            cell = tableView.dequeueReusableCell(withIdentifier: keyFileReuseIdentifier, for: indexPath)
            filename = keyFiles[indexPath.row]
        }

        cell.textLabel!.text = filename

        // Get the file's last modification time
        let databaseManager = DatabaseManager.sharedInstance()
        let url = databaseManager?.getFileUrl(filename)
        let size = databaseManager?.getFileSize(url)
        let date = databaseManager?.getFileLastModificationDate(url)
        let nowdate = Date()
        var sstr = String(format:"%@ Bytes", size!)
        
        if(Int64(truncating: size!) > 1024){
            sstr = String(format:"%d KB", Int64(truncating: size!)/1024)
        }
        
        if(Int64(truncating: size!) > (1024*1024)){
            sstr = String(format:"%d MB", Int64(truncating: size!)/1024/1024)
        }
        
        if(Int64(truncating: size!) > (1024*1024*1024)){
            sstr = String(format:"%d GB", Int64(truncating: size!)/1024/1024/1024)
        }
        
        // Format the last modified time as the subtitle of the cell
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.detailTextLabel!.text = NSLocalizedString("Last Modified", comment: "") + ": " + dateFormatter.string(from: date ?? nowdate) + " Size:" + sstr

        return cell
    }

    // MARK: - UITableView delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Load the database
        /*let keychainItemQuery = [
          kSecValueData: "Pullip2020".data(using: .utf8)!,
          kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        var status = SecItemAdd(keychainItemQuery, nil)
        print("Keychain Operation finished with status: \(status)")
        
        let keychainItem = [
          kSecValueData: "Pullip2020".data(using: .utf8)!,
          kSecAttrAccount: "andyibanez",
          kSecAttrServer: "pullipstyle.com",
          kSecClass: kSecClassInternetPassword
        ] as CFDictionary

        status = SecItemAdd(keychainItem, nil)
        print("Operation finished with status: \(status)")*/
        
        /*let keychain = KeychainSwift(server: "mumpitz.com", protocolType: .https)

     
        let items = keychain.allItems()
        for item in items {
          print("Keychain item: \(item)")
        }
        */
        let databaseManager = DatabaseManager.sharedInstance()
        // Move to a background thread to do some long running work
        //AppDelegate.showGlobalProgressHUD(withTitle:"loading..")
        //DispatchQueue.global(qos: .userInitiated).async {
            databaseManager?.openDatabaseDocument(self.databaseFiles[indexPath.row], animated: true)
            
            /*DispatchQueue.main.async {
                AppDelegate.dismissGlobalHUD()
            }
        }*/
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.deleteRowAtIndexPath(indexPath)
        }
        
        let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "")) { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.renameRowAtIndexPath(indexPath)
        }
        
        switch Section.AllValues[indexPath.section] {
        case .databases:
            return [deleteAction, renameAction]
        case .keyFiles:
            return [deleteAction]
        }
    }
    
    func renameRowAtIndexPath(_ indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "RenameDatabase", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        let viewController = navigationController.topViewController as! RenameDatabaseViewController
        viewController.donePressed = { (renameDatabaseViewController: RenameDatabaseViewController, originalUrl: URL, newUrl: URL) in
            let databaseManager = DatabaseManager.sharedInstance()
            databaseManager?.renameDatabase(originalUrl, newUrl: newUrl)
            
            // Update the filename in the files list
            self.databaseFiles[indexPath.row] = newUrl.lastPathComponent
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            
            self.dismiss(animated: true, completion: nil)
        }
        
        let databaseManager = DatabaseManager.sharedInstance()
        viewController.originalUrl = databaseManager?.getFileUrl(databaseFiles[indexPath.row])
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func deleteRowAtIndexPath(_ indexPath: IndexPath) {
        // Get the filename to delete
        let filename: String
        switch Section.AllValues[indexPath.section] {
        case .databases:
            filename = databaseFiles.remove(at: indexPath.row)
        case .keyFiles:
            filename = keyFiles.remove(at: indexPath.row)
        }
        
        // Delete the file
        let databaseManager = DatabaseManager.sharedInstance()
        databaseManager?.deleteFile(filename)
        
        // Update the table
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func newDatabaseCreated(filename: String) {
        let index = self.databaseFiles.insertionIndexOf(filename) {
            $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
        }
        self.databaseFiles.insert(filename, at: index)
        
        // Notify the table of the new row
        if (self.databaseFiles.count == 1) {
            // Reload the section if it was previously empty
            let indexSet = IndexSet(integer: Section.databases.rawValue)
            self.tableView.reloadSections(indexSet, with: .right)
        } else {
            let indexPath = IndexPath(row: index, section: Section.databases.rawValue)
            self.tableView.insertRows(at: [indexPath], with: .right)
        }
    }
    
    func importDatabaseCreated(fileURL: URL) {
      
       
        // Move database file from bundle to documents folder
            
            let fileManager = FileManager.default
            
            let documentsUrl = fileManager.urls(for: .documentDirectory,
                                                        in: .userDomainMask)
            
            guard documentsUrl.count != 0 else {
                return // Could not find documents URL
            }
            
            let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(fileURL.lastPathComponent)
        
            if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
                print("DB does not exist in documents folder")
                
               // let documentsURL = Bundle.main.resourceURL?.appendingPathComponent("SQL.sqlite")
                
                do {
                    let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
                       defer {
                         if didStartAccessing {
                           fileURL.stopAccessingSecurityScopedResource()
                         }
                       }
                    try fileManager.copyItem(atPath: (fileURL.path), toPath: finalDatabaseURL.path)
                      if(fileManager.fileExists(atPath: finalDatabaseURL.path)){
                      
                           let index = self.databaseFiles.insertionIndexOf(fileURL.lastPathComponent) {
                               $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
                           }
                           self.databaseFiles.insert(fileURL.lastPathComponent, at: index)
                           
                           // Notify the table of the new row
                           if (self.databaseFiles.count == 1) {
                               // Reload the section if it was previously empty
                               let indexSet = IndexSet(integer: Section.databases.rawValue)
                               self.tableView.reloadSections(indexSet, with: .right)
                           } else {
                               let indexPath = IndexPath(row: index, section: Section.databases.rawValue)
                               self.tableView.insertRows(at: [indexPath], with: .right)
                           }
                    }
                    } catch let error as NSError {
                        print("Couldn't copy file to final location! Error:\(error.description)")
                }
 
            } else {
                print("Database file found at path: \(finalDatabaseURL.path)")
            }
       /* let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsPath+"/"+fileURL.lastPathComponent
        //let ori = fileURL.path
         let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: ori)){
            print(ori)
        }
        do{
         try fileManager.copyItem(at: URL, to: path)
        
            if(fileManager.fileExists(atPath: path)){
           
                let index = self.databaseFiles.insertionIndexOf(fileURL.lastPathComponent) {
                    $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
                }
                self.databaseFiles.insert(fileURL.lastPathComponent, at: index)
                
                // Notify the table of the new row
                if (self.databaseFiles.count == 1) {
                    // Reload the section if it was previously empty
                    let indexSet = IndexSet(integer: Section.databases.rawValue)
                    self.tableView.reloadSections(indexSet, with: .right)
                } else {
                    let indexPath = IndexPath(row: index, section: Section.databases.rawValue)
                    self.tableView.insertRows(at: [indexPath], with: .right)
                }
            }
        }catch {
            print("Copy operation failed . Abort with error: \(error.localizedDescription)")
        }*/
        
       }
    
   
}
