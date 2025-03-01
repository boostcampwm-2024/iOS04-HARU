import Combine
import UIKit

import BaseFeature
import DesignSystem
import PhotoGetherDomainInterface

protocol StickerBottomSheetViewControllerDelegate: AnyObject {
    func stickerBottomSheetViewController(_ viewController: StickerBottomSheetViewController, didTap emoji: EmojiEntity)
}

public final class StickerBottomSheetViewController: UIViewController, ViewControllerConfigure {
    private let collectionView: StickerCollectionView
    private let viewModel: StickerBottomSheetViewModel
    
    weak var delegate: StickerBottomSheetViewControllerDelegate?
    
    private let input = PassthroughSubject<StickerBottomSheetViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: StickerBottomSheetViewModel) {
        let layout = UICollectionViewFlowLayout()
        self.collectionView = StickerCollectionView(collectionViewLayout: layout)
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
        self.addViews()
        self.setupConstraints()
        self.configureUI()
        self.bindOutput()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.sheetPresentationController?.detents = [.medium(), .large()]
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(
            StickerCollectionViewCell.self,
            forCellWithReuseIdentifier: StickerCollectionViewCell.identifier
        )
    }
    
    public func addViews() {
        [self.collectionView].forEach { self.view.addSubview($0) }
    }
    
    public func setupConstraints() {
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(24)
        }
    }
    
    public func configureUI() {
        self.view.backgroundColor = PTGColor.gray10.color
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .sink { [weak self] event in
                switch event {
                case .emoji(let entity):
                    self?.sendEmoji(by: entity)
                }
            }
            .store(in: &cancellables)
        
        self.viewModel.emojiList
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func sendEmoji(by entity: EmojiEntity) {
        self.delegate?.stickerBottomSheetViewController(self, didTap: entity)
        self.dismiss(animated: true)
    }
}

// MARK: - CollectionViewDelegate
extension StickerBottomSheetViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
         input.send(.emojiTapped(index: indexPath))
    }
}

// MARK: - CollectionViewDataSource
extension StickerBottomSheetViewController: UICollectionViewDataSource {
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.emojiList.value.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionViewCell.identifier,
                                                            for: indexPath) as? StickerCollectionViewCell,
              let emojiEntity = viewModel.emojiList.value[safe: indexPath.item]
        else { return UICollectionViewCell() }
        
        cell.setImage(by: emojiEntity)

        return cell
    }
}
