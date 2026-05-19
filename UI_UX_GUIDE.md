# 소각장 (Burn It) Flutter UI/UX 가이드 (White Theme)

## 1. 테마 및 컬러 팔레트 (Calm & Minimal)
- **Background**: 오프화이트 (`#FAFAFA`) - 눈이 편안하고 따뜻한 흰색 배경.
- **Surface**: 퓨어 화이트 (`#FFFFFF`) - 입력 카드나 팝업 배경 (미세한 그림자 추가).
- **Text (Primary)**: 다크 그레이 (`#333333`) - 가독성 높고 부드러운 검은색.
- **Text (Secondary)**: 미디엄 그레이 (`#888888`) - 날짜나 보조 설명.
- **Accent Colors (Pastel)**: 자극적이지 않은 파스텔톤 적용.
  - 🔥 분노/소각 버튼: 연한 코랄 (`#FF8A65`)
  - 💧 조언 AI: 부드러운 스카이블루 (`#64B5F6`)
  - 🪵 위로 AI: 따뜻한 샌드베이지 (`#D7CCC8`)

## 2. 타이포그래피 (Typography)
- 둥글고 부드러운 느낌의 산세리프 폰트(예: Noto Sans KR, Pretendard) 사용.
- 헤더는 굵지만(Bold) 위협적이지 않게, 본문은 얇고(Regular) 행간(Line-height)을 넓게 주어 여유로운 느낌 강조.

## 3. 인터랙션 및 애니메이션 (Transitions)
- **화면 전환**: Welcome Screen ➡️ Burn Screen 이동 시 부드러운 크로스페이드(Fade) 트랜지션 적용.
- **영수증 진입 동선**: 영수증 보관함 버튼은 Welcome Screen 우측 상단 AppBar 액션으로 배치.
- **소각 효과**: 텍스트가 위로 흩날리며 사라지는(AnimatedOpacity + Positioned) 부드러운 애니메이션.
- **위로 팝업**: 화면 **정중앙**에 카드 형태로 표시되며, **「닫기」** 버튼을 눌러야만 닫히고 Welcome Screen으로 돌아간다.
- **여백 (Whitespace)**: 화면에 요소들을 꽉 채우지 말고, 상하좌우 패딩을 넉넉히(24px 이상) 주어 시각적인 '숨 쉴 틈'을 제공.