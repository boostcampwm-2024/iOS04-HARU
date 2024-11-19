import SwiftUI

public struct NickNameLabelView: View {
    @State public var nickName: String
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.black)
            .opacity(0.4)
            .overlay {
                Text(nickName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
                    .opacity(0.84)
                    .lineLimit(1)
                    .kerning(-0.32)
                    .padding()
            }
    }
}

public extension View {
    var uiView: UIView {
        let hostingVC = UIHostingController(rootView: self)
        return hostingVC.view
    }
}

#Preview {
    ZStack {
        Color.gray
        NickNameLabelView(nickName: "testNickname1234")
            .frame(width: 100, height: 40)
    }
    
}
