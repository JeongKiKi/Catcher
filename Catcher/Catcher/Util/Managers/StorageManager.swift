//
//  StorageManager.swift
//  Catcher
//
//  Created by 김지은 on 2023/10/19.
//

import Foundation
import FirebaseStorage

/// Allows you to get, fetch, and upload files to firebase  storage
final class StorageManager {

    static let shared = StorageManager()

    private init() {}

    private let storage = Storage.storage().reference()

    /*
     /images/afraz9-gmail-com_profile_picture.png
     */

    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                // failed
                CommonUtil.print(output:"failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    CommonUtil.print(output:"Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                CommonUtil.print(output:"download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                CommonUtil.print(output:"failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    CommonUtil.print(output:"Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                CommonUtil.print(output:"download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    /// Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        if let videoData = NSData(contentsOf: fileUrl) as Data? {
            storage.child("message_videos/\(fileName)").putData(videoData, metadata: nil, completion: { [weak self] metadata, error in
                guard error == nil else {
                    // failed
                    CommonUtil.print(output:"failed to upload video file to firebase for picture")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                    guard let url = url else {
                        CommonUtil.print(output:"Failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    CommonUtil.print(output:"download url returned: \(urlString)")
                    completion(.success(urlString))
                })
            })
        }
    }

    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }

    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }
}
