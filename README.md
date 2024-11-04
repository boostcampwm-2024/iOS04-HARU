# 📷 포토게더 - For Together
> 멀리 떨어진 친구들과 실시간으로 함께 찍고 편집하는 사진 촬영 앱


#### 팀원 소개

<details>
<summary>  </summary>

|[S009_김기영](https://github.com/Kiyoung-Kim-57)|[S034_송영규](https://github.com/youn9k)|[S035_송영훈](https://github.com/0Hooni)|[S077_홍승완](https://github.com/hsw1920)|
|:---:|:---:|:---:|:---:|
|<img src="https://github.com/user-attachments/assets/6a865499-ef54-4c48-84ae-8d8eb9a229b6" width=150>|<img src="https://github.com/user-attachments/assets/eaadb82c-4880-4e66-bfe7-4eac844ca594" width=150>|<img src="https://github.com/user-attachments/assets/6cdb37fa-d0d1-46ed-bd6d-faa54db5e6b8" width=150>|<img src="https://github.com/user-attachments/assets/697edcf8-7709-42c2-82de-85f8f2bed08c" width=150>|
| 팩트는 코드가 건<br>강해지고 있다는 거임. | 이 또한 잡스의 은혜겠지요. | 디버깅 다 해줬잖아. | 정상화... 해야겠지? |
| iOS | iOS | iOS | iOS |
</details>

|[S009_김기영](https://github.com/Kiyoung-Kim-57)|[S034_송영규](https://github.com/youn9k)|[S035_송영훈](https://github.com/0Hooni)|[S077_홍승완](https://github.com/hsw1920)|
|:---:|:---:|:---:|:---:|
|<img src="https://avatars.githubusercontent.com/u/121777185?v=4" width=150>|<img src="https://avatars.githubusercontent.com/u/60254939?v=4" width=150>|<img src="https://avatars.githubusercontent.com/u/37678646?v=4" width=150>|<img src="https://avatars.githubusercontent.com/u/66902876?v=4" width=150>|
| 건강한 코드를 써내는<br>개발자가 되고싶습니다. | 지는거에요?<br>이겨. | 디버깅 다 해줬잖아. | 정상화... 해야겠지? |
| iOS | iOS | iOS | iOS |

## 개발 환경

| 환경  | 버전 |
|:---|:---|
| XCode | 16+ |
|Swift | 5.9 |
| Deployment Target | iOS 16+ |
| Packaging | SPM |

## 아키텍쳐 구조

3-layer Clean Architecture 를 기반하고 있습니다.

짧은 프로젝트 기간동안 팀의 생산성을 높일 수 있는 구조를 고민했습니다.

최종적으로 test double과 demo 앱을 활용해 작업간의 종속성을 끊어 독립적인 작업을 할 수 있도록 했습니다.

![1234](https://github.com/user-attachments/assets/11d8c188-af32-47fc-811f-88bd83417863)


## 기술 스택

### WebRTC

> 실시간으로 영상/음성/데이터를 주고 받기 위해 사용했습니다.
> 
> iOS 개발자밖에 없는 프로젝트였고, 짧은 기간 내에 개발을 해야하다보니
> 
> 서버 작업을 최소화하기 위해 p2p 방식인 WebRTC 방식을 채택했습니다.

### AVFoundation

> 카메라 촬영 및 편집 그리고 VoIP 기능을 위해 사용했습니다.

### Vision

> 영상에서 사람의 얼굴을 인식하고, 이미지 전처리 및 후처리를 하기 위해 사용했습니다.

### Combine

> 비동기 프로그래밍과 UI 바인딩을 위해 사용했습니다.
>
> 다른 선택지로는 RxSwift가 있었고, 성능과 퍼스트 파티라는 이유에서 Combine을 선택하게 되었습니다.
> 
> 만약 다양한 UI 컴포넌트와의 바인딩이 필요했다면 RxSwift와 RxCocoa를 사용했겠지만, 해당 프로젝트에선 화면이 적고 비교적 UI 컴포넌트들이 간단해 사용하지 않았습니다.

### Swift Concurrency

> GCD보다 성능이 뛰어나고, Combine에 비해 단발성 비동기 이벤트 처리에 특화되어 있다고 생각합니다.
>
> 그래서 네트워킹과 관련된 작업은 Concurrency를 사용하고, UI바인딩은 Combine을 사용해 각 비동기 프레임워크의 장점을 활용해보고자 했습니다.





|🏷️ 바로가기|[Wiki](https://github.com/boostcampwm-2024/iOS04-HARU/wiki)|[팀 노션](https://www.notion.so/0hooni/HARU-12e07f89fdcd8077a443dbba60cb124d)|[그라운드 룰](https://github.com/boostcampwm-2024/iOS04-HARU/wiki/그라운드-룰)|[컨벤션](https://github.com/boostcampwm-2024/iOS04-HARU/wiki/컨벤션)|[회의록](https://www.notion.so/0hooni/05cb406cd61f460ba7294ae3ffa31f7e)|[기획/디자인](https://www.figma.com/design/6jACkAa5WxD8mm4KgsPtzg/iOS04-GP?node-id=0-1&t=XKnwbbICywj03yF8-1)|
|:-:|:-:|:-:|:-:|:-:|:-:|:--:|
