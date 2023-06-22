# HangOutWithUs - flutter

Hang Out With Us 의 모바일 앱 클라이언트 입니다. 프론트엔드 지식이 부족하여 코드 퀄리티가 많이 낮습니다.

## API 통신

http 패키지를 사용하다가 토큰을 header에 담는 코드가 중복이 많이 되어 dio 패키지로 변경 후 interceptor를 작성해 onRequest 시에 header에 토큰을
담고, onRequest에서 AccessToken의 유효기간을 확인 후 만료시 자동으로 토큰을 재발급 받은 후 요청을 진행합니다.

## 카드 스와이프 애니메이션

appinio_swiper 라는 패키지를 사용해 카드 스와이프를 구현했습니다.

## 채팅

flutter_chat_ui 패키지를 사용해 채팅을 구현했습니다.

Stomp 사용

sqlflite 라는 데이터베이스를 사용해 채팅 내용을 저장했습니다.

## 소셜 로그인 - OAuth2

flutter_wet_auth 패키지를 사용해 Oauth2 소셜로그인을 구현했습니다.

## Token Authentication

JWT 로 토큰 방식의 인증을 하며 토큰은 secure_storage 패키지를 사용해 안전하게 저장합니다.

일반적인 api 통신을 할 때는 access token 만 header에 담아서 보내며, access token 재발급 시에만 refresh token을 담아서 보냅니다.