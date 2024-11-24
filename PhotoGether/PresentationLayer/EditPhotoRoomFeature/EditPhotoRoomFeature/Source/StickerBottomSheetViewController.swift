import UIKit

import BaseFeature

final class StickerBottomSheetViewController: UIViewController, ViewControllerConfigure {
    private let collectionView = StickerCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView.register(
            StickerCollectionViewCell.self,
            forCellWithReuseIdentifier: StickerCollectionViewCell.identifier
        )
    }
    
    func addViews() {
        [collectionView].forEach { self.view.addSubview($0) }
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureUI() {
        collectionView.backgroundColor = .yellow
        
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
    }
}

// MARK: - CollectionViewDelegate
extension StickerBottomSheetViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        // TODO: Cell 선택시 동작 -> 나중에 스티커 전달해줄 때 사용 예정
    }
}

// MARK: - CollectionViewDataSource
extension StickerBottomSheetViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 12
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StickerCollectionViewCell.identifier,
            for: indexPath
        ) as! StickerCollectionViewCell
        
        return cell
    }
}
