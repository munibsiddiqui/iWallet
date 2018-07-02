//
//  Constants.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

let appDelegate = UIApplication.shared.delegate as? AppDelegate



struct Constants {
    //Defaults
    static let EDITABLE_CATEGORIES = "editableCategories"
    static let CURRENT_ACCOUNT = "currentAccount"
    static let CURRENT_TRANSACTION_TYPE = "currentTransactionType"
    static let CURRENT_CATEGORY = "currentCategory"

    static let CATEGORY_TRANSFER = "transfer"
    static let CATEGORY_UNCATEGORIZED = "uncategorized"
    static let NAME_FOR_EXTERNAL_ACCOUNT = "Withdraw"
    
    //URLs
    static let URL_CURRENCY_EXCHANGE_RATE = "http://data.fixer.io/api/latest?access_key="
    static let URL_CURRENCY_EXCHANGE_RATE_HISTORICAL = "http://data.fixer.io/api/"
    
    static let URL_FOURSQUARE =  "https://api.foursquare.com/v2/venues/search?"
    static let URL_IWALLET = "saltedge-api-swift-demo://home.local"
    static let URL_SE_CREATE_CUSTOMER = "https://www.saltedge.com/api/v4/customers/"
    static let URL_SE_GET_CATEGORY = "https://www.saltedge.com/api/v4/categories"
    static let URL_LOGIN = "https://iwalletsg.herokuapp.com"
//    static let URL_LOGIN = "http://localhost:3000"
    
    //API keys
    static let API_KEY_CURRENCY_EXCHANGE_RATE = ""
    static let API_CLIENT_ID_FOURSQUARE = ""
    static let API_CLIENT_SECRET_FOURSQUARE = ""
    
    static let APP_ID_SALTEDGE = ""
    static let APP_SECRET_SALTEDGE = ""
    
    static let APP_LOGIN_SECRET  = ""
    
    //Size
    static let  REGION_SIZE_FOURSQUARE = 1000
    
    //Currencies
    static let EUR = "EUR"
    
    static let colors = [
    #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),
    #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),
    #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),
    #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
    #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1),
    #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1),
    #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1),
    #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1),
    #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
    #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    ]
    
    //Headers
    static let HEADER = [
        "Content-Type" : "application/json; charset = utf-8"
    ]
    
    static let HEADER_SE = [
        "Content-Type" : "application/json; charset = utf-8",
        "Accept" : "application/json; charset = utf-8",
        "App-id" : APP_ID_SALTEDGE,
        "Secret" : APP_SECRET_SALTEDGE
        
    ]
    
    static let HEADER_REGISTER = [
        "Content-Type" : "application/json; charset = utf-8",
        "secret" : APP_LOGIN_SECRET
    ]
    
    
    //Digits and allowed symbols
    static let allowedSDigits = ["0","1","2","3","4","5","6","7","8","9"]
    static let dotSymbol = "."
    static let allowedMathSymbolsForEvaluationInExpression = ["(",")","+","-","*","/"]
    static let InvisibleSign = "\u{200B}"
    
    //Login
    static let USERID = "userid"
    static let EMAIL = "email"
}


