//
//  TTTweet.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 18.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import Foundation

struct TTTweet {
    let text: String
    let userName: String
    let screenName: String
    let dateString: String
    var tweetDate: String{
        //date is in format: 1d1m1s
        get {
            return dateString.getDifferenceFromNowInFormat(format: "EEEE MMM dd HH:mm:ss Z yyyy")
        }
    }
    
    /**
     Init with a dictionary
     */
    init(dictionary: [String: Any]) {
        text = dictionary["text"] as? String ?? ""
        dateString = dictionary["created_at"] as? String ?? ""
        
        guard let user = dictionary["user"] as? [String: Any] else {
            userName = ""
            screenName = ""
            return
        }
        
        userName = user["name"] as? String ?? ""
        
        guard let scrName = user["screen_name"] as? String else {
            screenName = ""
            return
        }
        screenName = "@" + scrName
    }
}
