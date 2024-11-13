#include <Wire.h>               // I2C 통신을 위한 라이브러리
#include <LiquidCrystal_I2C.h> // LCD 2004 I2C용 라이브러리

#include <Servo.h>

#include <DHT.h>

#define buttonPin_LED 2
#define buttonPin_Servo 3
#define buttonPin_DCMotorDriver 4
#define buttonPin_IR 7
#define buttonPin_Ultrasonic 5
#define buttonPin_TemperatureHumidity 6

#define outputPin 11

#define IR A0

#define Trigger A3
#define Echo A2

#define TemperatureHumidity A1

LiquidCrystal_I2C lcd(0x27, 16, 2);
// 0x3F or 0x27를 선택하여 주세요. 작동이 되지 않는 경우 0x27로 바꾸어주세요. 확인 결과 0x3f가 작동하지 않을 수 있습니다.
//고유주소가 LCD마다 다르기 때문입니다.

Servo servo; // 서보 모터 객체 생성

DHT dht(A1, DHT11);

void setup()
{
  Serial.begin(9600);
  delay(1000);
  Serial.println("Start Serial Monitor!");

  // Buttons
  pinMode(buttonPin_LED, INPUT);
  pinMode(buttonPin_Servo, INPUT);
  pinMode(buttonPin_DCMotorDriver, INPUT);
  pinMode(buttonPin_IR, INPUT);
  pinMode(buttonPin_Ultrasonic, INPUT);
  pinMode(buttonPin_TemperatureHumidity, INPUT);

  // Display
  lcd.init();           // LCD 초기화
  lcd.backlight();     // 백라이트 켜기
  lcd.setCursor(0,0); // 첫번째 column 열, 첫번째 row 행부터 시작
  lcd.print("Hi! My name is a");
  //delay(1000);
  lcd.setCursor(0,1); // 첫번째 column 열, 첫번째 row 행부터 시작
  lcd.print("Signal Generator!");
  delay(3000);

  lcd.init();          // LCD 초기화
  lcd.setCursor(0,0); //첫번째 열, 두번째 행부터 시작
  lcd.print("Press");
  //delay(1000);
  lcd.setCursor(0,1); //두번째 열, 4번째 행부터 시작
  lcd.print("the mode button!");
  delay(1000);

  // Servo
  servo.attach(outputPin);
  
  // DC Motor Driver
  pinMode(outputPin, OUTPUT);

  // IR
  pinMode(IR, INPUT);

  // Ultrasonic
  pinMode(Trigger, OUTPUT);
  pinMode(Echo, INPUT);

  // Temperature And Humidity
  dht.begin();
  pinMode(TemperatureHumidity, INPUT);

  // Out Put
  pinMode(outputPin, OUTPUT);
}

void loop()
{
  int button_LED = digitalRead(buttonPin_LED);
  int button_Servo = digitalRead(buttonPin_Servo);
  int button_DCMotorDriver = digitalRead(buttonPin_DCMotorDriver);
  int button_IR = digitalRead(buttonPin_IR);
  int button_Ultrasonic = digitalRead(buttonPin_Ultrasonic);
  int button_TemperatureHumidity = digitalRead(buttonPin_TemperatureHumidity);

  if (button_LED == HIGH)
  {
    Display_CurrentMode("LED");

    while(1)
    {
      Mode_LED();  // 또는 다른 모드 실행
      
      if (Check_Buttons())
        break;  // 다른 버튼이 눌리면 while에서 탈출
    }
  }
  else if (button_Servo == HIGH)
  {
    Display_CurrentMode("Servo");
    
    while(1)
    {
      Mode_Servo();

      if (Check_Buttons())
        break;
    }
  }
  else if (button_DCMotorDriver == HIGH)
  {
    Display_CurrentMode("DC Motor Driver");
    
    while(1)
    {
      Mode_DCMotorDriver();

      if (Check_Buttons())
        break;
    }
  }
  else if (button_IR == HIGH)
  {
    Display_CurrentMode("IR");
    
    while(1)
    {
      Mode_IR();

      if (Check_Buttons())
        break;
    }
  }
  else if (button_Ultrasonic == HIGH)
  {
    Display_CurrentMode("Ultrasonic");
    
    while(1)
    {
      Mode_Ultrasonic();

      if (Check_Buttons())
        break;
    }
  }
  else if (button_TemperatureHumidity == HIGH)
  {
    Display_CurrentMode("Temper & Humidi");
    
    while(1)
    {
      Mode_TemperatureHumidity();

      if (Check_Buttons())
        break;
    }
  }
}

bool Check_Buttons()
{
  if (digitalRead(buttonPin_LED) == HIGH || digitalRead(buttonPin_Servo) == HIGH || 
      digitalRead(buttonPin_DCMotorDriver) == HIGH || digitalRead(buttonPin_IR) == HIGH || 
      digitalRead(buttonPin_Ultrasonic) == HIGH || digitalRead(buttonPin_TemperatureHumidity) == HIGH)
  {
    Display_NextMode();  // 모드 변경 안내 메시지
    
    return true;         // 다른 버튼이 눌리면 true 반환
  }
  return false;          // 눌린 버튼이 없으면 false 반환
}

void Display_CurrentMode(String mode)
{
  lcd.clear(); // 화면을 지우고 새로 출력
  lcd.setCursor(0,0);
  lcd.print("Current Mode : ");
  delay(1000);
  lcd.setCursor(0,1);
  lcd.print(mode);
  delay(1000);
}

void Display_NextMode()
{
  lcd.clear(); // 화면을 지우고 새로 출력
  lcd.setCursor(0,0);
  lcd.print("The current mode");
  lcd.setCursor(0,1);
  lcd.print("is complete.");
  delay(3000);

  lcd.clear(); // 화면을 지우고 새로 출력
  lcd.setCursor(0,0);
  lcd.print("Press the button");
  lcd.setCursor(0,1);
  lcd.print("of the next mode.");
  delay(1000);
}

void Mode_LED()
{
  digitalWrite(outputPin, HIGH);
  Serial.println(HIGH);
  delay(1000);
  digitalWrite(outputPin, LOW);
  Serial.println(LOW);
  delay(1000);
}
  
void Mode_Servo()
{
  // 서보 모터를 0도에서 90도까지 움직임
  for (int angle = 0; angle <= 90; angle++)
  {
    servo.write(angle); // 서보 모터를 해당 각도로 회전
    delay(10); // 서보가 이동하는 시간 제공
  }
  delay(1000);
  // 서보 모터를 90도에서 180도까지 움직임
  for (int angle = 90; angle <= 180; angle++)
  {
    servo.write(angle); // 서보 모터를 해당 각도로 회전
    delay(10); // 서보가 이동하는 시간 제공
  }
  delay(1000);
  // 서보 모터를 180도에서 90도까지 다시 움직임
  for (int angle = 180; angle >= 90; angle--)
  {
    servo.write(angle);
    delay(10);
  }
  delay(1000);
  // 서보 모터를 90도에서 0도까지 다시 움직임
  for (int angle = 90; angle >= 0; angle--)
  {
    servo.write(angle);
    delay(10);
  }
  delay(1000);
}
void Mode_DCMotorDriver()
{
  digitalWrite(outputPin, HIGH);
  Serial.println(HIGH);
  delay(1000);
  //digitalWrite(outputPin, LOW);
  //Serial.println(LOW);
  //delay(1000);
}
void Mode_IR()
{
  // 적외선 센서에서 디지털 신호를 읽음
  int sensorValue = digitalRead(IR);
  
  // 읽은 신호를 그대로 outputPin에 출력
  digitalWrite(outputPin, sensorValue);

  // 시리얼 모니터에 적외선 센서의 출력 상태 표시
  Serial.print("IR Sensor State: ");
  if (sensorValue == HIGH) {
    Serial.println("No Obstacle");
  } else {
    Serial.println("Obstacle Detected");
  }
  delay(1000); // 짧은 지연을 추가 (1000ms마다 체크)
}

void Mode_Ultrasonic()
{
  // Trig 핀을 짧게 HIGH로 만들어 초음파를 발사
  digitalWrite(Trigger, LOW);
  delayMicroseconds(2);
  digitalWrite(Trigger, HIGH);
  delayMicroseconds(10);
  digitalWrite(Trigger, LOW);

  // Echo 핀의 신호 펄스 길이를 측정
  long duration = pulseIn(Echo, HIGH);
  
  // 펄스 길이를 시리얼 모니터에 출력
  //Serial.print("Duration: ");
  //Serial.println(duration);
  //delay(1000);

  // 시간(duration)을 이용하여 거리 계산 (음속은 약 340m/s)
  // 거리 = 시간 * 음속 / 2 (왕복 시간이므로 2로 나눔)
  long distance = duration * 0.034 / 2;

  // 측정된 거리를 시리얼 모니터에 출력
  Serial.print("Distance : ");
  Serial.print(distance);
  Serial.println(" cm");

  // Echo 핀의 신호를 읽어서 그대로 outputPin에 출력
  //int echoState = digitalRead(Echo); // Echo 핀 상태 읽기
  //digitalWrite(outputPin, echoState);   // Echo 핀 상태를 그대로 outputPin에 전달
  //Serial.println(echoState);
  delay(1000); // 짧은 지연을 추가하여 신호가 안정적으로 전달되도록 함
}

void Mode_TemperatureHumidity()
{
  // DHT11에서 비트 단위로 신호를 읽기
  /*if (readDHT11()) {
    // 성공적으로 읽은 경우
    Serial.println("Signal Read Successfully.");
  } else {
    Serial.println("Failed to read from DHT sensor!");
  }*/

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // 온습도 값을 제대로 읽었는지 확인
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("DHT 센서에서 데이터를 읽는 중 오류 발생");
    return;
  }

  // 시리얼 모니터에 온도와 습도 출력
  Serial.print("습도 : ");
  Serial.print(humidity);
  Serial.print(" %, 온도 : ");
  Serial.print(temperature);
  Serial.println(" *C");

  delay(1000); // 1초 대기
}

// DHT11에서 신호를 비트 단위로 읽고 출력하는 함수
bool readDHT11() {
  uint8_t data[5] = {0}; // 5바이트 데이터 배열 초기화
  pinMode(TemperatureHumidity, OUTPUT); // 데이터 핀을 출력으로 설정
  digitalWrite(TemperatureHumidity, LOW); // 시작 신호를 위해 LOW 신호 전송
  delay(18); // 18ms 대기
  digitalWrite(TemperatureHumidity, HIGH); // HIGH 신호 전송
  delayMicroseconds(40); // 40us 대기
  pinMode(TemperatureHumidity, INPUT); // 데이터 핀을 입력으로 설정

  // DHT11 신호를 읽기 위한 루프
  for (int i = 0; i < 5; i++) {
    // 각 비트를 읽기 위한 루프
    for (int j = 0; j < 8; j++) {
      while (digitalRead(TemperatureHumidity) == LOW); // LOW 신호를 기다림
      delayMicroseconds(30); // 신호의 지속 시간을 측정하기 위해 대기
      if (digitalRead(TemperatureHumidity) == HIGH) {
        data[i] |= (1 << (7 - j)); // HIGH 비트를 저장
      }
      while (digitalRead(TemperatureHumidity) == HIGH); // HIGH 신호가 끝날 때까지 대기
    }
  }

  // 읽은 비트를 시리얼 모니터에 출력
  Serial.print("Read Bits : ");
  for (int i = 0; i < 5; i++) {
    Serial.print(data[i], BIN); // 비트 단위로 출력
    Serial.print(" ");
    
    // 출력 핀에 비트 전송
    for (int j = 7; j >= 0; j--) {
      digitalWrite(outputPin, (data[i] >> j) & 1); // 각 비트를 출력 핀으로 전송
      delayMicroseconds(100); // 비트 전송 후 대기
    }
  }
  Serial.println();

  return true; // 성공적으로 읽음
}