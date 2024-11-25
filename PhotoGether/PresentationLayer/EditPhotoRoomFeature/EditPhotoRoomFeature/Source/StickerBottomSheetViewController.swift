import Combine
import UIKit

import BaseFeature
import DesignSystem
import PhotoGetherDomainInterface

protocol StickerBottomSheetViewControllerDelegate {
    func stickerBottomSheetViewController(_ viewController: StickerBottomSheetViewController, didTap emoji: EmojiEntity)
}

final class StickerBottomSheetViewController: UIViewController, ViewControllerConfigure {
    private let collectionView: StickerCollectionView
    private let viewModel: StickerBottomSheetViewModel
    
    var delegate: StickerBottomSheetViewControllerDelegate?
    
    private let input = PassthroughSubject<StickerBottomSheetViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: StickerBottomSheetViewModel) {
        let layout = UICollectionViewFlowLayout()
        self.collectionView = StickerCollectionView(collectionViewLayout: layout)
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
        self.addViews()
        self.setupConstraints()
        self.configureUI()
        self.bindOutput()
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(
            StickerCollectionViewCell.self,
            forCellWithReuseIdentifier: StickerCollectionViewCell.identifier
        )
    }
    
    func addViews() {
        [self.collectionView].forEach { self.view.addSubview($0) }
    }
    
    func setupConstraints() {
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(24)
        }
    }
    
    func configureUI() {
        self.sheetPresentationController?.detents = [.medium(), .large()]
        self.view.backgroundColor = PTGColor.gray10.color
    }
    
    func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .sink { [weak self] event in
                switch event {
                case .emoji(let entity):
                    // TODO: 이모지 전달
                    self?.sendEmoji(by: entity)
                }
            }
            .store(in: &cancellables)
        
        // FIXME: Published 말고 다른 방법 없으려나...
        self.viewModel.$emojiList
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
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
         input.send(.emojiTapped(index: indexPath))
    }
}

// MARK: - CollectionViewDataSource
extension StickerBottomSheetViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if viewModel.emojiList.isEmpty { return 0 }
        else { return viewModel.emojiList.count }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StickerCollectionViewCell.identifier,
            for: indexPath
        ) as? StickerCollectionViewCell
        else { return UICollectionViewCell() }
        
        if viewModel.emojiList.isEmpty { return cell }
        
        cell.setupImage(by: viewModel.emojiList[indexPath.item])
        return cell
    }
}
