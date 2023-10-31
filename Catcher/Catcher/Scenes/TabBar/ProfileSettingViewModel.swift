//
//  ProfileSettingViewModel.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit

final class ProfileSettingViewModel {
    private let detectObject = DetectObject()
    private let distinguishGender = DistinguishGender()
    private let genProfile = GenerateProfile()
    
    var profileImage: UIImage?
    var gender: String?
}

extension ProfileSettingViewModel {
    func createUser(user: UserInfo, eamil: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let profileImage = profileImage,
              let gender = gender else {
            completion(false)
            return
        }
        FirebaseManager().createUsers(
            email: eamil,
            password: password) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    CommonUtil.print(output:"Error creating user: \(error)")
                    completion(false)
                    return
                } else {
                    let firebaseManager = FirebaseManager()
                    guard let uid = firebaseManager.getUID else {
                        CommonUtil.print(output:"Error: No UID available")
                        completion(false)
                        return
                    }
                    let userInfo = makeUserInfo(user: user, uid: uid, gender: gender)
                    setUserInfo(userInfo: userInfo, image: profileImage, completion: completion)
                }
            }
    }
}

extension ProfileSettingViewModel {
    func imageTasking(image: UIImage) -> (image: UIImage?, gender: String?) {
        let objects = detectObject.detect(image: image)
        let genders = distinguishGender.analyzeImage(image: image)
        
        guard let objects = objects,
              let male = genders?["male"],
              let female = genders?["female"] else { return (nil, nil) }
        
        if objects.contains("person") {
            let gender = compareGender(male: male, female: female)
            let generatedImage = genProfile.generateImage(image: image)
            return (generatedImage, gender)
        }
        return (nil, nil)
    }
}

private extension ProfileSettingViewModel {
    func compareGender(male: Double, female: Double) -> String {
        if male >= female {
            return "남성"
        }
        return "여성"
    }
    
    func setUserInfo(userInfo: UserInfo, image: UIImage, completion: @escaping (Bool) -> Void) {
        Task {
            let error = await FireStoreManager.shared.setUserInfo(data: userInfo)
            if let error = error {
                CommonUtil.print(output:"Error saving user info: \(error.localizedDescription)")
                return
            }
            setProfileImage(image: image, completion: completion)
            CommonUtil.print(output:"User info saved to Firestore successfully.")
        }
    }
    
    func setProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        FireStorageManager.shared.setProfileData(image: image) { [weak self] error in
            guard self != nil else { return }
            if let error {
                CommonUtil.print(output: error)
                completion(false)
                return
            }
            CommonUtil.print(output: "Profile Image saved to Storage successfully.")
            completion(true)
        }
    }
    
    func makeUserInfo(user: UserInfo, uid: String, gender: String) -> UserInfo {
        UserInfo(
            uid: uid,
            sex: gender,
            birth: user.birth,
            nickName: user.nickName,
            location: user.location,
            height: Int(user.height),
            body: user.body,
            education: user.education,
            drinking: user.drinking,
            smoking: user.smoking,
            register: Date(),
            score: 0,
            pick: []
        )
    }
}
