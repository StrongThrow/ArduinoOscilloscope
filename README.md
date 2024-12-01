# 작품명: 아두이노를 이용한 오실로스코프 및 전용 어플리케이션

![처음화면](https://github.com/user-attachments/assets/4a7c15e7-a680-4ace-aed5-05c3e6b10f1f)

(유튜브 링크 : https://youtu.be/PqTVPX0_A_k)

아두이노의 ADC를 이용하여 간이 오실로스코프 역할을 하는 프로젝트

## 배경

전자공학부에서 프로젝트를 진행하거나 공부를 할 때 원하는 시나리오대로 GPIO핀의 출력이 잘 안나올 때가 있었고

이런 상황일 때 오실로스코프같은 장비 없이는 제대로 된 출력이 나오는지 확인하기 어려움이 있었다

따라서 학부생들이 제일 많이 가지고 있는 아두이노를 활용하여 간단한 간이 오실로스코프를 만드는 프로젝트를 진행하였다

## 개발목표

- 아두이노와 최대한 적은 부품들, 간결한 회로를 이용하여 제작
- 전용 어플리케이션을 개발하고 아두이노와 블루투스 통신을 하여 추가 디스플레이 제공 및 간결한 회로 구성
- 간이 오실로스코프 기능 뿐만 아니라 처음 배우는 학생들에게도 도움이 될 수 있는 가이드 제공
- 어플리케이션을 활용하여서 2채널 오실로스코프를 사용 가능하게끔 지원
- 전자공학부에서 많이 사용되는 센서들과 액츄에이터들을 시뮬레이션 하는 기능
- 3D 모델링 파일을 지원하여 케이스를 3D프린터로 간단하게 출력을 할 수 있게 함

## 원리

#### (오실로스코프)
- 아두이노의 ADC를 이용하여 100회의 sampling을 sampleInterver의 간격을 두고 수행함(sampleInterver은 사용자의 설정에 따라 200us부터 2의 배수로 증가시킴)
- 100회의 sampling이 끝나면 ADC값 배열의 최대값, 최소값을 찾고 이의 중간값을 threshold값으로 설정
- sampling한 파형이 threshold값을 3번 넘으면(ex 아래에서 위로 -> 위에서 아래로 -> 아래에서 위로)한 파형을 측정하였다고 여김
- sampling하는데 걸린 시간을 이용하여 한 파형의 주기, duty ratio를 계산함
- OLED 디스플레이에 파형, 주기, sampling time을 출력
- 위의 내용을 계속 반복하여 파형을 계속 출력함

#### (SG-90 시뮬레이션)
- 위에서 구한 파형의 주기와 duty ratio를 이용하여 20ms주기의 PWM신호가 맞게 들어오는지 판단함
- 현재 0도, 90도, 180도 구현 완료

#### (DHT-11 시뮬레이션)
-코드의 각주 참고

#### (HC-SR04 시뮬레이션)
-코드의 각주 참고



## 동작 시나리오

![동작 시나리오](https://github.com/user-attachments/assets/4ef5ec5d-ea19-44e0-ac86-1f3d078a5670)

## 회로도

![회로도](https://github.com/user-attachments/assets/16e30dbc-24f7-46f2-9638-f184e084ca02)

## 3D 모델링 및 외관

![외관](https://github.com/user-attachments/assets/ed3357a7-eeb5-4285-b4ab-0710317535df)

## 어플리케이션
#### 초기화면 및 가이드
![초기화면 및 가이드](https://github.com/user-attachments/assets/7efca86f-b82a-40bd-9cc6-c9a69779c1b0)

#### 메뉴와 기능들
![메뉴와 각종 기능](https://github.com/user-attachments/assets/15d83998-a611-49e5-a623-8c894037e61f)

## 개발환경

![개발환경](https://github.com/user-attachments/assets/bf43c1ff-1d0f-47ac-878f-d824f44c22fe)

## 수상 내역
![처음화면 - 복사본](https://github.com/user-attachments/assets/5b642b28-f23a-4478-8f65-4a5b99407678)

## 팀원

| ProFile | Role | Part | Tech Stack |
|:--------:|:--------:|:--------:|:--------:|
| ![KakaoTalk_20241113_230554223](https://github.com/user-attachments/assets/986e1819-2d0d-4715-97ce-590ea6495421) <br> [강송구](https://github.com/Throwball99) |   팀장  |   HW, SW(오실로스코프) |   Arduino, Fusion 360 |
| ![pngtree-faceless-user-anonymous-unknown-icon-png-image_4816463](https://github.com/user-attachments/assets/bfd8d075-4b37-4b94-b6ca-e27ba3707f3c) <br>  길재훈  |   팀원  |   SW(신호 발생기)  |   Arduino  |
|   ![개구리](https://github.com/Throwball99/2023ESWContest_free_1042/assets/143514249/69319bbd-74bb-40c1-92d8-ae96e23b3500) <br> [최지민](https://github.com/irmu98)    |   팀원  |   SW(어플리케이션)  |   Flutter, Android  |
