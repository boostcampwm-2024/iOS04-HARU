import UIKit
import DesignSystem

public typealias Section = Int
public typealias SectionItem = ParticipantsSectionItem

public final class ParticipantsCollectionViewDataSource: UICollectionViewDiffableDataSource<Section, SectionItem> {
    public static func create(
        collectionView: UICollectionView
    ) -> UICollectionViewDiffableDataSource<Section, SectionItem> {
        let dataSource = UICollectionViewDiffableDataSource<Section, SectionItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, sectionItem in
            return configureCell(collectionView: collectionView, indexPath: indexPath, sectionItem: sectionItem)
        }
        return dataSource
    }
    
    private static func configureCell(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        sectionItem: SectionItem
    ) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ParticipantsCollectionViewCell.identifier,
            for: indexPath
        ) as? ParticipantsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let placeHolderView = PlaceHolderView()
        placeHolderView.setText("Photo Gether")
                
        cell.setNickname(sectionItem.nickname)
        cell.setView(sectionItem.videoView ?? placeHolderView)
        
        return cell
    }
}
