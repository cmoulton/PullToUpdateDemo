//
//  ViewController.swift
//  PullToUpdateDemo
//
//  Created by Christina Moulton on 2015-04-29.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var itemsArray:Array<CurrencyItem>?
  @IBOutlet var tableView: UITableView?
  
  var refreshControl:UIRefreshControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    self.tableView?.addSubview(refreshControl)
    
    self.loadCurrencyItems()
  }
  
  func loadCurrencyItems() {
    CurrencyItem.getFeedItems({ (items, error) in
      if error != nil
      {
        var alert = UIAlertController(title: "Error", message: "Could not load images :( \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
      self.itemsArray = items
      if self.refreshControl.refreshing
      {
        self.refreshControl.endRefreshing()
      }
      self.tableView?.reloadData()
    })
  }
  
  func refresh(sender:AnyObject)
  {
    self.loadCurrencyItems()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.itemsArray?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    let item = self.itemsArray?[indexPath.row]
    cell.textLabel?.text = ""
    if let name = item?.name
    {
      if let price = item?.price
      {
        cell.textLabel?.text = name + " @ $" + price
      }
    }
    cell.detailTextLabel?.text = item?.utctime
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
}

