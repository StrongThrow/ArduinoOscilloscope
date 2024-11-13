#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <SoftwareSerial.h>

// 핀 및 디스플레이 설정
#define ADC_PIN_1 A1 // 아날로그 입력 핀 A1
#define ADC_PIN_3 A3 // 아날로그 입력 핀 A0


// OLED 디스플레이 설정을 PROGMEM에 저장
const uint8_t SCREEN_WIDTH PROGMEM = 128; // OLED 디스플레이 너비
const uint8_t SCREEN_HEIGHT PROGMEM = 64; // OLED 디스플레이 높이
const int OLED_RESET PROGMEM = -1; // 리셋 핀 (공유 리셋 핀 사용시 -1)
const int SCREEN_ADDRESS PROGMEM = 0x3C; // OLED 디스플레이 I2C 주소
const uint8_t TX_PIN PROGMEM = 10; // TX 핀 
const uint8_t RX_PIN PROGMEM = 11; // RX 핀 

//블루투스 객제 생성
SoftwareSerial BTSerial(TX_PIN, RX_PIN);  // HC-06 연결 핀 (TX: 10, RX: 11)
//블루투스 버퍼 사이즈
const uint8_t BT_BUFFER_SIZE PROGMEM = 6;

//블루투스 수신 배열
char inputBuffer[BT_BUFFER_SIZE];
//블루투스 수신 배열의 인덱스
uint8_t BTindex = 0;

// OLED 디스플레이 객체 생성
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

uint8_t verticalScale = 1; // Oled 디스플레이 수직 스케일
uint8_t horizontalScale = 1; // Oled 디스플레이 수평 스케일 

// 샘플링 관련 설정
const uint8_t SAMPLE_SIZE PROGMEM = 100;// ADC 샘플링 배열 크기

uint8_t samples[SAMPLE_SIZE]; // 20ms 길이의 샘플 배열
uint8_t adc0Data[SAMPLE_SIZE / 5]; // BT로 송신하는 ADC 데이터 배열 크기
uint8_t cntAdc0 = 0;
uint8_t cnt = 0;// 20ms 길이 샘플 배열 카운팅
bool samplesComplete = false;
unsigned long collectTime = 0;
unsigned long collectTime_before = 0;

// 타이밍 관련 변수
unsigned long lastSampleTime = 0;     // 마지막 샘플 수집 시간
unsigned long sampleInterval = 400;   // 샘플링 간격 (마이크로초 단위, us)

// 측정값 저장 변수
float maxVoltage = 0.0;        // 최대 전압
float minVoltage = 5.0;        // 최소 전압

//sg90 변수
double sg90High = 0;
double sg90Low = 0;

//sr04변수
uint8_t simulatedDistance = 10; // 아두이노에 보낼 거리(cm)
bool sr04State = false;

//오실로스코프 모드 및 배율, ADC on/off
uint8_t scopeMode = 0;
//오실로스코프 1채널 활성화
bool scopeWork = true;
//오실로스코프 2채널 활성화
bool scopeCh2 = false;

//dht11 시뮬레이션 할 때의 온습도값
byte humidity =50;  // 습도
byte temperature = 50;  // 온도

void setup() {
  Serial.begin(57600);      //시리얼 통신 활성화, 57600 보드레이트는 
                            //AT Command를 이용하여서 HC-06의 통신 속도를 변경함

  BTSerial.begin(57600);    // HC-06 블루투스 통신 시작
  pinMode(ADC_PIN_1, INPUT);// ADC 핀을 입력으로 설정
  pinMode(ADC_PIN_3, INPUT);// ADC 핀을 입력으로 설정
  Wire.begin();             // I2C 통신 초기화
  Wire.setClock(400000);    // I2C 클럭 속도 설정 (400kHz)

  //OLED 디스플레이 초기화
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 할당 실패"));
    for(;;);  // 초기화 실패 시 무한 루프
  }

  display.clearDisplay();      // 디스플레이 초기화

  //OLED 초기화면 Set
  /*-----------
    |Please    |
    |Connect   |
    |Bluetooth |
    ------------*/
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.print(F("Please"));
  display.setCursor(0, 20);
  display.print(F("Connect"));
  display.setCursor(0,40);
  display.print(F("Bluetooth"));
  display.display();

  //블루투스 연결이 될 때까지 대기
  while(1){
    //100ms 마다 BT연결을 확인
    delay(100);
    //수신된 데이터가 있으면 while문 break
    if(BTSerial.available() != 0) break;
  }

  //아두이노가 켜지고 난 뒤 지나간 시간 저장
  lastSampleTime = micros();
  collectTime_before = micros();

  //디스플레이 초기화
  display.clearDisplay(); 
  display.display();
}

void loop() {
  //블루투스 수신 대기, 데이터가 수신이 되면 데이터를 Read
  while(BTSerial.available() > 0){
    BTreceive(scopeMode);
  }
  //ADC 샘플링이 true 이면 샘플링 시작
  if(scopeWork) collectSample(scopeMode);

  //어플리케이션이 메인 화면일 때의 OLED 화면
  if(scopeMode == 0){
    display.setTextSize(2);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0, 0);
    display.print(F("Please"));
    display.setCursor(0, 20);
    display.print(F("Select"));
    display.setCursor(0,40);
    display.print(F("Menu"));
    display.display();
    //collectTime_before 최신화
    collectTime_before = micros();
  }
  //어플리케이션으로 오실로스코프를 활성화 시켰을 때
  else if((scopeMode == 1) || (scopeMode == 3)){
    if(samplesComplete == true){
      //샘플링 된 ADC값의 최대, 최소 값 구하기
      calculateMeasurements(samples);
      //OLED 디스플레이에 그래프 그리기
      displayWaveform(samples, collectTime, scopeMode);
      //samplesComplete를 false로 변경하여 다시 샘플링 할 수 있게 함
      samplesComplete = false;
      //샘플링, 디스플레잉이 끝난 시간 저장
      collectTime_before = micros();
    }
  }
  //어플리케이션으로 오실로스코프 정지 버튼을 눌렀을 때
  else if(scopeMode == 2){
    //오실로스코프 정지, 아두이노에서 아무것도 수행하지 않으면
    //oled가 멈춘 것 처럼 보임
    ;;
  }
  // else if(scopeMode == 3){
  //   //sg90 시뮬레이션
  //   if(samplesComplete == true){
  //     //샘플링 된 ADC값의 최대, 최소 값 구하기
  //       calculateMeasurements(samples);
  //       displayWaveform(samples, collectTime, scopeMode);
  //       collectTime_before = micros();
  //       samplesComplete = false;
  //     }
  // }

  //어플리케이션에서 sr04 초음파 센서 시뮬레이션을 선택하였을 때
  else if(scopeMode == 4){
    //sr04 시뮬레이션
    sr04Simulation(scopeMode);
    collectTime_before = micros();
  }

  //어플리케이션에서 모터 드라이버, LED를 시뮬레이션을 선택하였을 때
  else if (scopeMode == 5){
    //n개의 adc를 Read하여 한 파형의 샘플링을 끝냈을 때
    if(samplesComplete == true){
      
      //파형의 최대, 최소값을 구함
      calculateMeasurements(samples);

      //파형의 평균 전압을 구함
      float avrVoltage = calculateAvrVoltage(samples);

      //BT로 송신할 문자열
      char sendBT[6];
      //float형의 온도를 문자열로 변환하기 위한 변수
      char voltage[5];
      //float형의 온도를 char형으로 변환
      dtostrf(avrVoltage, 4, 2, voltage);

      //가공된 문자열 전송
      sendBT[0] = 'V';
      strncpy(&sendBT[1], voltage, 4);
      sendBT[5] = '*';
      Serial.println(sendBT);
      BTsend(sendBT, 6);

      //OLED 디스플레이에 그래프 디스플레잉
      displayWaveform(samples, collectTime, scopeMode);

      //샘플링, BT전송, 그래프 디스플레잉이 끝난 시간 업데이트
      collectTime_before = micros();
      
      //다시 샘플링 할 수 있게 변수 초기화
      samplesComplete = false;
    }

  }

  //어플리케이션에서 dht-11 온습도센서 시뮬레이션을 선택하였을 때
  else if (scopeMode == 7){
    //dht-11 시뮬레이션
    dht11Simulation(scopeMode);
  }
}

//ADC를 이용하여 샘플링 하는 함수
void collectSample(uint8_t mode){
  //샘플링 시간마다 반복함
  if (micros() - lastSampleTime >= sampleInterval){
    //노이즈 방지를 위해 꺼보았음, 확실하지 않음
    pinMode(ADC_PIN_3, OUTPUT);
    //A1 핀 INPUT모드
    pinMode(ADC_PIN_1, INPUT);
    samples[cnt++] = analogRead(ADC_PIN_1) >> 2;// 10비트 ADC값을 8비트로 변환 (0~255)
                                                // right shift 하여 0 ~ 1023 의 값을 0 ~ 255로 줄임

    //어플리케이션에서 2채널을 활성화 시켰을 때                                            
    if((mode == 1) && (scopeCh2 == true)){
      //AD0 아날로그 값 구함
      delayMicroseconds(10);//adc1 의 샘플링 후 10us 동안 대기
      pinMode(ADC_PIN_1, OUTPUT);// 노이즈 방지를 위해 꺼보았음, 확실하지 않음
      pinMode(ADC_PIN_3, INPUT); // A3핀 입력 활성화
      adc0Data[cntAdc0++] = analogRead(ADC_PIN_3) >> 2;// 10비트 ADC값을 8비트로 변환 (0~255)
                                                // right shift 하여 0 ~ 1023 의 값을 0 ~ 255로 줄임
      //20개의 샘플 데이터를 모았으면
      if(cntAdc0 == SAMPLE_SIZE / 5){
        //BT로 어플리케이션에 데이터 송신
        BTsendByte(adc0Data, SAMPLE_SIZE / 5);
        //카운팅 초기화
        cntAdc0 = 0;
      }
    }

    //하나의 배열을 다 채웠으면 변수 초기화
    if(cnt == SAMPLE_SIZE){
      cnt = 0;
      collectTime = (micros() - collectTime_before);
      samplesComplete = true;
      //if(mode == 1) BTSerial.print('\n');      // 줄바꿈 문자 추가
    }
    //샘플링이 끝난 시간 최신화
    lastSampleTime = micros();
  }
}

// 최대/최소 전압을 계산하는 함수
void calculateMeasurements(uint8_t samples[]) {
  //현재는 부가적인 회로 없이 ADC만 이용하기 때문에
  //ADC로 Read할 수 있는 값의 최대값인 5V, 최소값인 0V를 설정함
  maxVoltage = 0.0;
  minVoltage = 5.0;

  //배열의 요소들 중 최소값과 최대값을 찾음
  for (uint16_t i = 0; i < SAMPLE_SIZE; i++) {
    float voltage = samples[i] * 5.0 / 255.0;  // 8비트 값을 전압으로 변환
    //현재 배열의 요소의 값이 최대값보다 크면 값 업데이트
    if (voltage > maxVoltage) maxVoltage = voltage;
    //현재 배열의 요소의 값이 최소값보다 작으면 값 업데이트
    if (voltage < minVoltage) minVoltage = voltage;
  }
}

//평균 전압을 구해서 return 하는 함수
float calculateAvrVoltage(uint8_t samples[]){
  //샘플링 된 데이터의 모든 전압을 더해서 평균을 구함
  float sumVoltage = 0;
  for(uint16_t i = 0; i < SAMPLE_SIZE; i++){
    sumVoltage = (samples[i] * 5.0 / 255.0) + sumVoltage;
  }
  float avrVoltage = sumVoltage / SAMPLE_SIZE;

  //Serial.print("avrVoltage : "); Serial.println(avrVoltage);
  return avrVoltage;
}


//파형의 주기를 구해서 return하는 함수
//n개의 배열의 ADC값 중 최소값과 최대값을 찾은 뒤 그 중간값을 계산하여 threshold값으로 정함
//threshold 값을 1. 아래에서 위로 통과할 때의 교차점
//               2. 위에서 아래로 통과할 때의 교차점
//               3. 아래에서 위로 통과할 때의 교차점
//를 검출한 뒤 샘플링 한 시간을 us로 계산하여 이를 1번째 교차점과 3번째 교차점 사이에 해당하는 비율을 이용하여 주기 계산 
float calculatePeriod(uint8_t samples[], unsigned long collectTime, uint8_t mode) {

  //샘플링 된 배열의 최소값과 최대값의 중간 값을 threshold값으로 함
  float threshold = (maxVoltage + minVoltage) / 2;
  //샘플링 된 배열의 몇 번째 요소가 threshold를 넘는 교차점인지 저장하기 위한 변수 
  uint8_t firstCross = 0, secondCross = 0, thirdCross = 0;
  
  //첫 번째, 두 번째, 세 번째 교차점을 찾았는지 알려주는 bool 값
  bool firstCrossFound = false;
  bool secondCrossFound = false;
  bool thirdCrossFound = false;

  for (uint8_t i = 1; i < SAMPLE_SIZE; i++) {
      // 첫 번째 교차점 탐지
      if (!firstCrossFound && (samples[i - 1] < threshold) && (samples[i] > threshold)) {
          firstCross = i;
          firstCrossFound = true;
      }
      // 두 번째 교차점 탐지
      else if (firstCrossFound && !secondCrossFound && (samples[i - 1] > threshold) && (samples[i] < threshold)) {
          secondCross = i;
          secondCrossFound = true;
      }
      // 세 번째 교차점 탐지
      else if (secondCrossFound && !thirdCrossFound && (samples[i - 1] < threshold) && (samples[i] > threshold)) {
          thirdCross = i;
          thirdCrossFound = true;
      }

      // 세 번째 교차점까지 찾았다면 주기 계산
      if (firstCrossFound && secondCrossFound && thirdCrossFound) {
          float period = round((thirdCross - firstCross) * (collectTime) / SAMPLE_SIZE) / 1000;
          
          //sg-90 서보모터를 시뮬레이션 할 때 (0도, 90도, 180도만 가능)
          if(mode == 3){
            //Low와 HIGH 신호의 길이를 분석하여 Duty ratio 분석
            sg90Low = (thirdCross - secondCross) * (collectTime / SAMPLE_SIZE)/100;
            sg90High = (secondCross - firstCross) * (collectTime / SAMPLE_SIZE)/100;

            //Serial.print("High : "); Serial.print(sg90High); Serial.println("ms");
            //Serial.print("Low : "); Serial.print(sg90Low); Serial.println("ms");
            
            //Duty ratio 구함
            float dutyRatio = (sg90High / (sg90High +sg90Low)) * 100;

            Serial.print("duty ratio : "); Serial.println(dutyRatio);

            //각도에 따라 어플리캐이션에 데이터 송신
            //1차로 sg-90에 맞는 pwm 신호가 들어오는지 분석함
            if(((sg90Low + sg90High) > 190) && ((sg90Low + sg90High) < 210)){

              //0도에 해당하는 pwm신호가 들어오면
              if(dutyRatio < 3 && dutyRatio > 0){
                //어플리케이션에 각도 전송
                BTsend("S000*", 5);
              }

              //90도에 해당하는 pwm신호가 들어오면
              else if(dutyRatio > 3 && dutyRatio < 9){
                //어플리케이션에 각도 전송
                BTsend("S090*", 5);
              }

              //180도에 해당하는 pwm신호가 들어오면
              else if(dutyRatio > 9 && dutyRatio < 13){
                //어플리케이션에 각도 전송
                BTsend("S180*", 5);
              }
            }

          }
          return period; // 주기 반환
      }
  }

  // 교차점이 발견되지 않았을 경우 0 반환
  return 0.0;
}

// 파형 및 정보를 디스플레이에 표시하는 함수
void displayWaveform(uint8_t samples[], unsigned long collectTime, uint8_t mode) {
  //디스플레이 클리어
  display.clearDisplay();
  
  //파형의 주기를 읽음
  float period = calculatePeriod(samples, collectTime, mode);

  // 측정값 표시 (상단에 배치)
  // OLED 디스플레이는 이렇게 출력이 됨
  /*--------------------------------------------------------------
    | MAX : 최대값(V) MIN : 최소값(V)                             |
    | X : 파형을 샘플링 하고 디스플레잉 하기까지의 시간(ms) P : 주기|
    |                                                            |
    |                                                            | 
    |                        그래프                               |
    |                                                            |
    |                                                            |
    --------------------------------------------------------------*/
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.print(F("MAX:"));
  display.print(maxVoltage, 1);
  display.print(F("V MIN:"));
  display.print(minVoltage, 1);
  display.print(F("V"));

  display.setCursor(0, 8);
  display.print(F("X :"));
  //display.print(updateTime = millis() - lastUpdateTime);
  display.print(collectTime/1000);
  display.print(F("ms P : "));
  //display.print(F("P : "));
  display.print(period);
  display.print(F("ms"));

  // 오실로스코프 처럼 그리드 그리기
  const uint8_t gridYCoordinates[] = {18, 26, 40, 54, SCREEN_HEIGHT - 2};  // y좌표
  for (uint8_t i = 0; i < 5; i++) {
    for (uint8_t x = 28; x < SCREEN_WIDTH; x += 4) {
      display.drawPixel(x, gridYCoordinates[i], SSD1306_WHITE); 
    }
  }

  // y축 label 추가
  display.setCursor(0, 17);  // 5V 위치
  display.print(F("5V"));
  
  display.setCursor(0, 39);  // 2.5V 위치
  display.print(F("2.5V"));
  
  display.setCursor(0, SCREEN_HEIGHT - 9);  // 0V 위치
  display.print(F("1V"));

  // x축 세로 점선 그리드 추가
  for (uint8_t x = 28; x < SCREEN_WIDTH; x += 20) {
    for (uint8_t y = 17; y < SCREEN_HEIGHT; y += 4) {
      display.drawPixel(x, y, SSD1306_WHITE); // 세로 점선
    }
  }

  // 파형 그리기
  int16_t lastY = map(samples[0], 0, 255, SCREEN_HEIGHT - 1, 17);
  for (uint8_t x = 29; x < SCREEN_WIDTH; x++) { 
    uint16_t index = (x - 28) * horizontalScale; 
    if (index >= SAMPLE_SIZE) break;
    
    int16_t y = map(samples[index], 0, 255, SCREEN_HEIGHT - 1, 17);
    y = constrain(y, 17, SCREEN_HEIGHT - 2);  
    display.drawLine(x - 1, lastY, x, y, SSD1306_WHITE);
    lastY = y;
  }
  
  display.display();
}

//데이터가 수신되었는지 확인해주는 bool 함수, 데이터가 수신되었으면 true, 그렇지 않으면 false
bool BTdata(){
  if(BTSerial.available() != 0) return true;
  else return false;
}

void BTreceive(uint8_t &mode){
  //블루투스에서 데이터를 수신 받았으면
  if(BTSerial.available() != 0){
    char receiveValue = BTSerial.read();  // 문자 읽기

    //문자열의 끝 문자를 만나면
    if(receiveValue == '*'){
      inputBuffer[BTindex] = '*'; // 문자열 종료 문자 추가
      Serial.println(inputBuffer); // 시리얼 모니터에 출력
      //메인 메뉴
      if(inputBuffer[0] == 'a'){
        mode = 0;
        scopeWork = false;
      } 

      //오실로스코프 설정
      else if(inputBuffer[0] == 'b'){
        scopeWork = true;
        mode = 1;
        //오실로스코프 x축 길이 설정, 샘플링 주기를 변경하여 x축의 길이를 설정함
        if (inputBuffer[1] == '1') sampleInterval = 200;
        if (inputBuffer[1] == '2') sampleInterval = 400;
        if (inputBuffer[1] == '3') sampleInterval = 800;
        if (inputBuffer[1] == '4') sampleInterval = 1600;
        if (inputBuffer[1] == '5') sampleInterval = 3200;
        if (inputBuffer[1] == '6') sampleInterval = 6400;
        if (inputBuffer[1] == '7') sampleInterval = 12800;
        if (inputBuffer[1] == '8') mode = 2; // 오실로스코프 stop
        if (inputBuffer[1] == '9'){
          scopeCh2 = true; //2채널 오실로스코프 on
          pinMode(ADC_PIN_3, INPUT);
        } 
        if (inputBuffer[1] == '0') scopeCh2 = false; // 2채널 오실로스코프 off
        pinMode(ADC_PIN_3, OUTPUT);
      }

      //sg-90 시뮬레이션
      else if(inputBuffer[0] == 'c'){
        pinMode(ADC_PIN_3, OUTPUT);
        scopeWork = true;
        mode = 3;
        sampleInterval = 400;
      } 

      //sr-04 시뮬레이션
      else if(inputBuffer[0] == 'd'){
        //오실로스코프 작동 중단
        scopeWork = false;
        mode = 4;
        //버퍼에서 전송받은 거리 추출

        //문자를 숫자로 변환 ASCII코드 - 48 = 그 문자에 해당하는 숫자
        uint8_t a = inputBuffer[1] - 48;
        uint8_t b = inputBuffer[2] - 48;

        //10의 자리와 1의 자리의 숫자를 합쳐서 하나의 숫자로 만듦
        simulatedDistance = a * 10 + b;
        //Serial.println(simulatedDistance);
        //전송받은 거리 입력
        /*-----------
          |Simulated    |
          |Distance     |
          |is **cm      |
          ------------*/
        display.clearDisplay();
        display.setTextSize(2);
        display.setTextColor(SSD1306_WHITE);
        display.setCursor(0, 0);
        display.print(F("Simulated"));
        display.setCursor(0, 20);
        display.print(F("Distance"));
        display.setCursor(0, 40);
        display.print(F("is "));
        display.print(simulatedDistance);
        display.print(F("cm"));
        display.display();
      } 

      //LED 시뮬레이션
      else if(inputBuffer[0] == 'e'){
        //오실로스코프 작동 
        pinMode(ADC_PIN_3, OUTPUT);
        scopeWork = true;
        sampleInterval = 400;
        mode = 5;
      } 

      //DC Motor 시뮬레이션
      else if(inputBuffer[0] == 'f'){
        //오실로스코프 작동 
        pinMode(ADC_PIN_3, OUTPUT);
        scopeWork = true;
        sampleInterval = 400;
        mode = 5;
      } 

      //Dht-11 시뮬레이션
      else if(inputBuffer[0] == 'g'){
        mode = 7;
        //오실로스코프 작동 중단
        scopeWork = false;
        //버퍼에서 전송받은 거리 추출
        humidity = ((inputBuffer[1] - 48) * 10) + (inputBuffer[2] -48);
        temperature = ((inputBuffer[3] - 48) * 10) + (inputBuffer[4] -48);
        //전송받은 거리 입력
        display.clearDisplay();
        display.setTextSize(2);
        display.setTextColor(SSD1306_WHITE);
        display.setCursor(0, 0);
        display.print(F("Simulated"));
        display.setCursor(0, 20);
        display.print(F("H : "));
        display.print(humidity);
        display.print(F(" %"));
        display.setCursor(0, 40);
        display.print(F("T : "));
        display.print(temperature);
        display.print(F(" C"));
        display.display();

      } 

      BTindex = 0;
      display.clearDisplay();
    }
    //문자열의 끝 문자를 만나지 않았으면
    else{
      inputBuffer[BTindex++] = receiveValue;
      //BTindex++;
    }
  }
}

void sr04Simulation(uint8_t mode){
  //핀모드 설정, INPUT 풀업 저항 설정, Trig핀에 해당
  pinMode(ADC_PIN_1, INPUT_PULLUP);
  //핀모드 설정, OUTPUT, ECHO핀에 해당
  pinMode(ADC_PIN_3, OUTPUT);
  //sr04의 TRIG 신호 Read
  uint8_t trigState = digitalRead(ADC_PIN_1);
  //풀업 저항으로 HIGH상태가 기본임
  if(trigState == LOW){
    //초음파 센서처럼 Echo핀으로 신호를 보내기 위해 시간을 계산
    long duration = simulatedDistance * 58; // 거리에 따른 시간 계산(음속)

    // ECHO핀에 신호 전송
    digitalWrite(ADC_PIN_3, HIGH);  // ECHO 핀 HIGH 신호
    delayMicroseconds(duration);// 계산된 시간 동안 신호 유지
    digitalWrite(ADC_PIN_3, LOW);    // ECHO 핀 LOW 신호로 설정

    //trig신호가 LOW가 될 때까지 대기(PULLUP저항이라 HIGH일 때)

    //이 while문에서 무한반복 중에 BT가 수신되었을 때 모드를 변경해야 함으로 break
    while(BTdata() == false){
      if(digitalRead(ADC_PIN_1) == HIGH) break;
      //모드가 바뀌어도 break
      if(mode != 4) break;
    }

  }

}

void dht11Simulation(uint8_t mode){
  //시작 신호 대기
  pinMode(ADC_PIN_1, INPUT);  // A1 핀 인풋 설정

  //이 while문에서 무한반복 중에 BT가 수신되었을 때 모드를 변경해야 함으로 break
  while(BTdata() == false){
    //LOW신호를 받을 때 까지 대기
    if(digitalRead(ADC_PIN_1) == LOW) break;
    //모드가 변경되어도 break
    if(mode != 7) break;
  }

  delay(18);// 마스터의 LOW 신호 동안 대기

  //만약 dht-11이 시뮬레이션 되지 않을 시에는 이 값을 변경하여 조절
  delayMicroseconds(15);

  //이 while문에서 무한반복 중에 BT가 수신되었을 때 모드를 변경해야 함으로 break
  while(BTdata() == false){
    //풀업 신호 대기
    if(digitalRead(ADC_PIN_1) == HIGH) break;
    //모드가 변경되어도 break
    if(mode != 7) break;
  }

  //만약 dht-11이 시뮬레이션 되지 않을 시에는 이 값을 변경하여 조절
  delayMicroseconds(20);

  // 응답 신호 보내기

  //온습도 정보 송신
  //A1핀을 OUTPUT으로 설정
  pinMode(ADC_PIN_1, OUTPUT);
  
  //데이터시트에 따라 LOW신호를 80us로 유지한 뒤 HIGH신호를 80us로 유지
  digitalWrite(ADC_PIN_1, LOW);
  delayMicroseconds(80);
  digitalWrite(ADC_PIN_1, HIGH);
  delayMicroseconds(80);
  
  //40비트 데이터 전송
  sendByte(humidity);
  sendByte(0);  // 습도 소수점 (항상 0)
  sendByte(temperature);
  sendByte(0);  // 온도 소수점 (항상 0)
  sendByte(humidity + temperature);  // 체크섬
  digitalWrite(ADC_PIN_1, LOW);
  delayMicroseconds(50);
  
  // 다음 읽기 요청을 기다림
}

//dht11에 비트단위 신호 보내는 함수
void sendByte(byte data) {
  for (int i = 7; i >= 0; i--) {
    pinMode(ADC_PIN_1, OUTPUT);
    digitalWrite(ADC_PIN_1, LOW);
    delayMicroseconds(50);
    digitalWrite(ADC_PIN_1, HIGH);
    
    if (bitRead(data, i)) {
      delayMicroseconds(70);
    } else {
      delayMicroseconds(27);
    }
    
  }
}


//블루투스로 데이터 전송하는 함수
void BTsend(const char message[], uint8_t length) {
  for(uint8_t i = 0; i < length; i++){
    BTSerial.print(message[i]);  // 메시지 전송
  }
  BTSerial.print('\n');      // 줄바꿈 문자 추가
}

//블루투스로 1바이트 데이터 전송하는 함수
void BTsendByte(const uint8_t data[], uint8_t length){
  for(uint8_t i = 0; i < length; i++){
    BTSerial.write(data[i]);
  }
}