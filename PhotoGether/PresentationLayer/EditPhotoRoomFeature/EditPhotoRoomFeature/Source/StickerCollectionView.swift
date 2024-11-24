import UIKit

final class StickerCollectionView: UICollectionView {
    convenience init() {
        self.init()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 64, height: 64)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(
            top: 16, left: 16,
            bottom: 16, right: 16
        )
        
        self.collectionViewLayout = layout
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
