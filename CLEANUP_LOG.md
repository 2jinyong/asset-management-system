# 작업 로그 — 사내 비품관리시스템 (feature/login-jinyong)

---

## 세션 1: eGov 샘플 코드 제거 (2026-06-30)

**목적:** eGovFramework 샘플 코드를 전부 제거하고 로그인/회원가입 기능만 남기기

### 삭제한 파일

#### Java 소스 (egovframework/example 패키지 전체)
- `EgovSampleExcepHndlr.java`, `EgovSampleOthersExcepHndlr.java`
- `EgovBindingInitializer.java`, `EgovImgPaginationRenderer.java`
- `EgovSampleService.java`, `EgovSampleServiceImpl.java`
- `SampleMapper.java`, `SampleDefaultVO.java`, `SampleVO.java`
- `EgovSampleController.java`

#### SQL/MyBatis 리소스
- `egovframework/sqlmap/example/` 디렉토리 전체
- `db/sampledb.sql`

#### JSP / 이미지 / CSS
- `WEB-INF/jsp/egovframework/example/` 디렉토리 전체
- `images/egovframework/example/` 디렉토리 전체
- `images/egovframework/cmmn/` 디렉토리 전체 (페이징 이미지)
- `css/egovframework/sample.css`

### 새로 생성한 파일
- `egovframework/asset/cmmn/AssetExcepHndlr.java`
- `egovframework/asset/cmmn/AssetOthersExcepHndlr.java`
- `WEB-INF/jsp/egovframework/asset/cmmn/egovError.jsp` 외 에러 JSP 2개

### 수정한 설정 파일

| 파일 | 변경 내용 |
|------|-----------|
| `dispatcher-servlet.xml` | component-scan → `egovframework.asset`, ViewResolver prefix → `asset/`, 샘플 빈 제거 |
| `context-aspect.xml` | AOP pointcut → `asset..impl`, 핸들러 빈 교체 |
| `context-mapper.xml` | MapperConfigurer → `egovframework.asset`, configLocation 경로 수정 |
| `context-idgen.xml` | SAMPLE ID 생성 빈 제거 |
| `validator.xml` | sampleVO 폼 규칙 제거 |
| `index.jsp` | `/egovSampleList.do` → `/user/loginView.do` forward |

---

## 세션 2: 로그인/회원가입 기능 구현 (2026-06-30)

**목적:** 로그인·회원가입 백엔드 완성 + Bootstrap 기반 JSP 작성

### 새로 생성 / 완성한 파일

#### Java 백엔드

| 파일 | 변경 내용 |
|------|-----------|
| `UserVO.java` | DB 컬럼 매핑 필드 전체 + Lombok @Data |
| `UserService.java` | `insertUser()`, `login()` 인터페이스 정의 |
| `UserServiceImpl.java` | 중복 이메일 체크 + 기본값(role/useYn) 설정 + 로그인 비번 검증 |
| `UserMapper.java` | `insertUser()`, `selectUserByEmail()` 인터페이스 |
| `UserMapper.xml` | INSERT / SELECT SQL 작성 (테이블명: `users`) |
| `UserController.java` | loginView/login/registerView/register/main/logout 전체 매핑 |

#### JSP (Bootstrap 5 + jQuery)

| 파일 | 내용 |
|------|------|
| `user/login.jsp` | 로그인 폼, 에러메시지 출력, 자동포커스 |
| `user/register.jsp` | 회원가입 폼, JS 실시간 비번확인, 사원번호 필수 |
| `user/joinResult.jsp` | 가입 완료 화면 |
| `user/main.jsp` | 세션 역할(role) 기반 분기 화면 |

#### 기타

| 파일 | 내용 |
|------|------|
| `db/asset_schema.sql` | users 테이블 CREATE + 관리자 초기 데이터 |
| `STUDY_GUIDE_LOGIN.md` | 학습 가이드 최초 작성 |

### 주요 설계 결정
- **테이블명 `users`**: MySQL 예약어 `user` 충돌 방지
- **세션 역할 분기**: `loginUser.role == 'ADMIN'` → 관리자 화면 / `USER` → 사용자 화면(병합 예정)
- **PRG 패턴**: 로그인 성공 후 `redirect:/user/main.do` → 새로고침 폼 재전송 방지

---

## 세션 3: Spring Validation 백엔드 유효성 검증 추가 (2026-06-30)

**목적:** 프론트엔드 JS 검증만으로는 우회 가능 → 서버측 이중 검증 구조 구축

### 추가한 의존성 (pom.xml)
```xml
<!-- Bean Validation API -->
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
    <version>2.0.1.Final</version>
</dependency>
<!-- Hibernate Validator (구현체) -->
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.2.5.Final</version>
</dependency>
```

### 수정한 파일

#### dispatcher-servlet.xml
- 수동 `RequestMappingHandlerAdapter`/`RequestMappingHandlerMapping` 빈 제거
- `<mvc:annotation-driven/>` 으로 교체 → Bean Validation 자동 활성화
- `<mvc:interceptors>` 로 LocaleChangeInterceptor 구성

#### UserVO.java
| 필드 | 추가된 어노테이션 |
|------|-----------------|
| `userName` | `@NotBlank(message = "이름을 입력해주세요.")` |
| `email` | `@NotBlank` + `@Email(message = "올바른 이메일 형식이 아닙니다.")` |
| `password` | `@NotBlank` + `@Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")` |
| `employeeNumber` | `@NotBlank(message = "사원번호를 입력해주세요.")` |

#### UserController.java
- `register()` 메서드: `@Valid` + `BindingResult` 파라미터 추가
- `login()` 메서드: 수동 빈값 체크 추가 (`@Valid` 미사용 - 이유: 로그인 폼은 일부 필드만 전송)

#### register.jsp
- 각 입력 필드 아래 `<form:errors path="필드명">` 태그 추가
- 백엔드 검증 실패 시 Spring이 자동으로 오류 메시지 출력

### 유효성 검증 이중 구조
```
사용자 입력
    │
    ├─ [1단계] 프론트엔드 (JS / register.jsp)
    │     - 즉각 피드백 (UX 향상)
    │     - JS 비활성화나 직접 HTTP 요청으로 우회 가능 → 신뢰 불가
    │
    └─ [2단계] 백엔드 (Spring Validation / UserVO @NotBlank 등)
          - 서버에서 직접 검증 → 우회 불가
          - @Valid + BindingResult + form:errors 로 동작
          - 실제 보안/데이터 무결성을 담당
```

---

## 현재 프로젝트 구조 (세션 3 완료 후)

```
src/main/java/egovframework/asset/
├── cmmn/
│   ├── AssetExcepHndlr.java
│   └── AssetOthersExcepHndlr.java
└── user/
    ├── service/
    │   ├── UserVO.java             ← @NotBlank/@Email/@Size 어노테이션 포함
    │   ├── UserService.java
    │   ├── UserMapper.java
    │   └── impl/UserServiceImpl.java
    └── web/
        └── UserController.java    ← register에 @Valid + BindingResult

src/main/resources/
├── db/
│   ├── db.properties              ← DB 접속 정보
│   └── asset_schema.sql           ← users 테이블 CREATE SQL
└── egovframework/
    ├── mapper/asset/UserMapper.xml
    ├── sqlmap/asset/mappers/sql-mapper-config.xml
    └── spring/context-*.xml

src/main/webapp/
├── index.jsp                      → /user/loginView.do forward
├── WEB-INF/
│   ├── web.xml
│   ├── config/egovframework/springmvc/dispatcher-servlet.xml  ← mvc:annotation-driven 추가
│   └── jsp/egovframework/asset/user/
│       ├── login.jsp
│       ├── register.jsp           ← form:errors 태그 추가
│       ├── joinResult.jsp
│       └── main.jsp               ← role 기반 분기 (ADMIN/USER)
├── js/jquery.min.js
└── css/egovframework/bootstrap/
```

---

## 세션 4: main.jsp 삭제 + 구조 정리 (2026-06-30)

### 삭제한 파일
- `WEB-INF/jsp/egovframework/asset/user/main.jsp`
  - **이유**: 팀원(형)이 사용자 메인 화면을 별도 브랜치에서 이미 작성했음
  - GitHub 병합 시 팀원의 `main.jsp` 가 추가될 예정
  - `UserController.main()` 의 `return "user/main"` 은 그대로 유지
    → 병합 후 팀원의 `main.jsp` 로 자동 연결됨

### 확인 사항
- `images/egovframework/asset/` 하위 이미지 파일 → Bootstrap 사용으로 불필요, 삭제 가능
- Bootstrap CSS/JS, jQuery 는 정상 위치에 존재

---

## 다음 작업 예정
- 관리자 기능 개발 (비품 관리, 사용자 관리, 신청 관리)
- 형(팀원) 브랜치의 사용자 메인 페이지와 main.jsp 병합
- 세션 인증 인터셉터 추가 (로그인 없이 /user/main.do 직접 접근 차단)
