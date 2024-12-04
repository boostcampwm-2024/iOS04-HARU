<div align = center>
  
# 📷 포토게더 - For Together

<br>

![목업 배너](https://github.com/user-attachments/assets/c743749b-a16f-4673-921e-3ac335a80e30)

<img src="https://github.com/user-attachments/assets/0243957d-da45-4fa2-a49e-a83bc4a4cccc" width="500" align="right">

<br><br><br><br>

<i>"함께하면 더 특별해지는 순간"</i>
<br><br>
<i>"지인들과 함께 사진을 찍고 꾸밀 수 있어요"</i>
<br><br>
<i>**실시간 연결**, **사진 촬영**, **꾸미기**까지 – </i>
<br><br>
<i>**PhotoGether**에서 여러분의 특별한 순간들을 저장하고 공유해보세요.</i>

</div>

<br><br><br>


## ✨ 앱 플로우 소개


| 🙋‍♂️🙋 모여봐요 | 📸 함께 찍어요 | 🌠 함께 꾸며요 | 🔗 공유해요 |
| :-----: | :-----: | :-----: | :-----: |
| <img width="250" alt="bye world" src="https://github.com/user-attachments/assets/a139e0c0-d1e2-44d6-a5c6-98174bbe332a"> | <img width="250" alt="Image" src="https://github.com/user-attachments/assets/b9ff509e-2930-4e84-8938-37514d4b469e"> | <img width="250" alt="hello world" src="https://github.com/user-attachments/assets/22e6126c-1008-4233-9419-db1bb8d49307"> |<img width="250" alt="hello world" src="https://github.com/user-attachments/assets/44f08974-1e3a-412b-a1a3-eb42f77e5d75"> |
|- 방을 생성하여 친구를 초대할 수 있습니다.<br>- 친구로부터 링크를 받아 참여할 수 있습니다.<br>- 오디오/비디오 공유를 할 수 있습니다. |- 촬영할 수 있습니다.<br>- 전/후면 카메라 전환을 할 수 있습니다.<br>- 마이크를 On/Off 할 수 있습니다. |- 편집 과정이 실시간으로 공유됩니다.<br>- 스티커를 붙여 사진을 꾸밀 수 있습니다.<br>- 프레임을 바꿀 수 있습니다. | - 편집 결과를 확인할 수 있습니다.<br>- 사진을 공유/저장할 수 있습니다. |


## ✨ 핵심 챌린지 소개

### ✨ WebSocket 서버

• **서버가 필요했던 이유**

우리 앱은 WebRTC를 통해 여러 명과 P2P 연결이 필요한 서비스입니다. 이 과정에서 Signaling 정보를 주고받기 위해 서버가 필요했으며, Swift Vapor를 사용해 Swift 코드로 직접 WebSocket 서버를 구축했습니다.

•	**요청/응답 구조 설계**

하나의 엔드포인트로 모든 요청과 응답을 처리합니다. 요청별로 서버 로직과 응답 데이터가 달라 효율적으로 관리하기 위해 메시지 구조를 다음과 같이 정리했습니다.

>	**MessageType**: 서버가 요청을 처리할 로직을 결정하는 Enum 속성
>
>	**Message**: 요청에 필요한 정보를 담는 데이터

이렇게 구조화하여 서버가 효율적으로 로직을 수행하도록 했습니다.

•	**[트러블 슈팅] 서버 다운 문제**

서버 개발 중 동시 접근으로 인한 Race Condition 문제로 서버가 자주 멈췄습니다. 웹소켓 요청 관리 객체를 Actor로 리팩토링하면서 동시 접근 문제를 해결했습니다.

### ✨ WebRTC

•	**WebRTC 채택 이유**

최대 4명의 유저가 실시간 영상, 음성 공유와 동시 편집을 해야 했기에 낮은 레이턴시가 중요했습니다. 서버를 경유하지 않고 P2P 연결을 지원하는 WebRTC를 사용했습니다.

•	**Mesh 방식 채택 이유**


<img width="40%" alt="Image from Notion" src="https://github.com/user-attachments/assets/888e7156-e2ba-488e-9fe1-56bc7f7aae69">


서버 개발 리소스를 줄이기 위해 Mesh 방식을 선택했습니다. Mesh 방식은 참가자들 간 직접 연결을 지원하며, 최대 4명까지 연결하기에 성능상 문제가 없다고 판단했습니다.

•	**WebRTC 연결 과정**

1.	방 생성자가 웹소켓 서버에서 방을 생성하고, 방 정보를 딥링크 URL로 초대 대상에게 공유합니다.

2.	참여자가 링크를 통해 방에 참가하면, 서버에 방 참가 요청을 보냅니다.

3.	기존 참가자는 새로운 참가자의 정보를 브로드캐스팅으로 받습니다.

4.	Signaling을 통해 데이터 교환 후 P2P 연결이 성립됩니다.

•	**[트러블 슈팅] AVCaptureSession 카메라 접근 문제**

WebRTC P2P 연결 중 음성 연결은 되었으나 화면 연결이 되지 않는 문제를 발견했습니다. 이는 AVCaptureSession이 단일 접근만 허용하기 때문이었습니다. 각 객체가 카메라 데이터를 동시에 요청해 문제가 발생했으며, 데이터를 한 곳에서만 관리하도록 리팩토링하여 해결했습니다.



## ✨ 실시간 데이터 동기화

![이벤트 허브](https://github.com/user-attachments/assets/d57bc44c-d219-42e4-b340-46d07cab4d5a)

<br>

- 실시간 데이터 동기화를 통해 모든 참여자는 동일한 화면 상태를 유지할 수 있습니다.
- 참여자들의 동시 다발적 비동기적인 편집 이벤트를 처리합니다.
- 네트워크 상태에 따른 경쟁 상황을 완화합니다.
- 중앙 집중 상태 관리를 통해 모든 참여자가 동일한 상태를 유지하도록 합니다.

>  [🔗 실시간 데이터 동기화를 위한 이벤트 허브](https://github.com/boostcampwm-2024/iOS04-PhotoGether/wiki/%EC%8B%A4%EC%8B%9C%EA%B0%84-%EB%8D%B0%EC%9D%B4%ED%84%B0-%EB%8F%99%EA%B8%B0%ED%99%94%EB%A5%BC-%EC%9C%84%ED%95%9C-%EC%9D%B4%EB%B2%A4%ED%8A%B8-%ED%97%88%EB%B8%8C)


## ✨ 아키텍쳐 구조

<img width="100%" alt="Image from Notion" src="https://github.com/user-attachments/assets/fd2573f6-71a5-4109-8386-04e8a0ae46c9">

- **3-Layer 기반 클린 아키텍쳐**를 채택하여 관심사를 분리하고 **확장성과** **유지보수성**을 높입니다.

- 인터페이스 의존 설계를 통해 **낮은 결합도**와 유연한 기능 추가 및 수정이 가능하도록 합니다.

- 명확한 역할 분리로 **일관된 코드 구조**를 유지합니다. 이를 통해 코드 흐름 이해를 돕고 개발 속도를 높입니다.



## ✨ 프레젠테이션 레이어 구조

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/13d75a37-2ac1-4e72-a708-d12b7dc6dd7a">

> [!NOTE]
> 현재 저희의 Presentation Layer는 위와 같이 커뮤니케이션 하고 있습니다.
>
> View는 유저 인터랙션이 일어나는 지점으로, 비즈니스 로직은 ViewModel에서 처리되며, 최종적으로 View는 갱신된 상태를 반영합니다.
>
> 특히, 사진 편집과 같은 **이벤트 발생이 빈번한 기능 요구사항**에서, 이벤트와 상태를 명확하게 정의하고 관리하는 것이 중요했습니다. 이를 위해 Input-Output 패턴을 도입하게 되었습니다.
> 
> View에서 발생하는 탭과 같은 이벤트를 **Input**, View에 전달될 데이터 등의 상태를 **Output**으로 정의하여 각 객체의 역할을 명확하게 분리하였습니다.
>
> 또한 개발 과정에서 새로운 이벤트나 상태를 추가할 때 구조적으로 응집되어 있어 쉽게 확장이 가능했습니다.
>
> 추가적으로 팀 내 PR 요청시 코드 리뷰를 필수로 진행하고 있는 상황에서 동일한 패턴을 활용함으로써 빠른 구조 파악을 통해 코드 리뷰 시간이 단축되어 생산성이 향상되었습니다.


## ✨ 모듈 구조

<img width="100%" alt="Group 1000003128" src="https://github.com/user-attachments/assets/6f1d3921-5a41-4034-a3cb-dea1dfbf493f">

> [!NOTE]
> 저희의 모듈 구조는 다음과 같습니다. 모듈을 분리함으로써 접근제어자 설정을 통해 특정 모듈을 수정하거나 기능을 확장할 때 다른 모듈에 미치는 영향을 최소화할 수 있었습니다. 이로 인해 안전하게 개발을 할 수 있었습니다.
>
> 또한 각 Feature별 DemoApp을 통해 병렬적인 화면 개발을 진행해 개발 속도를 높일 수 있었습니다.


## 💻 개발 환경
<div align="center">
<img height="22" src="https://img.shields.io/badge/iOS-16.0+-lightgray"> <img height="22" src="https://img.shields.io/badge/Xcode-16.0-blue"> <img height="22" src="https://img.shields.io/badge/Swift-5.9-orange"> <img height="22" src="https://img.shields.io/badge/Platform-iOS-blue">
</div>


## 👋 팀원 소개

<div align = center>

|[`S009` 김기영](https://github.com/Kiyoung-Kim-57)|[`S034` 송영규](https://github.com/youn9k)|[`S035` 송영훈](https://github.com/0Hooni)|[`S077` 홍승완](https://github.com/hsw1920)|
| :--: | :--: | :--: | :--: |
| <img src="https://avatars.githubusercontent.com/u/121777185?v=4" width=150> | <img src="https://avatars.githubusercontent.com/u/60254939?v=4" width=150> | <img src="https://avatars.githubusercontent.com/u/37678646?v=4" width=150> | <img src="https://avatars.githubusercontent.com/u/66902876?v=4" width=150> |
| **`iOS`** | **`iOS`** | **`iOS`** | **`iOS`** |

</br>

| 🏷️ 바로가기 | [Wiki](https://github.com/boostcampwm-2024/iOS04-HARU/wiki) | [팀 노션](https://www.notion.so/0hooni/HARU-12e07f89fdcd8077a443dbba60cb124d) | [그라운드 룰](https://github.com/boostcampwm-2024/iOS04-HARU/wiki/그라운드-룰) | [컨벤션](https://github.com/boostcampwm-2024/iOS04-HARU/wiki/컨벤션) | [회의록](https://www.notion.so/0hooni/05cb406cd61f460ba7294ae3ffa31f7e) | [기획/디자인](https://www.figma.com/design/6jACkAa5WxD8mm4KgsPtzg/iOS04-GP?node-id=11-32851) |
| :--------: | :---------------------------------------------------------: | :---------------------------------------------------------------------------: | :----------------------------------------------------------------------------: | :------------------------------------------------------------------: | :---------------------------------------------------------------------: | :------------------------------------------------------------------------------------------: |

</div>
