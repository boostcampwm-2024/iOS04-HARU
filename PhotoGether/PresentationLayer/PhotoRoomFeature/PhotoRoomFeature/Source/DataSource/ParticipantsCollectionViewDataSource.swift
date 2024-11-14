import UIKit

public typealias Section = Int
public typealias SectionItem = ParticipantsSectionItem

public final class ParticipantsCollectionViewDataSource: UICollectionViewDiffableDataSource<Section, SectionItem> {
    public static func create(
        collectionView: UICollectionView
    ) -> UICollectionViewDiffableDataSource<Section, SectionItem> {
        let dataSource = UICollectionViewDiffableDataSource<Section, SectionItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, _ in
            return configureCell(collectionView: collectionView, indexPath: indexPath)
        }
        return dataSource
    }
    
    private static func configureCell(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ParticipantsCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? ParticipantsCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}
