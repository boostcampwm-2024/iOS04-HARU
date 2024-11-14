import BaseFeature
import DesignSystem
import EditPhotoRoomFeature
import PhotoGetherDomainInterface
import SnapKit
import UIKit

public class WaitingRoomViewController: BaseViewController, ViewControllerConfigure {
    let connectionClient: ConnectionClient
    let offerButton = UIButton()
    let captureButton = UIButton()
    let localVideoView: UIView
    var remoteVideoView: UIView
    
    public init(connectionClient: ConnectionClient) {
        self.connectionClient = connectionClient
        self.localVideoView = connectionClient.localVideoView
        self.remoteVideoView = connectionClient.remoteVideoView
        
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
        setActions()
    }
    
    public func addViews() {
        [offerButton, localVideoView, remoteVideoView, captureButton].forEach { subView in
            view.addSubview(subView)
        }
    }
    
    public func setupConstraints() {
        offerButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.centerX.equalToSuperview().offset(100)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        captureButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.centerX.equalToSuperview().offset(-100)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        localVideoView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(191)
            $0.height.equalTo(290)
            $0.trailing.equalTo(view.snp.centerX).offset(-5.5)
        }
        
        remoteVideoView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(191)
            $0.height.equalTo(290)
            $0.leading.equalTo(view.snp.centerX).offset(5.5)
        }
    }
    
    public func configureUI() {
        view.backgroundColor = .white
        
        offerButton.setTitle("Offer", for: .normal)
        offerButton.setTitleColor(.white, for: .normal)
        offerButton.layer.cornerRadius = 10
        offerButton.backgroundColor = .black
        
        captureButton.setTitle("Capture", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 10
        captureButton.backgroundColor = .black
        
        localVideoView.backgroundColor = PTGColor.gray50.color
        
        remoteVideoView.backgroundColor = PTGColor.gray50.color
    }
    
    private func setActions() {
        offerButton.addAction(UIAction { [weak self] _ in
            self?.connectionClient.sendOffer()
        }, for: .touchUpInside)
        
        captureButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            
            let images = self.connectionClient.captureVideo()
            print("imagesCount: \(images.count)")
            let frameImageGenerator = FrameImageGeneratorImpl(images: images)
            let viewModel = EditPhotoRoomHostViewModel(frameImageGenerator: frameImageGenerator)
            let viewController = EditPhotoRoomHostViewController(viewModel: viewModel)
            self.connectionClient.sendData(data: images.first!.pngData()!)
            navigationController?.pushViewController(viewController, animated: true)
        }, for: .touchUpInside)
    }
}
