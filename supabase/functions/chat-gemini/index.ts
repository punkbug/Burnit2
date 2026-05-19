import "jsr:@supabase/functions-js/edge-runtime.d.ts"

// CORS: Chrome(Web)에서도 Edge Function 호출을 허용
const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, accept, accept-language",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Max-Age": "86400",
}

const functionBuild = "chat-gemini@2026-04-07-3"

Deno.serve(async (req) => {
  // 1. CORS Preflight 요청 처리 (브라우저가 먼저 보내는 OPTIONS)
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: { ...corsHeaders, "X-Function-Build": functionBuild },
    })
  }

  try {
    // 2. Flutter 앱에서 보낸 JSON 데이터 읽기
    const body = await req.json().catch(() => ({}))
    const message = typeof body?.message === "string" ? body.message : ""
    const systemInstruction =
      typeof body?.systemInstruction === "string" ? body.systemInstruction : ""
    if (!message.trim()) {
      return new Response(JSON.stringify({ error: "message is required", build: functionBuild }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          "X-Function-Build": functionBuild,
        },
        status: 422,
      })
    }

    // 3. Supabase 금고에서 구글 Gemini API 키 꺼내기
    const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')
    if (!GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY is not set in edge function")
    }

    // 4. 구글 서버(Gemini API)로 직접 요청 보내기
    const GEMINI_MODEL = "gemini-1.5-flash" 
    const url =
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`
    
    // 시스템 프롬프트 강화: JSON 응답 강제 및 구조 정의
    const jsonInstruction = `
응답은 반드시 아래의 JSON 형식으로만 반환해야 해. 다른 텍스트는 포함하지 마.
{
  "arousal": 0~100 (각성도: 흥분, 분노, 패닉이 높을수록 100, 차분/무기력하면 0),
  "valence": 0~100 (감정가: 평온/긍정적이면 100, 우울/부정적이면 0),
  "complexity": 0~100 (복잡도: 감정이 혼재되고 표현이 거칠수록 100),
  "emotion_summary": "현재 감정을 10자 이내의 명사형으로 요약",
  "comfort_message": "선택한 페르소나에 맞춘 위로 메시지 (3~4문장)"
}
`;

    const payload: Record<string, unknown> = {
      contents: [
        {
          parts: [{ text: message }],
        },
      ],
      generationConfig: {
        response_mime_type: "application/json",
      },
    }
    
    const finalSystemInstruction = (systemInstruction.trim() ? systemInstruction + "\n" : "") + jsonInstruction;
    payload.systemInstruction = {
      parts: [{ text: finalSystemInstruction }],
    }

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    })

    const geminiData = await response.json()
    if (!response.ok) {
      throw new Error(`Gemini API error (${response.status}): ${JSON.stringify(geminiData)}`)
    }

    // 5. 구글에서 준 답변 중 텍스트(JSON 문자열)만 뽑아내기
    let replyText = ""
    const candidates = (geminiData as Record<string, unknown> | null)?.candidates
    if (Array.isArray(candidates) && candidates.length > 0) {
      const content = (candidates[0] as Record<string, unknown> | null)?.content
      const parts = (content as Record<string, unknown> | null)?.parts
      if (Array.isArray(parts) && parts.length > 0) {
        replyText = (parts[0] as Record<string, unknown> | null)?.text || ""
      }
    }

    if (!replyText.trim()) {
      throw new Error(
        `Gemini 응답에서 reply 텍스트를 찾을 수 없습니다: ${JSON.stringify(geminiData)}`,
      )
    }

    // JSON 파싱 및 필드 보완 로직
    try {
      const parsed = JSON.parse(replyText)
      // AI가 키 이름을 잘못 생성했을 경우를 대비한 매핑
      const arousal = parsed.arousal ?? 50
      const valence = parsed.valence ?? 50
      const complexity = parsed.complexity ?? 30
      const emotion_summary = parsed.emotion_summary ?? "감정 기록"
      const comfort_message = parsed.comfort_message ?? parsed.reply ?? parsed.text ?? ""

      return new Response(
        JSON.stringify({ 
          arousal,
          valence,
          complexity,
          emotion_summary, 
          comfort_message,
          build: functionBuild 
        }),
        { 
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
            "X-Function-Build": functionBuild,
          },
          status: 200 
        }
      )
    } catch (e) {
      throw new Error(`AI 응답이 올바른 JSON 형식이 아닙니다: ${replyText}`)
    }

  } catch (error) {
    const message =
      error instanceof Error ? error.message : typeof error === "string" ? error : JSON.stringify(error)
    return new Response(
      JSON.stringify({ error: message, build: functionBuild }),
      { 
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          "X-Function-Build": functionBuild,
        },
        status: 400 
      }
    )
  }
})
