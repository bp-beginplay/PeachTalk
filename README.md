# PeachTalk

피치파이브 재직 중 참여한 AI 챗 앱 개발 프로젝트입니다.
가상의 아이돌 그룹 '피치걸스' 멤버들과 대화하는 캐릭터 챗 앱으로, Flutter와 LangChain으로 OpenAI 대화형 모델을 호출합니다.

- 기간: 2026.08 ~ 2026.09 (피치파이브 재직 중)
- 언어·프레임워크: Dart, Flutter
- LLM: OpenAI Chat Completions API, LangChain.dart (`langchain`, `langchain_openai`)
- 플랫폼: Windows, Android, iOS, Web

## 화면 흐름

1. **스플래시**: 로고와 로딩 진행 막대
2. **캐릭터 선택**: 피치걸스 멤버 3명(아야, 코미, 니아) 중 선택
3. **채팅**: 시간대별 배경 위에 캐릭터 초상화, 아래 패널에서 대화

## 기술 구조

| 계층 | 위치 | 역할 |
|---|---|---|
| 화면 | `lib/screens/` | 스플래시, 캐릭터 선택, 채팅 |
| 서비스 | `lib/services/` | LLM 호출(`chat_service.dart`), 시간대별 배경 계산, JSON 에셋 로딩·캐시 |
| 모델 | `lib/models/` | 캐릭터 설정, 그룹 설정, 대화 한 턴 |
| 데이터 | `assets/data/`, `assets/images/` | 화면 문구·색상, 캐릭터 설정, 배경 일정표, 이미지 |

LLM 관련 코드는 `lib/services/chat_service.dart` 한 파일에 모여 있고, 화면은 LangChain을 직접 다루지 않습니다.

### 메시지 처리 순서

1. 캐릭터 설정 JSON과 그룹 설정으로 시스템 프롬프트를 조립
2. 시스템 프롬프트, 이전 대화(사용자·AI 역할 구분), 새 입력을 메시지 목록으로 구성
3. LangChain의 `ChatOpenAI`로 모델 호출
4. 응답 끝의 `[emotion: …]` 태그를 정규식으로 분리하고 허용값(neutral, happy, sad, angry, surprised)인지 검증, 아니면 `neutral`로 처리
5. 대사를 말풍선으로 추가하고 감정에 맞는 캐릭터 이미지로 전환

### 주요 기능

- **감정 연동 초상화**: 모델이 응답에 표시한 감정에 따라 캐릭터 이미지를 바꾸고, 해당 이미지가 없으면 기본 이미지로 대체
- **시간대별 배경**: 요일·시각별 일정표(`assets/data/background_schedule.json`)로 배경을 고르고 30초마다 다시 계산
- **대화 검색**: 검색어가 든 메시지를 이전·다음으로 이동하며 해당 말풍선으로 스크롤
- **데이터 주도 UI**: 화면 문구·색상·이미지 경로를 JSON 에셋으로 분리해 코드 수정 없이 편집

### 범위

- 이미 학습된 모델을 API로 호출하는 응용 개발입니다. 모델 학습·미세조정, 외부 문서 검색(RAG), 데이터베이스 연동은 포함하지 않습니다.
- 대화 기록은 앱이 켜져 있는 동안만 메모리에 보관합니다.

## 실행 방법

API 키는 코드에 넣지 않고, 실행할 때 `OPENAI_API_KEY` 환경 변수 값을 `--dart-define`으로 전달합니다.
(모바일 앱은 PC의 환경 변수를 직접 읽을 수 없어서, `--dart-define`이 데스크톱과 모바일 모두에서 동작하는 방법입니다.)

```bash
# PowerShell
flutter run -d windows --dart-define=OPENAI_API_KEY=$env:OPENAI_API_KEY

# bash
flutter run -d windows --dart-define=OPENAI_API_KEY="$OPENAI_API_KEY"
```

에뮬레이터나 실기기에서는 `-d <device-id>`만 바꾸고, 빌드(`flutter build ...`)할 때도 같은 `--dart-define`을 붙입니다.
`OPENAI_API_KEY`가 비어 있으면 채팅 화면에 안내 문구가 뜨고 전송이 비활성화됩니다.

> `--dart-define` 값은 빌드된 앱 안에 포함됩니다. 배포용으로는 키를 서버에 두고 중계하는 구조가 필요합니다.

## 테스트

```bash
flutter test
```

캐릭터 선택 화면과 채팅 사이드바 동작에 대한 위젯 테스트가 있습니다.
