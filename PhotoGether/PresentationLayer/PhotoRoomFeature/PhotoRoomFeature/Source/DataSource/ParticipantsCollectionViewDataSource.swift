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
        cell.setNickname(sectionItem.nickname)
        let tempImageView = configureTempImageView(indexPath.row)
        cell.setVideoView(tempImageView)
        
        return cell
    }
    
    private static func configureTempImageView(_ row: Int) -> UIImageView {
        var tempImage: UIImage?
        switch row {
        case 0: tempImage = PTGImage.temp1.image
        case 1: tempImage = PTGImage.temp2.image
        case 2: tempImage = PTGImage.temp3.image
        case 3: tempImage = PTGImage.temp4.image
        default: tempImage = PTGImage.temp1.image
        }
        let tempImageView = UIImageView(image: tempImage)
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.clipsToBounds = true
        
        return tempImageView
    }
}
