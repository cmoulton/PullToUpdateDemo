//
//  ViewController.swift
//  PullToUpdateDemo
//
//  Created by Christina Moulton on 2015-04-29.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var itemsArray:Array<StockQuoteItem>?
  @IBOutlet var tableView: UITableView?
  
  var refreshControl:UIRefreshControl!
  var dateFormatter = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    self.dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    self.tableView?.addSubview(refreshControl)
    
    self.loadStockQuoteItems()
  }
  
  func loadStockQuoteItems() {
    StockQuoteItem.getFeedItems({ (items, error) in
      if error != nil
      {
        var alert = UIAlertController(title: "Error", message: "Could not load images :( \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
      self.itemsArray = items
      
      // update "last updated" title for refresh control
      let now = NSDate()
      let updateString = "Last Updated at " + self.dateFormatter.stringFromDate(now)
      self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
      if self.refreshControl.refreshing
      {
        self.refreshControl.endRefreshing()
      }
      
      self.tableView?.reloadData()
    })
  }
  
  func refresh(sender:AnyObject)
  {
    self.loadStockQuoteItems()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.itemsArray?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    let item = self.itemsArray?[indexPath.row]
    cell.textLabel?.text = ""
    cell.detailTextLabel?.text = ""
    if let symbol = item?.symbol
    {
      if let ask = item?.ask
      {
        cell.textLabel?.text = symbol + " @ $" + ask
      }
    }
    if let low = item?.yearLow
    {
      if let high = item?.yearHigh
      {
        cell.detailTextLabel?.text = "Year: " + low + " - " + high
      }
    }
    return cell
  }
  
}

