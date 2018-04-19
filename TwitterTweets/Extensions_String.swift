//
//  Extensions_String.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 18.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import Foundation

extension String {

    /**
     Encode to base64 the string
     */
    func toBase64()->String{
        let data = self.data(using: String.Encoding.utf8)
        
        guard let stringData = data else { return "" }
        
        return stringData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    /**
     Get the difference in time until now. 
     */
    func getDifferenceFromNowInFormat(format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard let date = dateFormatter.date(from: self) else { return "" }
        
        let dateString = Date().offsetFrom(date: date)
        return dateString
    }
}
