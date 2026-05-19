![Screenshot](/screenshot.jpg)

# 소각장 (Burn It) 🔥

**소각장(Burn It)**은 사용자가 평소에 말하지 못했던 거친 감정과 고민들을 가감 없이 쏟아내고 시각적으로 불태워버림으로써 심리적 해방감을 얻을 수 있도록 돕는 프라이버시 중심 감정 쓰레기통 앱입니다.

## ✨ 주요 기능

- **감정 소각 (Burn Screen)**: 속에 담아둔 이야기를 텍스트로 입력하고 '소각하기' 버튼을 눌러 불태워버립니다. 부드러운 애니메이션과 햅틱 피드백을 통해 카타르시스를 제공합니다.
- **AI 페르소나 위로**: 사용자의 감정을 읽고 세 가지 페르소나(🔥 같이 화내기, 💧 현실적 조언, 🪵 따뜻한 위로) 중 하나를 선택해 맞춤형 위로 메시지를 받을 수 있습니다.
- **감정 영수증 (Receipt Cabinet)**: 소각된 감정들은 로컬 기기에 '영수증' 형태로 보관됩니다. 과거의 감정 기록을 확인하거나 영구적으로 삭제할 수 있습니다.
- **프라이버시 중심**: 모든 감정 텍스트는 서버에 저장되지 않고 소각 후 즉시 삭제되며, 영수증 기록은 오직 사용자의 기기에만 저장됩니다.

## 🛠 기술 스택

- **Framework**: Flutter (Dart)
- **Backend**: Supabase (Edge Functions)
- **AI Interface**: Google Gemini API (via Supabase)
- **Local Storage**: Shared Preferences
- **Design Strategy**: Calm & Minimal White Theme

## 🚀 시작하기

### 1. 전제 조건
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (v3.3.0 이상 권장)
- Supabase 프로젝트 생성 및 Gemini API 키 확보

### 2. 환경 변수 설정
프로젝트 루트에 `.env` 파일을 생성하고 아래 내용을 입력합니다 (또는 `.env.example` 복사).

```env
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### 3. 의존성 설치 및 실행
```bash
# 패키지 설치
flutter pub get

# 앱 실행
flutter run
```

## 📸 UI/UX 가이드
본 앱은 사용자에게 편안함을 주기 위해 **White Theme (Calm & Minimal)**을 지향합니다.
- **Background**: 오프화이트 (`#FAFAFA`)
- **Accent**: 파스텔톤 코랄, 스카이블루, 샌드베이지

---
*이 프로젝트는 사용자의 정서적 건강을 위해 제작된 MVP 프로토타입입니다.*
