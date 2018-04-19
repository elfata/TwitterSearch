//
//  TTTweetCell.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 17.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import UIKit

class TTTweetCell: UITableViewCell {
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    /**
     Update the cell with TTTweet data
     */
    func updateCellWithTweet(tweet: TTTweet){
        tweetTextLabel.text = tweet.text
        nameLabel.text = tweet.userName
        viewNameLabel.text = tweet.screenName
        timeLabel.text = tweet.tweetDate
    }
}
