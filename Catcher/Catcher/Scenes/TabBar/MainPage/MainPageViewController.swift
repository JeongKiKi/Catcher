//
//  MainPageViewController.swift
//  Catcher
//
//  Copyright (c) 2023 z-wook. All right reserved.
//

import UIKit
import Combine
import SnapKit
import SwiftUI

final class MainPageViewController: UIViewController {
    private let mainPageView = MainPageView()
    private let viewModel = MainPageViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private var cancellables = Set<AnyCancellable>()
    
    override func loadView() {
        super.loadView()
        
        view = mainPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setDataSource()
        setHeader()
        bind()
        viewModel.fetchMainPageData()
    }
}

private extension MainPageViewController {
    func configure() {
        mainPageView.collectionView.delegate = self
    }
    
    func bind() {
        viewModel.mainSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else { return }
                applyItems(data: data)
            }.store(in: &cancellables)
    }
}

private extension MainPageViewController {
    func setDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: mainPageView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                switch itemIdentifier {
                    
                    
                case .random(let item), .near(let item), .pick(let item), .new(let item):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: DefaultSectionCell.identifier,
                        for: indexPath) as? DefaultSectionCell else { return UICollectionViewCell() }
                    cell.configure(data: item)
                    return cell
                    
                case .rank(let item):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: RankSectionCell.identifier,
                        for: indexPath) as? RankSectionCell else { return UICollectionViewCell() }
                    cell.configure(data: item, index: indexPath.item)
                    return cell
                }
            })
    }
    
    func setHeader() {
        guard let dataSource = dataSource else { return }
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SectionHeaderView.identifier,
                for: indexPath) as? SectionHeaderView else {
                return SectionHeaderView()
            }
            let title = self?.viewModel.getSectionTitle(section: indexPath.section)
            header.configure(sectionTitle: title)
            return header
        }
    }
    
    func applyItems(data: MainItems) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        let randomSection = Section(id: SectionName.random.sectionID)
        let rankSection = Section(id: SectionName.rank.sectionID)
        let newSection = Section(id: SectionName.new.sectionID)
        let nearSection = Section(id: SectionName.near.sectionID)
        let pickSection = Section(id: SectionName.pick.sectionID)
        
        [randomSection, rankSection, newSection].forEach {
            snapshot.appendSections([$0])
        }
        
        snapshot.appendItems(data.random, toSection: randomSection)
        snapshot.appendItems(data.rank, toSection: rankSection)
        snapshot.appendItems(data.new, toSection: newSection)
        
        if data.near.isEmpty == false {
            snapshot.appendSections([nearSection])
            snapshot.appendItems(data.near, toSection: nearSection)
        }
        if data.pick.isEmpty == false {
            snapshot.appendSections([pickSection])
            snapshot.appendItems(data.pick, toSection: pickSection)
        }
        dataSource?.apply(snapshot)
    }
}

extension MainPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items: [Item]
        let index = indexPath.item
        
        switch indexPath.section {
        case 0:
            items = viewModel.mainSubject.value.random
        case 1:
            items = viewModel.mainSubject.value.rank
        case 2:
            items = viewModel.mainSubject.value.new
        case 3:
            items = viewModel.mainSubject.value.near
        case 4:
            items = viewModel.mainSubject.value.pick
        default:
            return
        }
        
        if items.isEmpty == false {
            let item = items[index]
            let userInfo = viewModel.userInfoFromItem(item: item)
            let userInfoVC = UserInfoViewController(info: userInfo)
            userInfoVC.modalTransitionStyle = .crossDissolve
            userInfoVC.modalPresentationStyle = .custom
            present(userInfoVC, animated: true)
        }
    }
}

struct MainPageViewControllerPreView: PreviewProvider {
    static var previews: some View {
        MainPageViewController().toPreview().edgesIgnoringSafeArea(.all)
    }
}
