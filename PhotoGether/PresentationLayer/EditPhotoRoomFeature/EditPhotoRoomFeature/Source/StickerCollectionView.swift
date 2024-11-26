import UIKit

import DesignSystem

final class StickerCollectionView: UICollectionView {
    override init(
        frame: CGRect = .zero,
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.congigureUI()
    }
    
    private func congigureUI() {
        guard let layout = self.collectionViewLayout
                as? UICollectionViewFlowLayout
        else { return }
        
        layout.itemSize = CGSize(width: 64, height: 64)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        self.backgroundColor = PTGColor.gray10.color
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}
