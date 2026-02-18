# The Code Whisperer

A Spring Boot + Spring AI demo that gives code snippets a first-person voice. Paste any code, and the AI narrates *as* the code — expressing its fears, dreams, personality, and thoughts about the developer who wrote it.

Two endpoints:
- **`POST /api/whisper`** — streams a Victorian-ghost monologue from the code's perspective (SSE)
- **`POST /api/profile`** — returns a structured JSON personality profile of the code

---

## Tech Stack

| | |
|---|---|
| Java | 21 |
| Spring Boot | 3.4.2 |
| Spring AI | 1.0.0 GA |
| Server | Netty (via WebFlux) |
| AI model | gpt-4o |
| Build | Maven (via wrapper) |

---

## Prerequisites

- Java 21+
- An OpenAI API key

No Maven installation needed — `./mvnw` downloads Maven automatically on first run.

---

## Quick Start

```bash
git clone <repo-url>
cd ledge-demo-springai

export OPENAI_API_KEY=sk-...

./mvnw spring-boot:run
```

Then open **http://localhost:8080** in a browser.

---

## Project Structure

```
ledge-demo-springai/
├── pom.xml
├── mvnw / mvnw.cmd                         ← Maven wrapper
└── src/
    ├── main/
    │   ├── java/com/ledge/codewhisperer/
    │   │   ├── CodeWhispererApplication.java
    │   │   ├── config/
    │   │   │   ├── ChatClientConfig.java       ← ChatClient bean + SimpleLoggerAdvisor
    │   │   │   └── GlobalExceptionHandler.java ← validation + AI error → ProblemDetail
    │   │   ├── controller/
    │   │   │   └── WhisperController.java      ← POST /api/whisper, POST /api/profile
    │   │   ├── model/
    │   │   │   ├── WhisperRequest.java         ← request record (code, language)
    │   │   │   └── CodeProfile.java            ← structured output record
    │   │   └── service/
    │   │       └── WhisperService.java         ← Spring AI logic (streaming + structured)
    │   └── resources/
    │       ├── application.properties
    │       ├── prompts/
    │       │   ├── whisper-system.st           ← Victorian-ghost persona prompt
    │       │   └── profile-system.st           ← code psychologist prompt (JSON schema)
    │       └── static/
    │           └── index.html                  ← dark terminal UI
    └── test/
        └── java/com/ledge/codewhisperer/
            └── CodeWhispererApplicationTests.java
```

---

## API

### `POST /api/whisper`
Streams a first-person narrative from the code's perspective as server-sent events.

**Request**
```json
{
  "code": "function divide(a, b) { return a / b; }",
  "language": "JavaScript"
}
```

**Response** — `text/event-stream`, tokens arrive in real-time
```
data: I
data:  am
data:  the Divider...
```

**curl**
```bash
curl -N -X POST http://localhost:8080/api/whisper \
  -H "Content-Type: application/json" \
  -d '{"code":"function divide(a,b){return a/b;}","language":"JavaScript"}'
```

---

### `POST /api/profile`
Returns a structured JSON personality profile.

**Request** — same shape as `/api/whisper`

**Response** — `application/json`
```json
{
  "codeName": "The Reckless Divider",
  "personalityType": "Chaotic Optimist",
  "currentMood": "blissfully unaware",
  "fears": [
    "b being zero",
    "floating-point imprecision",
    "being called with NaN"
  ],
  "dreams": [
    "a guard clause checking b !== 0",
    "a descriptive parameter name like numerator and denominator",
    "unit tests that actually try the edge cases"
  ],
  "quirks": [
    "returns Infinity without complaint when b is 0",
    "implicitly trusts its caller completely",
    "two lines, zero ceremony"
  ],
  "developerNote": "Wrote this at speed, trusting the happy path — optimistic to a fault."
}
```

**curl**
```bash
curl -X POST http://localhost:8080/api/profile \
  -H "Content-Type: application/json" \
  -d '{"code":"function divide(a,b){return a/b;}","language":"JavaScript"}' \
  | python3 -m json.tool
```

---

## How It Works

### Request flow

```
HTTP POST /api/whisper
        │
        ▼
WhisperController   (@Valid validates request)
        │
        ▼
WhisperService
  ├── loads whisper-system.st from classpath
  ├── builds user message: "Language: JS\n\n```...code...```"
  └── chatClient.prompt()
            .system(...)
            .user(...)
            .stream()
            .content()        ← Flux<String>
        │
        ▼
SSE response (text/event-stream)
```

```
HTTP POST /api/profile
        │
        ▼
WhisperController
        │
        ▼
WhisperService
  ├── loads profile-system.st from classpath
  ├── injects JSON schema via BeanOutputConverter.getFormat()
  │   (replaces {format} placeholder in prompt)
  └── chatClient.prompt()
            .system(...)
            .user(...)
            .call()
            .entity(converter)    ← CodeProfile (deserialized)
        │
        ▼
JSON response
```

### Spring AI features used

| Feature | Where |
|---|---|
| `ChatClient` fluent API | `WhisperService` |
| File-based prompt templates (`.st`) | `prompts/` loaded via `@Value("classpath:...")` |
| System + user prompt separation | `.system()` + `.user()` |
| Streaming via `Flux<String>` | `streamNarrative()` → SSE |
| Structured output | `BeanOutputConverter` + `.entity()` |
| `SimpleLoggerAdvisor` | `ChatClientConfig` — logs prompts/responses at DEBUG |

### Prompt design

**`whisper-system.st`** instructs the model to speak as the code in first person with a Victorian gothic tone, covering: what the code does, its specific fears (grounded in what's actually in the snippet), its dreams for refactoring, and its opinion of the developer. Output is free-form prose, no bullet points.

**`profile-system.st`** instructs the model to act as a clinical code psychologist and return raw JSON only. The `{format}` placeholder is replaced at runtime with the JSON schema derived from `CodeProfile` by `BeanOutputConverter.getFormat()`, so the model knows the exact structure expected.

---

## Configuration

All settings are in `src/main/resources/application.properties`:

```properties
spring.ai.openai.api-key=${OPENAI_API_KEY}
spring.ai.openai.chat.options.model=gpt-4o
spring.ai.openai.chat.options.temperature=0.9
spring.ai.openai.chat.options.max-tokens=1500
logging.level.org.springframework.ai.chat.client.advisor=DEBUG
```

To swap models or tune temperature, edit the properties file. No code changes needed.

---

## Build

```bash
# compile + package (skip tests)
./mvnw clean package -DskipTests

# run tests
./mvnw test

# run
./mvnw spring-boot:run

# or run the fat jar directly
java -jar target/code-whisperer-0.0.1-SNAPSHOT.jar
```

> **Note on Spring AI 1.0.0 artifact name:** The OpenAI starter was renamed from
> `spring-ai-openai-spring-boot-starter` → `spring-ai-starter-model-openai` in the 1.0.0 GA release.
> This project uses the correct 1.0.0 name.
