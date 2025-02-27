//
//  ImageFactoryView.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import SnapKit
import UIKit

final class ImageFactoryView: UIView {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "default")
        return view
    }()
    
    lazy var saveButton: UIButton = {
        ButtonFactory.makeButton(
            title: "이미지 저장",
            titleColor: .white,
            backgroundColor: ThemeColor.userInfoHeaderView,
            cornerRadius: AppConstraint.defaultCornerRadius)
    }()
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.color = .systemOrange
        view.stopAnimating()
        view.isHidden = true
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = ThemeColor.backGroundColor
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ImageFactoryView {
    func setLayout() {
        indicatorView.addSubview(indicator)
        
        [imageView, saveButton, indicatorView].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(imageView.snp.width)
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(200)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(70)
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
