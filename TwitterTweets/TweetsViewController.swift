//
//  TweetsViewController.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 16.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private static let kTweetCell = "TweetCell"
    
    @IBOutlet weak var tweetsSearchBar: UISearchBar!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    private let communicationManager = TTCommunicationManager()
    private var tweets:[TTTweet] = []
    
    //MARK: - main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communicationManager.startTwitterCommunication()
        
        //set delegates
        tweetsSearchBar.delegate = self
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self

        tweetsTableView.tableFooterView = UIView(frame: CGRect.zero)
        tweetsTableView.allowsSelection = false
        
        //register a cell which will show received tweets
        tweetsTableView.register(UINib.init(nibName: "TTTweetCell", bundle: nil), forCellReuseIdentifier: TweetsViewController.kTweetCell)
    }

    //MARK: - SearchBar delegation
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchedText = searchBar.text else { return }
        
        searchKeyWord(keyWord: searchedText)
        //hide the keyboard after pressing the Search button
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //tableview/missing results are hidden when the user is typing
        tweetsTableView.isHidden = true
        noResultsLabel.isHidden = true
    }

    //MARK: - Table View Delegation
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: TTTweetCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: TweetsViewController.kTweetCell, for: indexPath) as? TTTweetCell {
            cell = dequeuedCell
        } else {
            cell = TTTweetCell(style: UITableViewCellStyle.default, reuseIdentifier: TweetsViewController.kTweetCell)
        }
        
        //update current cell with Tweet object
        let currentTweet = tweets[indexPath.row]
        cell.updateCellWithTweet(tweet: currentTweet)
        
        return cell
    }
    
    //MARK: - helper methods
    /**
     Send a query to Twitter's API with a given keyword.
     - Parameter keyWord: String value which can be null.
     */
    func searchKeyWord(keyWord: String?){
        guard let searchWord = keyWord, searchWord != "" else {
            updateTweets(newTweets: [])
            return
        }
        
        //show activity indicator during the query
        activityIndicator.startAnimating()
        
        //send a search query. Update tableView when receiving a response, stop the activity indicator.
        communicationManager.getTweetsWith(keyword: searchWord) { [weak self] (error, currentTweets) in
            guard let weakSelf = self else { return }

            var newTweets: [TTTweet] = []
            if error == nil, let tweets = currentTweets {
                newTweets = tweets
            }

            //update UI on main queue
            DispatchQueue.main.async {
                weakSelf.updateTweets(newTweets: newTweets)
                weakSelf.activityIndicator.stopAnimating()
                weakSelf.noResultsLabel.isHidden = !newTweets.isEmpty
            }
        }
    }
    
    /**
     Updates the tableView with given tweets
     - Parameter newTweets: array of TTTweet objects. If it is empty the tableView is hidden.
     */
    private func updateTweets(newTweets: [TTTweet]) {
        tweetsTableView.isHidden = newTweets.isEmpty
        tweets = newTweets
        tweetsTableView.reloadData()
        //scroll back to top for the new search
        if tweets.isEmpty == false {
            tweetsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
    }
}
