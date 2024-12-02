import WebRTC

enum PeerConnectionSupport {
    static let peerConnectionFactory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
    }()
    
    static func configuration(iceServers: [String]) -> RTCConfiguration {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        return config
    }
    
    static func mediaConstraint() -> RTCMediaConstraints {
        return RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: [
                "DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue
            ]
        )
    }
    
    static func createAudioTrack() -> RTCAudioTrack {
        let audioConstraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
        let audioSource = peerConnectionFactory.audioSource(
            with: audioConstraints
        )
        let audioTrack = peerConnectionFactory.audioTrack(
            with: audioSource,
            trackId: "audio0"
        )
        return audioTrack
    }

    static func createVideoTrack(videoSource: RTCVideoSource) -> RTCVideoTrack {
        let videoTrack = peerConnectionFactory.videoTrack(
            with: videoSource,
            trackId: "video0"
        )
        return videoTrack
    }
}
