//
//  StorageManager.swift
//  ChatApp
//
//  Created by Varun Bagga on 08/09/22.
//

import Foundation
import FirebaseStorage
final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPicturesCompletion = (Result<String,Error>)-> Void
    
    ///uploads pictures to fireBase Storage and returns completion with url string to download
    
    public func uploadProfilePicture(with data:Data,fileName: String,completion:@escaping UploadPicturesCompletion){
        
        storage.child("images/\(fileName)").putData(data) { metaData, error in
            guard error == nil else{
                //
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            // Getting download Url
                self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else{
                    
                    print("failedToGetDownloadURl")
                    completion(.failure(StorageErrors.failedToGetDownloadURl))
                    return
                }
                    let urlString = url.absoluteString
                    print("download url returned:\(urlString)")
                    completion(.success(urlString))
            }
        }
        
    }
    public enum StorageErrors:Error{
        case failedToUpload
        case failedToGetDownloadURl
    }
}
