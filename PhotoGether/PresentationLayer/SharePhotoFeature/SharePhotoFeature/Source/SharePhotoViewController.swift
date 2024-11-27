import BaseFeature
import Combine
import DesignSystem
import UIKit

public class SharePhotoViewController: BaseViewController, ViewControllerConfigure {
    // MARK: Properties
    
    private let navigationView = UIView()
    private let photoView = UIImageView()
    private let bottomView = SharePhotoBottomView()
    
    private let input = PassthroughSubject<SharePhotoViewModel.Input, Never>()
    
    // MARK: Dependencies
    
    private let viewModel: SharePhotoViewModel

    // MARK: Initializer
    
    public init(viewModel: SharePhotoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setupConstraints()
        configureUI()
        bindInput()
        bindOutput()
    }
    
    // MARK: Setup View
    
    public func addViews() {
        [navigationView, photoView, bottomView].forEach {
            view.addSubview($0)
        }
    }
    
    public func setupConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        photoView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(80)
        }
    }
    
    public func configureUI() {
        view.backgroundColor = PTGColor.gray90.color
        
        let imageData = viewModel.photoData
        photoView.image = UIImage(data: imageData)
        photoView.backgroundColor = .clear
        photoView.contentMode = .scaleAspectFit
    }
    
    public func bindInput() {
        bottomView.shareButtonTapped
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.input.send(.shareButtonDidTap)
            }
            .store(in: &cancellables)
        
        bottomView.saveButtonTapped
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.input.send(.saveButtonDidTap)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                switch event {
                case .showShareSheet:
                    self?.showShareSheet()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: Functions
    
    private func showShareSheet() {
        if let image = photoView.image {
            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            present(activityViewController, animated: true)
        }
    }
    
    }
}
