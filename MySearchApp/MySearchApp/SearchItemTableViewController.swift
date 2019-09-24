//
//  SearchItemTableViewController.swift
//  MySearchApp
//
//  Created by 長坂豪士 on 2019/09/24.
//  Copyright © 2019 Tsuyoshi Nagasaka. All rights reserved.
//

import UIKit

class SearchItemTableViewController: UITableViewController, UISearchBarDelegate {

    var itemDataArray = [ItemData]()
    
    var imageCache = NSCache<AnyObject, UIImage>()
    
    
    let appid = "dj00aiZpPU44VFpSRXJjaXBqMiZzPWNvbnN1bWVyc2VjcmV0Jng9NmU-"
    
    let entryURL: String = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    
    let priceFormat = NumberFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        priceFormat.numberStyle = .currency
        priceFormat.currencyCode = "JPY"
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let inputText = searchBar.text else {
            return
        }
    
        guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else {
            return
        }
        
        itemDataArray.removeAll()
        
        
        let parameter = ["appid": appid, "query": inputText]
        
        let requestUrl = createRequestUrl(parameter: parameter)
        
        
        request(requestUrl: requesturl)
        
        searchBar.resignFirstResponder()
    }
    
    
    func encodeParameter(key: String, value: String) -> String? {
        
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        return "\(key)=\(escapedValue)"
    }
    
    
    func createRequestUrl(parameter: [String: String]) -> String {
        var parameterString = ""
        for key in parameter.keys {
            guard let value = parameter[key] else {
                continue
            }
        
        
            if parameterString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                parameterString += "&"
            }
        
            guard let encodeValue = encodeParameter(key: key, value: value) else {
                continue
            }
            parameterString += encodeValue
        }
        let requestUrl = entryUrl + "?" + parameterString
        return requestUrl
    }
    
    func request(requestUrl: String) {
        
        guard let url = URL(string: requestUrl) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data:Data?, responce:URLResponse?, error:Error?) in
            
            guard error == nil else {
                let alert = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: UIAlertActionController.Style.alert)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let resultSet = try JSONDecoder().decode(ItemSearchResultSet.self, from: data)
                
                self.itemDataArray.append(contentsOf: resultSet.resultSet.firstObject.result.items)
            } catch let error {
                print("## error: \(error)")
            }
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemDataArray.count
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        
        let itemData = itemDataArray[indexPath.row]
        
        cell.itemTitleLabel.text = itemData.name
        
        let number = NSNumber(integerLiteral: Int(itemData.priceInfo.price!)!)
        cell.itemPriceLabel.text = priceFormat.string(from: number)
        
        cell.itemUrl = itemData.url
        
        
        guard let itemImageUrl = itemData.imageInfo.medium else {
            return cell
        }
        
        if let cacheImage = imageCache.object(forKey: itemImageUrl as Anyobject) {
            cell.itemImageView.image = cacheImage
            return cell
        }
        
        guard let url = URL(string: itemImageUrl) else {
            return cell
        }
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            self.imageCache.setObject(image, forKey: itemImageUrl as AnyObject)
            
            DispatchQueue.main.async {
                cell.itemImageView.image = image
            }
        }
        task.resume()

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ItemTableViewCell {
            if let webViewController = segue.destination as? WebViewController {
                webViewController.itemUrl = cell.itemUrl
            }
        }
    }
}
