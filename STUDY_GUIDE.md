# 사내 비품관리시스템 — 2일 완성 학습 가이드

> **이 문서의 목적**: 큰 그림과 파일 간 연결고리를 잡아주는 것.
> 각 파일 안에는 이미 상세한 한글 주석이 달려 있으니, 세세한 설명은 코드 주석에서 확인하고
> 이 문서는 "왜 이렇게 짜여 있는가 / 무엇이 무엇을 부르는가"에 집중한다.
> **막히는 부분은 표시해뒀다가 따로 질문하면서 채워나갈 것.**

---

## 학습 로드맵

| | 목표 | 분량 |
|---|---|---|
| **1일차** | Spring/eGov 프레임워크 구조를 이해한다 (왜 이렇게 짰는가) | 1~8장 |
| **2일차** | 이 프로젝트의 실제 기능 흐름을 코드로 추적한다 (무엇이 무엇을 부르는가) | 9~17장 |

---

# 1일차 — 프레임워크 구조

## 1. 전체 그림 한 장

```
브라우저
   │  GET/POST *.do
   ▼
[Filter]  인코딩 처리, XSS 방어           ← web.xml
   ▼
[DispatcherServlet]  요청을 받는 관문      ← Spring MVC 시작점
   ▼
[Interceptor]  언어 변경, 로그인/관리자 권한 체크   ← dispatcher-servlet.xml
   ▼
[Controller]  URL ↔ 메서드 매핑
   ▼
[Service]  비즈니스 로직 (+ AOP 예외처리 자동 적용)
   ▼
[Mapper + XML]  SQL 실행 (MyBatis)
   ▼
[DB] users, EQUIPMENT 테이블
   ▲
[View]  return "뷰이름" → ViewResolver → JSP 렌더링
```

이 프로젝트는 **Controller → Service → Mapper → DB** 4계층 구조를 항상 지킨다.
컨트롤러가 Mapper를 직접 부르는 코드는 없다 — 이 규칙만 기억해도 코드 읽기가 쉬워진다.

---

## 2. IoC / DI / Bean — 왜 `new`를 안 쓰는가

```java
// ❌ 직접 생성 (제어권이 개발자에게 있음)
UserService svc = new UserServiceImpl();

// ✅ 이 프로젝트 방식 — Spring이 만들어서 넣어준다
@Resource(name = "userService")
private UserService userService;
```

- **Bean** = Spring이 생성·관리하는 객체
- **IoC(제어의 역전)** = 객체를 누가 만드는지의 주도권이 개발자 → Spring 컨테이너로 넘어감
- **DI(의존성 주입)** = 필요한 객체를 Spring이 필드/생성자에 넣어주는 방식

**Bean이 등록되는 2가지 방법 — 프로젝트에 둘 다 있음:**

```java
@Service("userService")   // 어노테이션 스캔 (user 모듈)
public class UserServiceImpl { ... }
```
```java
public class EquipmentController {   // 생성자 주입 (equipment 모듈, 최근 스타일)
    private final EquipmentService equipmentService;
    public EquipmentController(EquipmentService equipmentService) {
        this.equipmentService = equipmentService;
    }
}
```
→ `@Resource` 필드 주입과 생성자 주입이 섞여 있다. 기능은 같고, 생성자 주입이 최신 Spring 권장 방식.

| 어노테이션 | 계층 | 뜻 |
|---|---|---|
| `@Controller` | Presentation | HTTP 요청 처리 |
| `@Service` | Business | 비즈니스 로직 |
| `@Mapper`(eGov) | Persistence | SQL 실행 인터페이스 |

---

## 3. 두 개의 Spring 컨텍스트

이 프로젝트는 컨텍스트가 **Root(부모) / Servlet(자식)** 둘로 나뉜다. 헷갈리면 여기로 돌아올 것.

```
Root Context (ContextLoaderListener, context-*.xml)
  └ @Service, @Mapper, dataSource, txManager 등록
        │  (자식이 부모를 참조 가능, 반대는 불가)
        ▼
Servlet Context (DispatcherServlet, dispatcher-servlet.xml)
  └ @Controller, ViewResolver 등록
```

**왜 나누나?** Service/Mapper는 앱 전체가 공유하는 비즈니스 로직이라 Root에 두고,
Controller는 "웹 요청 처리 전용"이라 Servlet Context에 따로 둔다.
→ Controller는 Service를 주입받을 수 있지만, Service가 Controller를 주입받을 순 없다.

---

## 4. 설정 파일 지도

한 줄씩만 기억하면 된다. 실제 세부 설정은 파일 열어서 확인.

| 파일 | 역할 |
|---|---|
| `web.xml` | Filter 등록, DispatcherServlet 등록 → 두 컨텍스트의 시작점 |
| `dispatcher-servlet.xml` | `@Controller` 스캔, ViewResolver(뷰이름→JSP경로 변환), 인터셉터 |
| `context-common.xml` | `@Service`/`@Mapper` 스캔(Controller 제외), 다국어 MessageSource |
| `context-datasource.xml` | DB 커넥션 풀(BasicDataSource) |
| `context-mapper.xml` | MyBatis SqlSessionFactory, `@Mapper` 스캔 |
| `context-aspect.xml` | AOP 예외 처리 |
| `context-transaction.xml` | 트랜잭션 설정 — ⚠**버그 있음, 16장 참고** |

**ViewResolver 변환 공식** (자주 나오니 외워둘 것):
```
return "user/login"
  → prefix("/WEB-INF/jsp/egovframework/asset/") + "user/login" + suffix(".jsp")
  → /WEB-INF/jsp/egovframework/asset/user/login.jsp
```

---

## 5. AOP — 예외 처리를 한 곳에 몰아넣는 이유

**AOP 없이 매 메서드마다 try-catch를 반복하는 대신**, `*Impl` 로 끝나는 클래스의 모든 메서드를
Spring이 감시하다가 예외가 터지면 자동으로 처리해준다.

```
UserServiceImpl.insertUser() 에서 예외 발생
        │ (Spring이 만든 Proxy가 가로챔)
        ▼
ExceptionTransfer.transfer(exception, 패키지명)
        │ (패키지명이 **service.impl.* 패턴과 매칭되는지 확인)
        ▼
AssetExcepHndlr.occur() → 로그만 찍음 (지금은)
        │
        ▼
예외가 다시 위로 전파됨 (AOP는 예외를 삼키지 않는다)
        ▼
SimpleMappingExceptionResolver → cmmn/egovError.jsp 렌더링
```

핵심 용어 4개만: **Pointcut**(어디에 적용할지 표현식) → **Advice**(무엇을 실행할지) →
**Aspect**(Pointcut+Advice 묶음) → **Weaving**(런타임에 실제로 Proxy를 씌우는 과정).

```
execution(* egovframework.asset..impl.*Impl.*(..))
→ asset 패키지 하위 어디든, 이름이 Impl로 끝나는 클래스의, 모든 메서드
```

**이게 왜 되냐면**: `UserServiceImpl`이 `EgovAbstractServiceImpl`을 상속하기 때문.
이 상속 하나로 AOP 예외처리 + eGov 추적로그(LeaveaTrace)에 자동으로 편입된다.

---

## 6. MyBatis 핵심 3가지

**① `#{}` vs `${}` — 보안상 반드시 구분**
```sql
WHERE email = #{email}      -- PreparedStatement 방식, SQL Injection 안전 (항상 이걸 쓸 것)
WHERE email = '${email}'    -- 문자열 직접 치환, ' OR '1'='1 같은 공격에 취약
```

**② 자동 이름 변환** — `sql-mapper-config.xml`의 `mapUnderscoreToCamelCase=true` 덕분에
DB의 `user_name` ↔ Java의 `userName`이 resultMap 없이 자동 매핑된다.

**③ 연결 체인** — 이름이 정확히 일치해야 연결된다:
```
UserMapper.java 의 insertUser()
   ↕ id 속성이 일치해야 함
UserMapper.xml 의 <insert id="insertUser">
   ↕ namespace가 인터페이스 풀패키지경로와 일치해야 함
"egovframework.asset.user.service.UserMapper"
```
→ 여기서 오타 나면 `Invalid bound statement` 에러가 뜬다.

**동적 SQL** (equipment_SQL.xml에서 실제 사용 중):
```xml
<where>
    <if test="category != null and category != ''">
        AND category = #{category}
    </if>
</where>
```
category 파라미터가 없으면 `WHERE`절 자체가 안 생김 → 전체 조회.

---

## 7. Filter vs Interceptor

| | Filter | Interceptor |
|---|---|---|
| 위치 | 서블릿 컨테이너(Tomcat) 레벨, Spring 밖 | Spring MVC 안쪽 |
| 설정 | `web.xml` | `dispatcher-servlet.xml` |
| Spring Bean 접근 | 불가능 | 가능 (세션의 `UserVO` 같은 도메인 객체를 자유롭게 다룸) |
| 이 프로젝트 | `CharacterEncodingFilter`(UTF-8), `HTMLTagFilter`(XSS 방어) | `LocaleChangeInterceptor`, `LoginCheckInterceptor`, `AdminCheckInterceptor` |

**로그인/권한 체크는 Interceptor로 처리한다.** 처음엔 컨트롤러 메서드마다
`session.getAttribute("loginUser") == null` 체크를 직접 넣었는데(같은 코드가 12곳 이상 반복),
이건 "여러 컨트롤러에 공통으로 필요한 부가 로직"이라 AOP나 Interceptor로 뽑아내기 딱 좋은 사례다.
지금은 `LoginCheckInterceptor`/`AdminCheckInterceptor` 두 개로 분리해서 컨트롤러에는
비즈니스 로직만 남아 있다 — 자세한 동작은 10장 참고. Interceptor는 eGov가 만든 개념이 아니라
Spring MVC 표준 기능이고, 이 프로젝트는 그걸 그대로 가져다 쓴 것이다.

---

## 8. eGov 특유 개념 — 순수 Spring과 다른 점

| 항목 | 순수 Spring | 이 프로젝트(eGov) |
|---|---|---|
| Mapper 어노테이션 | `org.apache.ibatis.annotations.Mapper` | `org.egovframe.rte.psl.dataaccess.mapper.Mapper` |
| Mapper 등록 | `@MapperScan` | `MapperConfigurer` 빈 |
| Service 부모클래스 | 없음 | `EgovAbstractServiceImpl` 상속 |
| 예외 처리 | `@ControllerAdvice` 등 | AOP(`context-aspect.xml`) 자동 처리 |

이름이 같은 `@Mapper`가 패키지만 다르게 두 종류 있으니 import문에서 헷갈리지 말 것.

---

# 2일차 — 실전 코드 추적

## 9. 이 프로젝트의 핵심 도메인: 사용자 상태 4단계

`users.use_yn` 컬럼 하나가 계정의 상태를 전부 결정한다. **이걸 이해하면 회원가입/승인/로그인/탈퇴가 전부 이해된다.**

```
      회원가입              관리자 승인
  ┌────────────┐  P   ┌────────────┐  Y   (로그인 가능)
  │   (없음)   │ ───▶ │  승인대기   │ ───▶ 활성
  └────────────┘      └─────┬──────┘
                             │  관리자 반려
                             ▼  R
                          가입반려

  활성(Y) 계정이 ──── 본인 탈퇴 ────▶  N  탈퇴
```

| 값 | 의미 | 로그인 가능? | 같은 이메일 재가입 가능? |
|---|---|---|---|
| `P` | 승인대기 | ❌ | ❌ (막힘) |
| `Y` | 활성 | ✅ | — |
| `R` | 가입반려 | ❌ | ✅ (재가입 허용) |
| `N` | 탈퇴 | ❌ | ✅ (재가입 허용) |

이 상태값 하나 때문에 `UserMapper.xml`에 조회 쿼리가 3개나 있다 — **왜 3개인지가 핵심**:

| 메서드 | WHERE 조건 | 용도 |
|---|---|---|
| `selectUserByEmail` | `use_yn='Y'` | 로그인 — 활성 계정만 통과시킴 |
| `selectUserByEmailAny` | `use_yn IN ('Y','P')` | 회원가입 중복체크 — 대기중/활성만 막고, R/N은 재가입 허용 |
| `selectUserByEmailAllStatus` | 상태 무관 전체 | 로그인 실패 시 "왜" 실패했는지 원인 메시지 표시용 |

---

## 10. 로그인/권한 체크 — Interceptor로 리팩터링

**Before**: 로그인 여부를 확인하는 코드가 `UserController`, `EquipmentController`에
아래 형태로 12곳 넘게 그대로 복사돼 있었다.
```java
UserVO loginUser = (UserVO) session.getAttribute("loginUser");
if (loginUser == null) { return "redirect:/user/loginView.do"; }
```
관리자 전용 화면(`pendingList.do`, `approve.do`, `reject.do`, `approveList.do`)은
여기에 `!"ADMIN".equals(loginUser.getRole())` 체크까지 덧붙어 더 길었다.

**After**: `egovframework.asset.cmmn` 패키지에 `HandlerInterceptor`를 구현한
인터셉터 2개를 만들고, `dispatcher-servlet.xml`에 어떤 경로에 적용할지만 등록했다.

```
LoginCheckInterceptor.preHandle()
  세션에 loginUser 없음 → response.sendRedirect(로그인 화면) + return false (컨트롤러 호출 자체가 막힘)
  있음                  → return true (다음 단계로 통과)

AdminCheckInterceptor.preHandle()
  role != "ADMIN"  → response.sendRedirect("/main.do") + return false
  role == "ADMIN"  → return true
```

```xml
<!-- dispatcher-servlet.xml -->
<mvc:interceptors>
    <mvc:interceptor>                              <!-- 로그인 체크: 로그인/가입 화면만 제외하고 전부 적용 -->
        <mvc:mapping path="/**"/>
        <mvc:exclude-mapping path="/user/loginView.do"/>
        <mvc:exclude-mapping path="/user/login.do"/>
        <mvc:exclude-mapping path="/user/registerView.do"/>
        <mvc:exclude-mapping path="/user/register.do"/>
        <bean class="egovframework.asset.cmmn.LoginCheckInterceptor"/>
    </mvc:interceptor>
    <mvc:interceptor>                              <!-- 관리자 체크: 관리자 전용 경로만 지정 -->
        <mvc:mapping path="/user/pendingList.do"/>
        <mvc:mapping path="/user/approve.do"/>
        <mvc:mapping path="/user/reject.do"/>
        <mvc:mapping path="/approveList.do"/>
        <bean class="egovframework.asset.cmmn.AdminCheckInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```

**등록 순서가 중요하다.** `<mvc:interceptors>`에 나열된 순서대로 `preHandle()`이 실행되므로,
로그인 체크가 관리자 체크보다 먼저 와야 한다. 그래야 `AdminCheckInterceptor`가 role을 확인하는
시점엔 "로그인은 이미 되어 있다"고 가정할 수 있다.

**결과**: 컨트롤러 메서드에서 세션 null 체크가 전부 사라졌다.
`EquipmentController`는 `HttpSession`/`UserVO` import 자체가 필요 없어졌고,
`UserController`의 `pendingList()`/`approve()`/`reject()`는 원래 로직(각각 3~5줄)만 남았다.
단, `withdraw()`의 "ADMIN은 탈퇴 불가" 체크는 **인증이 아니라 업무 규칙**이라 컨트롤러에 그대로 남겨뒀다
— 로그인 여부/권한처럼 "여러 화면에 공통으로 적용되는 게이트"만 인터셉터로 뽑는 것이 기준이다.

> ⚠ **인터셉터를 추가할 때 흔한 실수**: 새 공개 페이지(로그인 필요 없는 화면)를 만들고
> `dispatcher-servlet.xml`의 `exclude-mapping`에 추가하는 걸 깜빡하면, 그 페이지 자체가
> 로그인 화면으로 무한 리다이렉트된다. 반대로 새 관리자 화면을 만들고 `AdminCheckInterceptor`의
> `mvc:mapping`에 경로를 안 넣으면 일반 사용자도 접근할 수 있게 된다 — 두 실수 모두 눈에 잘 안 띄니 주의.

---

## 11. 회원가입 → 승인 → 로그인 흐름 (Step-by-Step)

```
[회원가입]
GET  /user/registerView.do  → register.jsp

POST /user/register.do
  UserController.register()
    @Valid 검증 (이름/이메일형식/비번8자↑/사원번호 필수)
      실패 → register.jsp 로 되돌아가며 <form:errors> 출력
    ↓ 성공
  UserServiceImpl.insertUser()
    1. selectUserByEmailAny(email) → Y/P 상태로 이미 있으면 return 0 (중복)
    2. role="USER", use_yn="P" 로 강제 설정   ← 가입 즉시 활성화 안 됨!
    3. userMapper.insertUser() → INSERT
  ↓
  결과 1 → joinResult.jsp ("가입 승인 대기중" 안내)
  결과 0 → register.jsp (에러: 이미 사용중인 이메일)

[관리자 승인]  (13장에서 자세히)
관리자가 /user/pendingList.do 화면에서 승인 버튼 클릭
  → POST /user/approve.do → use_yn: P → Y

[로그인]
POST /user/login.do
  UserController.login()
    email/password 빈값 수동 체크 (⚠ @Valid 안 씀 — 아래 이유 참고)
    ↓
  UserServiceImpl.login()
    selectUserByEmail(email)  ← use_yn='Y' 인 계정만 조회됨
    비밀번호 불일치 or 계정 없음(P/R/N 상태 포함) → null
    ↓
  성공 → session.setAttribute("loginUser", loginUser)
        → redirect:/main.do          ← ⚠ /user/main.do 아님, EquipmentController가 처리 (14장)
  실패 → findByEmailAnyStatus(email)로 상태 재조회 후
        P → "승인 중입니다"  /  R → "반려되었습니다"  /  N → "탈퇴한 계정입니다"
        /  없음 → "이메일 또는 비밀번호가 올바르지 않습니다"
        → login.jsp 에러 메시지 표시
```

**로그인에 `@Valid`를 안 쓰는 이유**: `UserVO`의 `@NotBlank`가 `userName`, `employeeNumber`에도
붙어있는데 로그인 폼은 email+password만 보내므로, `@Valid`를 걸면 항상 검증 실패한다.
그래서 컨트롤러에서 email/password만 수동으로 빈값 체크한다.

**`redirect:` vs 그냥 뷰이름 반환** — 로그인 성공 후 `redirect:`를 쓰는 이유:
```
return "user/main"              → Forward, URL 안 바뀜, 새로고침하면 폼 재전송 경고
return "redirect:/main.do"      → 302 응답, 브라우저가 새로 GET 요청, 새로고침 안전 (PRG 패턴)
```

---

## 12. 탈퇴 흐름

```
POST /user/withdraw.do
  UserController.withdraw()
    세션 없음 → 로그인 페이지로
    ADMIN 이면 → 탈퇴 거부, /main.do 로 돌려보냄  (관리자 탈퇴 방지)
    ↓
  userService.withdrawUser(userId) → UPDATE users SET use_yn='N' WHERE use_yn='Y'
  session.invalidate()
  → 로그인 페이지
```
탈퇴는 실제 DELETE가 아니라 `use_yn='N'` 마킹(소프트 삭제)이다. 기록은 DB에 남는다.

---

## 13. 관리자 승인 화면 흐름

```
GET  /user/pendingList.do
  (LoginCheckInterceptor → AdminCheckInterceptor 통과해야 컨트롤러 도달, ADMIN 아니면 /main.do 로 튕겨냄)
  userService.getPendingUserList() → use_yn='P' 목록, 신청일 오름차순
  → /board/ApproveUserList.jsp

ApproveUserList.jsp:
  각 행마다 승인/반려 버튼 → 별도 <form> 으로 즉시 POST
  (confirm() 으로 실수 클릭 방지)

POST /user/approve.do?userId=n  →  updateUserApprove: P→Y 로 변경 (P 상태일 때만)
POST /user/reject.do?userId=n   →  updateUserReject : P→R 로 변경 (P 상태일 때만)
  둘 다 처리 후 pendingList.do 로 다시 리다이렉트 (새로고침해도 안전)
```
`WHERE user_id=#{userId} AND use_yn='P'` 조건이 있어서, 이미 처리된 요청을 중복 클릭해도
두 번째 클릭은 아무 일도 안 일어난다 (0 rows affected) — 방어적으로 잘 짜여 있다.

---

## 14. 비품(EQUIPMENT) 목록 + 페이징 흐름

user 모듈과 구조가 다르다: **생성자 주입**, **Map 파라미터로 동적 조건 전달**, **자체 페이징 클래스**.

```
GET /main.do
  (LoginCheckInterceptor 통과해야 컨트롤러 도달, 미로그인 → 로그인 페이지)
  EquipmentController.mainPage()
    equipmentService.getCategorySummary()
      → SQL: category별 GROUP BY, 전체/대여가능/대여중/신고 건수 집계
    → /board/TestUI.jsp (대시보드, 카테고리별 카드)

GET /equipmentList.do?category=노트북&page=2
  EquipmentController.equipmentList()
    1. EquipmentPaging 생성: page=2, perPageNum=15
    2. params = { category, pageSize=15, offset=(2-1)*15=15 }
    3. equipmentService.getEquipmentList(params)
         → SQL: WHERE category=? ORDER BY equipment_id LIMIT 15 OFFSET 15
    4. equipmentService.getEquipmentCount(params) → 전체 건수 (페이지 계산용)
    5. PageMaker.setTotalCount() → 시작페이지/끝페이지/이전유무/다음유무 자동 계산
    → /board/EquipmentList.jsp
```

**페이징 계산 원리** (`PageMaker.calcData()`):
```
displayPageNum = 5   // 한 번에 보여줄 페이지 번호 개수 (1~5, 6~10 ...)

endPage   = ceil(현재page / 5) * 5          // 현재 블록의 끝 번호
startPage = endPage - 5 + 1                  // 현재 블록의 시작 번호
totalPage = ceil(전체건수 / 페이지당개수)     // 실제 마지막 페이지로 endPage 보정
prev = (startPage != 1)                      // "이전" 버튼 표시 여부
next = (endPage * perPageNum < totalCount)   // "다음" 버튼 표시 여부
```
예: 현재 7페이지, 전체 8페이지 → startPage=6, endPage=8(10에서 보정됨), prev=true, next=false
→ 화면엔 `6 7 8` 번호와 "이전" 버튼만 보임.

JSP 쪽 핵심 한 줄 (`EquipmentList.jsp`):
```jsp
<c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
    <a href="equipmentList.do?category=${category}&page=${idx}">${idx}</a>
</c:forEach>
```

> ⚠ **아직 미완성인 부분**: `/approveList.do`(대여/연장/신고 승인 화면)는 실제 DB 대신
> `EquipmentController.buildDummyApprovalList()`가 만든 **더미 데이터**를 보여준다.
> RENTAL/REPORT 테이블과 연동되면 이 부분을 실제 Service 조회로 교체해야 한다 (코드 주석에도 TODO로 표시됨).

---

## 15. 헷갈리기 쉬운 것 — `/main.do`는 어디서 처리되는가

`UserController`에도 `main()` 메서드가 `/user/main.do`로 남아있지만, **실제 로그인 성공 후 이동하는 곳은
`/main.do`(슬래시로 시작, `/user/`가 없음)이고 이건 `EquipmentController.mainPage()`가 처리한다.**
`/user/main.do`는 현재 어디서도 호출되지 않는 사실상 죽은 코드다. 헷갈리면 URL의 `/user/` 유무를 확인할 것.

---

## 16. 알려진 이슈 (질문거리로 남겨두기 좋은 것들)

1. **`context-transaction.xml`의 pointcut이 이 프로젝트를 가리키지 않는다**
   ```xml
   <!-- 현재: 존재하지 않는 패키지를 가리켜서 트랜잭션이 실제로 안 걸림 -->
   <aop:pointcut id="requiredTx"
       expression="execution(* egovframework.example.sample..impl.*Impl.*(..))"/>
   <!-- 맞는 값: egovframework.asset..impl.*Impl.*(..) -->
   ```
   지금은 단순 INSERT/UPDATE 한 번짜리 로직이라 문제가 드러나지 않지만, "여러 테이블에 걸친
   작업"(예: 대여 처리 시 EQUIPMENT 상태 변경 + RENTAL 기록 INSERT를 함께)이 생기면 반드시 고쳐야 한다.

2. ~~비밀번호 평문 저장/비교~~ — `BCryptPasswordEncoder`로 암호화 저장 + 비교하도록 수정 완료
   (`UserServiceImpl.insertUser()`/`login()`).

3. **`/approveList.do`는 더미 데이터** — 14장 참고. RENTAL 테이블 설계 전까지 임시.

4. ~~`employee_number` 중복 미검증~~ — 이메일과 동일한 방식(승인대기/활성 상태만 중복 취급)으로
   `UserServiceImpl.insertUser()`에서 사원번호 중복 체크 추가 완료. DB 스키마에는 `NULL` 허용으로
   남아있고(앱단에서만 검증), `@NotBlank`로 폼에서는 필수 강제 중.

---

## 17. 자주 만나는 에러 Top 5

| 에러 메시지 | 원인 | 확인할 곳 |
|---|---|---|
| `No qualifying bean of type 'UserService'` | `@Service` 누락 또는 스캔 범위 밖 | `context-common.xml`의 `base-package` |
| `Invalid bound statement (not found)` | Mapper 인터페이스 ↔ XML `id`/`namespace` 불일치 | 메서드명, namespace 오타 |
| `Neither BindingResult nor plain target object for bean name 'userVO'` | `<form:form modelAttribute="userVO">`인데 Model에 없음 | GET 핸들러에 `model.addAttribute("userVO", new UserVO())` 있는지 |
| `Table 'EQUIPMENT'/'users' doesn't exist` | 스키마 미실행 | `src/main/resources/db/asset_schema.sql` 직접 실행 |
| 새로고침 시 폼 재전송 경고 | 처리 후 `return "뷰이름"`(Forward) 사용 | `return "redirect:...";` 로 변경 (PRG 패턴) |
| 새 공개 페이지가 로그인 화면으로 계속 튕김 | `LoginCheckInterceptor`의 `exclude-mapping`에 경로 추가를 안 함 | `dispatcher-servlet.xml` 확인 (10장) |

---

## 요약 카드

```
요청 흐름:  Filter → DispatcherServlet → Interceptor(Locale→Login→Admin) → Controller → Service → Mapper → DB
                                                                                    ↑ AOP가 예외를 여기서 가로챔

두 컨텍스트: Root(context-*.xml)=Service/Mapper   /   Servlet(dispatcher-servlet.xml)=Controller

user 상태값: P(승인대기) → Y(활성) / R(반려)      Y --탈퇴--> N

로그인 성공 후 이동: /main.do (EquipmentController가 처리, /user/main.do 아님)

페이징 3종 세트: EquipmentPaging(page,offset 계산) + PageMaker(시작/끝 페이지 계산) + Mapper의 LIMIT/OFFSET

⚠ 고쳐야 할 것: context-transaction.xml pointcut, /approveList.do 더미데이터
```
