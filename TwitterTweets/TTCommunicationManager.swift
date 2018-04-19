//
//  TTCommunicationManager.swift
//  TwitterTweets
//
//  Created by Petya Kozhuharova on 16.04.18.
//  Copyright © 2018 Petya Kozhuharova. All rights reserved.
//

import Foundation

class TTCommunicationManager {
    private static let twitterKey = "eQyzIZueReOK7nJhOa64uEHrF"
    private static let privateKey = "tqJYg357yMGaXzjZ9Y8UI64s7wmOhgnvkqoaXKjR9MEvjrtJU4"
    private static let twitterUrl = "https://api.twitter.com/1.1/search/tweets.json"
    private static let oauthUrLString = "https://api.twitter.com/oauth2/token"
    private var accessToken = ""

    //MARK: - Base methods
    /**
     Get new token for further requests
     */
    func startTwitterCommunication() {
        requestBearerToken()
    }
    
    /**
     Send s query with searched word. If accessToken is expired it returns Error in completion block.
     - Parameter keyword: Searched String.
     - Parameter completion: Block which will be executed when the response is received or any error occurs
     */
    func getTweetsWith(keyword: String, completion: ((CommunicationErrors?, [TTTweet]?) -> Void)?){
        if accessToken == "" {
            //missing accessToken - request for a new one
            requestBearerToken()
            completion?(.authError, nil)
        } else {
            getTweets(keyword: keyword, completion: completion)
        }
    }
    
    /**
     Send a query to get a bearer token
     */
    private func requestBearerToken() {
        //encode the key + secret
        let bearerToken = TTCommunicationManager.twitterKey + ":" + TTCommunicationManager.privateKey
        let bearerTokenBase64 = bearerToken.toBase64()
        
        //prepare for POST request
        guard let url = URL(string: TTCommunicationManager.oauthUrLString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic " + bearerTokenBase64, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        
        //send the request
        getAccessTokenQuery(request: request)
    }

    /**
     Send a query with the searched word.
     - Parameter keyword: Searched String.
     - Parameter completion: Block which will be executed when the response is received or any error occurs
     */
    func getTweets(keyword: String, completion: ((CommunicationErrors?, [TTTweet]?) -> Void)?){
        
        guard let url = URL(string: TTCommunicationManager.twitterUrl + "?q=" + keyword) else {
            completion?(.connectionError, nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let weakSelf = self else { return }
            
            guard let data = data, error == nil, let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 else {
                print("error: \(String(describing: error))")
                completion?(.connectionError, nil)
                //reset the accessToken
                weakSelf.accessToken = ""
                return
            }
            
            do {
                //try to parse the response
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    guard let statuses = jsonDictionary["statuses"] as? [NSDictionary] else {
                        completion?(.parsingError, nil)
                        return
                    }
                    
                    var tweets: [TTTweet] = []
                    for status in statuses {
                        //if status is not [String: Any], check the next element
                        guard let statusData = status as? [String: Any] else { continue  }
                        
                        //append new TTTweet in the array
                        let tweet = TTTweet.init(dictionary: statusData)
                        tweets.append(tweet)
                    }
                    completion?(nil, tweets)
                } else {
                     completion?(.parsingError, nil)

                }
            } catch let error{
                print(error.localizedDescription)
                completion?(.connectionError, nil)
            }
        })
        task.resume()
    }
    
    /**
     Send a query to get a bearer token
     */
     private func getAccessTokenQuery(request: URLRequest){
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            guard let weakSelf = self else { return }
            
            guard let data = data, error == nil, let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 else {
                print("error: \(String(describing: error))")
                //reset the accessToken
                weakSelf.accessToken = ""
                return
            }

            do{
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    guard let tokenType = jsonDictionary["token_type"] as? String, tokenType == "bearer", let token = jsonDictionary["access_token"] as? String else {
                        //reset the accessToken
                        weakSelf.accessToken = ""
                        return
                    }
                    weakSelf.accessToken = token
                }else {
                    //reset the accessToken
                    weakSelf.accessToken = ""
                }
            }catch let error{
                //reset the accessToken
                weakSelf.accessToken = ""
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}
