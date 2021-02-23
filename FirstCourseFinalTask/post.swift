//
//  post.swift
//  FirstCourseFinalTask
//
//  Created by Elenasshu on 23.02.2021.
//  Copyright © 2021 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

struct Post: PostProtocol {
    var id: Identifier
    var author: GenericIdentifier<UserProtocol>
    var description: String
    var imageURL: URL
    var createdTime: Date
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
}

class PostStorage: PostsStorageProtocol {
    
    private var posts: [Post]
    private var likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)]
    private let currentUserID: GenericIdentifier<UserProtocol>
    
    required init(posts: [PostInitialData],
                  likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)],
                  currentUserID: GenericIdentifier<UserProtocol>) {
        self.likes = likes
        self.currentUserID = currentUserID
        
        var bufPosts = [Post]()
        for post in posts {
            
            let likedByCount: Int = likes.filter { $0.1 == post.id }.count
            let currentUserLikesThisPost = likes.contains {like in
                return (like.0 == currentUserID && like.1 == post.id )
            }
            
            bufPosts.append(Post(id: post.id,
                                 author: post.author,
                                 description: post.description,
                                 imageURL: post.imageURL,
                                 createdTime: post.createdTime,
                                 currentUserLikesThisPost: currentUserLikesThisPost,
                                 likedByCount: likedByCount))
        }
        
        self.posts = bufPosts
    }
    
    var count: Int {
        get {
            return self.posts.count
        }
    }
    
    func post(with postID: GenericIdentifier<PostProtocol>) -> PostProtocol? {
        return posts.first { $0.id == postID }
    }
    
    func findPosts(by authorID: GenericIdentifier<UserProtocol>) -> [PostProtocol] {
        return posts.filter { $0.author == authorID }
    }
    
    func findPosts(by searchString: String) -> [PostProtocol] {
        return posts.filter { $0.description.contains(searchString) }
    }
    
    func likePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        if likes.contains(where: {$0.0 == currentUserID && $0.1 == postID})  {
            return true
        }
        else {
            guard let postIDIndex = posts.firstIndex(where: {$0.id == postID}) else { return false }
            posts[postIDIndex].currentUserLikesThisPost = true
            likes.append((currentUserID, postID))
        }
        return true
    }
    
    func unlikePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        
        guard let postIDIndex = posts.firstIndex(where: { $0.id == postID }) else {
            return false
        }
        
        guard let likeIndex = likes.firstIndex(where: { $0.0 == currentUserID && $0.1 == postID }) else {
            return true
        }
        
        posts[postIDIndex].currentUserLikesThisPost = false
        likes.remove(at: likeIndex)
        
        return true
    }
    
    func usersLikedPost(with postID: GenericIdentifier<PostProtocol>) -> [GenericIdentifier<UserProtocol>]? {
        
        guard posts.contains(where: {$0.id == postID }) else {
            return nil
        }
        
        return likes.filter{$0.1 == postID}.map{ $0.0 }
    }
}
