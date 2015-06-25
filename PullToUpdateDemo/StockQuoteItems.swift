//
//  StockQuoteItems.swift
//  PullToUpdateDemo
//
//  Created by Christina Moulton on 2015-04-29.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

/* Feed of Apple, Yahoo & Google stock prices (ask, year high & year low) from Yahoo ( https://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20Ask%2C%20YearHigh%2C%20YearLow%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22AAPL%22%2C%20%22GOOG%22%2C%20%22YHOO%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys ) looks like
  {
    "query": {
      "count": 3,
      "created": "2015-04-29T16:21:42Z",
      "lang": "en-us",
      "results": {
        "quote": [
          {
          "symbol": "AAPL"
          "YearLow": "82.904",
          "YearHigh": "134.540",
          "Ask": "129.680"
          },
          ...
        ]
      }
    }
  }
*/
// See https://developer.yahoo.com/yql/ for tool to create queries

class StockQuoteItem {
  let symbol: String
  let ask: String
  let yearHigh: String
  let yearLow: String
  
  required init(stockSymbol: String, stockAsk: String, stockYearHigh: String, stockYearLow: String) {
    self.symbol = stockSymbol
    self.ask = stockAsk
    self.yearHigh = stockYearHigh
    self.yearLow = stockYearLow
  }
  
  class func endpointForFeed(symbols: Array<String>) -> String {
    //    let wrappedSymbols = symbols.map { $0 = "\"" + $0 + "\"" }
    let symbolsString:String = "\", \"".join(symbols)
    let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbolsString) \")&format=json&env=http://datatables.org/alltables.env"
    let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    
    let endpoint = "https://query.yahooapis.com/v1/public/yql?q=" + encodedQuery!
    return endpoint
  }
  
  class func getFeedItems(symbols: Array<String>, completionHandler: (Array<StockQuoteItem>?, NSError?) -> Void) {
    Alamofire.request(.GET, self.endpointForFeed(symbols))
      .responseItemsArray { (request, response, itemsArray, error) in
        if let anError = error
        {
          completionHandler(nil, error)
          return
        }
        completionHandler(itemsArray, nil)
    }
  }
}

extension Alamofire.Request {
  class func itemsArrayResponseSerializer() -> Serializer {
    return { request, response, data in
      if data == nil {
        return (nil, nil)
      }
      var jsonString = NSString(data: data!, encoding:NSUTF8StringEncoding)
      var jsonError: NSError?
      let jsonData:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments, error: &jsonError)
      if jsonData == nil || jsonError != nil
      {
        return (nil, jsonError)
      }
      let json = JSON(jsonData!)
      if json.error != nil || json == nil
      {
        return (nil, json.error)
      }
      
      var itemsArray:Array<StockQuoteItem> = Array<StockQuoteItem>()
      let quotes = json["query"]["results"]["quote"].arrayValue

      for jsonItem in quotes
      {
        let symbol = jsonItem["symbol"].stringValue
        let yearLow = jsonItem["YearLow"].stringValue
        let yearHigh = jsonItem["YearHigh"].stringValue
        let ask = jsonItem["Ask"].stringValue
        let item = StockQuoteItem(stockSymbol: symbol, stockAsk: ask, stockYearHigh: yearHigh, stockYearLow: yearLow)
        itemsArray.append(item)
      }
      return (itemsArray, nil)
    }
  }
  
  func responseItemsArray(completionHandler: (NSURLRequest, NSHTTPURLResponse?, Array<StockQuoteItem>?, NSError?) -> Void) -> Self {
    return response(serializer: Request.itemsArrayResponseSerializer(), completionHandler: { (request, response, itemsArray, error) in
      completionHandler(request, response, itemsArray as? Array<StockQuoteItem>, error)
    })
  }
}