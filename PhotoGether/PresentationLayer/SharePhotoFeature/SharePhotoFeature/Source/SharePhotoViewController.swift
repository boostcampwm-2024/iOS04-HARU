import BaseFeature
import Combine
import DesignSystem
import UIKit

public class SharePhotoViewController: BaseViewController {
    private let navigationView = UIView()
    private let photoView = UIImageView()
    private let bottomView = SharePhotoBottomView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setupConstraints()
        configureUI()
        bindOutput()
    }
    
    public override func addViews() {
        [navigationView, photoView, bottomView].forEach {
            view.addSubview($0)
        }
    }
    
    public override func setupConstraints() {
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
    
    // MARK: Image가 원래는 바인딩 되어야 함
    public override func configureUI() {
        view.backgroundColor = PTGColor.gray90.color
        
        photoView.image = PTGImage.frameIcon.image
        photoView.backgroundColor = PTGColor.gray50.color
        photoView.contentMode = .scaleAspectFit
    }
    
    public override func bindOutput() {
        bottomView.shareButtonTapped
            .sink { [weak self] _ in
                self?.showShareSheet()
            }
            .store(in: &cancellables)
        
        bottomView.saveButtonTapped
            .sink { [weak self] _ in
                self?.saveImage()
            }
            .store(in: &cancellables)
    }
    
    private func showShareSheet() {
        if let image = photoView.image {
            let activityViewController = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            present(activityViewController, animated: true)
        }
    }
    
    // TODO: 권한 요청 및 사진앱에 저장
    private func saveImage() {
        
    }
}
