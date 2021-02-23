//
//  user.swift
//  FirstCourseFinalTask
//
//  Created by Elenasshu on 23.02.2021.
//  Copyright © 2021 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

struct User: UserProtocol {
    var id: Identifier
    var username: String
    var fullName: String
    var avatarURL: URL?
    var currentUserFollowsThisUser: Bool
    var currentUserIsFollowedByThisUser: Bool
    var followsCount: Int
    var followedByCount: Int
}

class UserStorage: UsersStorageProtocol {
    private var users: [User]
    private var followers: [(UserProtocol.Identifier, UserProtocol.Identifier)]
    private let currentUserID: UserProtocol.Identifier
    
    required init?(users: [UserInitialData], followers: [(GenericIdentifier<UserProtocol>, GenericIdentifier<UserProtocol>)], currentUserID: GenericIdentifier<UserProtocol>) {
        
        guard (users.first (where: { $0.id == currentUserID }) != nil) else {
            return nil
        }
        
        self.followers = followers
        self.currentUserID = currentUserID
        
        var bufUsers = [User]()
        for user in users {
            
            let currentUserFollowsThisUser = followers.contains(where: {$0.0 == currentUserID && $0.1 == user.id})
            
            let currentUserIsFollowedByThisUser = followers.contains(where: {$0.0 == user.id && $0.1 == currentUserID})
            
            let followsCount = followers.filter({$0.0 == user.id}).count
            
            let followedByCount = followers.filter({$0.1 == user.id}).count
            
            bufUsers.append(User(id: user.id, username: user.username, fullName: user.fullName, avatarURL: user.avatarURL, currentUserFollowsThisUser: currentUserFollowsThisUser, currentUserIsFollowedByThisUser: currentUserIsFollowedByThisUser, followsCount: followsCount, followedByCount: followedByCount))
        }
        self.users = bufUsers
    }
    
    var count: Int {
        get {
            return users.count
        }
    }
    
    func currentUser() -> UserProtocol {
        return users.first{$0.id == currentUserID}!
    }
    
    func user(with userID: GenericIdentifier<UserProtocol>) -> UserProtocol? {
        return users.first{ $0.id == userID} ?? nil
    }
    
    func findUsers(by searchString: String) -> [UserProtocol] {
        return users.filter { user -> Bool in
            user.username.contains(searchString) || user.fullName.contains(searchString)
        }
    }
    
    func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
        
        guard let userToFollowIndex = users.firstIndex(where: {$0.id == userIDToFollow}) else {
            return false
        }
        
        guard !followers.contains(where: {$0.0 == currentUserID && $0.1 == userIDToFollow}) else {
            return true
        }
        
        let userCurrentUserIndex: Int = users.firstIndex(where: {$0.id == currentUserID})!
        
        followers.append((currentUserID, userIDToFollow))
        users[userToFollowIndex].followedByCount += 1
        users[userCurrentUserIndex].followsCount += 1
        return true
    }
    
    func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
        
        guard let userToUnfollowIndex = users.firstIndex(where: {$0.id == userIDToUnfollow}) else {
            return false
        }
        
        guard let followersIndex = followers.firstIndex(where: {$0.0 == currentUserID && $0.1 == userIDToUnfollow}) else {
            return true
        }
        
        let userCurrentUserIndex: Int = users.firstIndex(where: {$0.id == currentUserID})!
        
        followers.remove(at: followersIndex)
        users[userToUnfollowIndex].followedByCount -= 1
        users[userCurrentUserIndex].followsCount -= 1
        
        return true
    }
    
    func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        
        guard users.contains (where: {$0.id == userID}) else {
            return nil
        }
        return users.filter { user -> Bool in
            followers.contains { $0.0 == user.id && $0.1 == userID }
        }
    }
    
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        
        guard users.contains (where: {$0.id == userID}) else {
            return nil
        }
        
        return users.filter { user -> Bool in
            followers.contains { $0.1 == user.id && $0.0 == userID }
        }
        
    }
    
}
