import UIKit

public final class ParticipantsCollectionViewController: UICollectionViewController {
    public init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(
            ParticipantsCollectionViewCell.self,
            forCellWithReuseIdentifier: ParticipantsCollectionViewCell.reuseIdentifier
        )
    }

    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    public override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 4
    }

    public override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ParticipantsCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        // TODO: Cell Configuration needed
        return cell
    }
}

extension ParticipantsCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemWidth = (view.frame.width - Constants.horizontalSpacing - Constants.itemSpacing) / 2
        let itemHeight = itemWidth * Constants.sizeMultiplier
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.lineSpacing
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.itemSpacing
    }
}

extension ParticipantsCollectionViewController {
    enum Constants {
        static let sizeMultiplier: CGFloat = 290 / 179
        static let horizontalSpacing: CGFloat = 12
        static let itemSpacing: CGFloat = 11
        static let lineSpacing: CGFloat = 11
    }
}
