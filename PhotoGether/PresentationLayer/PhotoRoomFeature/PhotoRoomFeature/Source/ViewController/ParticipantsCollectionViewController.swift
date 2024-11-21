import UIKit

fileprivate typealias DataSource = ParticipantsCollectionViewDataSource

public final class ParticipantsCollectionViewController: UICollectionViewController {
    public lazy var dataSource = DataSource.create(
        collectionView: self.collectionView
    )
    
    public init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.collectionView!.register(
            ParticipantsCollectionViewCell.self,
            forCellWithReuseIdentifier: ParticipantsCollectionViewCell.identifier
        )
    }
}

extension ParticipantsCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizotalSpacing = Constants.sectionLeadingSpacing + Constants.sectionTrailingSpacing
        let itemWidth = (view.frame.width - horizotalSpacing - Constants.itemSpacing) / 2
        let itemHeight = itemWidth * Constants.sizeMultiplier
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.itemSpacing
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.itemSpacing
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: Constants.sectionLeadingSpacing, bottom: 0, right: Constants.sectionTrailingSpacing)
    }
}

extension ParticipantsCollectionViewController {
    enum Constants {
        static let sizeMultiplier: CGFloat = 290 / 179 // 피그마 디자인에 따른 세로/가로 비율입니다.
        static let sectionLeadingSpacing: CGFloat = 12
        static let sectionTrailingSpacing: CGFloat = 12
        static let itemSpacing: CGFloat = 11
    }
}
