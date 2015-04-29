//
//  CurrencyItems.swift
//  PullToUpdateDemo
//
//  Created by Christina Moulton on 2015-04-29.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

/* Feed (http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json) looks like
{
"list": {
  "meta": {
    "type": "resource-list",
    "start": 0,
    "count": 173
  },
  "resources": [
    {
    "resource": {
    "classname": "Quote",
    "fields": {
      "name": "USD\/KRW",
      "price": "1067.944946",
      "symbol": "KRW=X",
      "ts": "1430321940",
      "type": "currency",
      "utctime": "2015-04-29T15:39:00+0000",
      "volume": "0"
    }
    }
  },
  ...
*/

class CurrencyItem {
  let name: String
  let utctime: String
  let price: String
  
  required init(currencyName: String, currencyPrice: String, quoteTime: String) {
    self.name = currencyName
    self.price = currencyPrice
    self.utctime = quoteTime
  }
  
  class func endpointForFeed() -> String {
    return "http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"//"https://api.currency.com/services/feeds/photos_public.gne?format=json"
  }
  
  class func getFeedItems(completionHandler: (Array<CurrencyItem>?, NSError?) -> Void) {
    Alamofire.request(.GET, self.endpointForFeed())
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
      println(jsonString!)
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
      
      var itemsArray:Array<CurrencyItem> = Array<CurrencyItem>()
      println(json)
      let items = json["list"]["resources"].arrayValue
      println(items)
      for jsonItem in items
      {
        let resource = jsonItem["resource"]
        println(resource)
        let fields = resource["fields"]
        println(fields)
        let name = fields["name"].stringValue
        let price = fields["price"].stringValue
        let utcTime = fields["utctime"].stringValue
        let item = CurrencyItem(currencyName: name, currencyPrice: price, quoteTime: utcTime)
        itemsArray.append(item)
      }
      return (itemsArray, nil)
    }
  }
  
  func responseItemsArray(completionHandler: (NSURLRequest, NSHTTPURLResponse?, Array<CurrencyItem>?, NSError?) -> Void) -> Self {
    return response(serializer: Request.itemsArrayResponseSerializer(), completionHandler: { (request, response, itemsArray, error) in
      completionHandler(request, response, itemsArray as? Array<CurrencyItem>, error)
    })
  }
}