# 사내 비품관리시스템 — 프로젝트 이해 가이드

> **목적**: 이 프로젝트가 "왜 이런 구조로 짜여 있는지"와 "무엇이 무엇을 부르는지"를 잡아주는 것.
> 각 장 맨 앞에 **📂 볼 파일**을 달아뒀다 — 읽기 전에 그 파일을 먼저 열어놓고, 설명과 코드를
> 대조해가며 읽을 것. 경로는 전부 프로젝트 루트(`asset-management-system/`) 기준 상대경로다.

---

## 학습 로드맵 (월화수 3일 기준)

| | 범위 | 내용 | 비고 |
|---|---|---|---|
| **월 (1일차)** | Part 1+2 (1~10장) | 아키텍처 큰 그림, 왜 eGovFrame인지, IoC/AOP/MyBatis/Interceptor 문법 | 표·코드 스니펫 위주라 상대적으로 가볍게 훑을 수 있음 |
| **화 (2일차)** | Part 3 (11~17장) | 사용자 상태값, 인터셉터 리팩터링, 가입→승인→로그인→탈퇴, 페이징 | 실제 컨트롤러/서비스/매퍼 코드를 열어 대조해야 해서 가장 오래 걸림 |
| **수 (3일차)** | Part 4+5 (18~26장) | 승인 게이팅(대여/연장/신고), 카테고리 FK 정규화, 체크리스트·트러블슈팅 | 화요일에 익힌 패턴(게이트/PRG/FK)의 응용이라 두 번째 바퀴 도는 느낌 |

---

## 목차

**Part 1. 큰 그림** — [1](#1-전체-요청-흐름-한-장) 요청 흐름 · [2](#2-왜-전자정부표준프레임워크eGovFrame인가) 왜 eGovFrame인가 · [3](#3-계층-구조-규칙) 계층 구조 · [4](#4-두-개의-spring-컨텍스트) 두 컨텍스트 · [5](#5-설정-파일-지도) 설정 파일 지도

**Part 2. 프레임워크 문법** — [6](#6-ioc--di--bean--왜-new를-안-쓰는가) IoC/DI/Bean · [7](#7-aop--예외-처리를-한-곳에-몰아넣는-이유) AOP · [8](#8-mybatis-핵심-3가지) MyBatis · [9](#9-filter-vs-interceptor) Filter vs Interceptor · [10](#10-validation과-prg-패턴) Validation/PRG

**Part 3. 도메인으로 이해하기** — [11](#11-이-프로젝트의-핵심-도메인-사용자-상태-4단계) 사용자 상태 · [12](#12-로그인권한-체크--interceptor로-리팩터링) 인터셉터 리팩터링 · [13](#13-회원가입--승인--로그인-흐름) 가입~로그인 · [14](#14-탈퇴-흐름) 탈퇴 · [15](#15-관리자-승인-화면-흐름) 승인 화면 · [16](#16-비품equipment-목록--페이징-흐름) 페이징 · [17](#17-헷갈리기-쉬운-것--maindo는-어디서-처리되는가) main.do 함정

**Part 4. 심화 — 승인 게이팅 & 정규화** — [18](#18-왜-승인-게이팅이-필요했는가) 게이팅 이유 · [19](#19-rentalreport-테이블--새로-생긴-컬럼들) 신규 컬럼 · [20](#20-대여-요청-승인-흐름) 대여 승인 · [21](#21-연장-요청-승인-흐름--임시-저장-패턴) 연장 승인 · [22](#22-신고-승인-흐름--왜-rental_id를-저장해야-했나) 신고 승인 · [23](#23-카테고리-분리--category-테이블과-fk) 카테고리 FK

**Part 5. 실전** — [24](#24-새-관리자-페이지-추가-체크리스트) 신규 화면 체크리스트 · [25](#25-트러블슈팅--자주-만나는-에러) 트러블슈팅 · [26](#26-알려진-이슈--남은-숙제) 알려진 이슈 · [요약 카드](#요약-카드)

---

# Part 1. 큰 그림

## 1. 전체 요청 흐름 한 장

> 📂 **볼 파일**: `src/main/webapp/WEB-INF/web.xml` · `src/main/webapp/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml`
> — 이 둘을 나란히 열어두고 아래 그림과 대조할 것. web.xml에서 필터 2개와 서블릿 등록을,
> dispatcher-servlet.xml에서 인터셉터·뷰리졸버를 확인한다.

```
브라우저
   │  GET/POST *.do
   ▼
[Filter]  인코딩 처리, XSS 방어                     ← web.xml
   ▼
[DispatcherServlet]  요청을 받는 관문                ← Spring MVC 시작점
   ▼
[Interceptor]  언어 변경 → 로그인 체크 → 관리자 권한 체크   ← dispatcher-servlet.xml
   ▼
[Controller]  URL ↔ 메서드 매핑
   ▼
[Service]  비즈니스 로직 (+ AOP 예외처리 자동 적용)
   ▼
[Mapper + XML]  SQL 실행 (MyBatis)
   ▼
[DB]  users, EQUIPMENT, RENTAL, REPORT, CATEGORY 테이블
   ▲
[View]  return "뷰이름" → ViewResolver → JSP 렌더링
```

이 프로젝트는 **Controller → Service → Mapper → DB** 4계층을 항상 지킨다.
컨트롤러가 Mapper를 직접 부르는 코드는 어디에도 없다 — 이 규칙 하나만 기억해도 코드 읽기가 쉬워진다.

---

## 2. 왜 전자정부표준프레임워크(eGovFrame)인가

> 📂 **볼 파일**: `src/main/resources/egovframework/spring/context-aspect.xml`(AOP 예외처리 설정) ·
> `src/main/java/egovframework/asset/user/service/impl/UserServiceImpl.java`(클래스 선언부에서
> `extends EgovAbstractServiceImpl` 확인) · `src/main/java/egovframework/asset/user/service/UserMapper.java`
> (import 문에서 `org.egovframe.rte.psl.dataaccess.mapper.Mapper` 확인)

**배경**: 공공기관 SW 사업은 매번 다른 업체가 수주해서 개발한다. 업체마다 쓰는 프레임워크가
제각각이면, 나중에 다른 업체가 유지보수를 넘겨받았을 때 코드를 처음부터 다시 파악해야 하고
(인수인계 비용), 처음 만든 업체에 계속 의존할 수밖에 없다(벤더 종속). 이 문제를 풀기 위해
행정안전부 주도로 "공공 SW 사업은 이 표준 구조를 따르자"고 만든 오픈소스 프레임워크가
전자정부 표준프레임워크(eGovFrame)다.

**Spring을 대체하는 게 아니라 그 위에 얹은 것**이라는 게 핵심이다. DI/AOP/MVC 같은 뼈대는
그대로 Spring을 쓰고, 그 위에 아래 것들을 표준화해서 얹었다:

| 얹은 것 | 목적 |
|---|---|
| 공통 컴포넌트(게시판, 파일업로드, 다국어, ID 생성기 등) | 매 프로젝트마다 반복 구현하는 기능을 재사용 |
| `EgovAbstractServiceImpl` 상속 + AOP 예외처리 | 어떤 업체가 짜도 예외 처리 방식이 동일 |
| `Mapper` 추상화 + `MapperConfigurer` | MyBatis 연동 방식을 표준화 |
| `LeaveaTrace`(추적 로그) | 감사(audit) 로그를 표준 포맷으로 남김 |

즉 **"eGovFrame을 배운다"는 사실상 "Spring을 배우고, 그 위에 얹힌 표준 관례 몇 가지를 더 배우는 것"**에
가깝다. 지금도 한국 공공기관·지자체 발주 SW 사업은 대부분 eGovFrame 사용을 요구하기 때문에,
국내 SI(시스템 통합) 업계에서는 사실상 필수 스택이다 — 이 프로젝트로 eGovFrame 구조에 익숙해지는
연습을 해두면 실무 진입 장벽이 낮아진다.

**이 프로젝트에서 실제로 "eGovFrame다운" 부분이 어디인지** — 순수 Spring과 비교하면 이렇다:

| 항목 | 순수 Spring | eGovFrame | 이 프로젝트에서 확인할 파일 |
|---|---|---|---|
| Mapper 어노테이션 | `org.apache.ibatis.annotations.Mapper` | `org.egovframe.rte.psl.dataaccess.mapper.Mapper` | `.../user/service/UserMapper.java` 상단 import |
| Mapper 등록 | `@MapperScan` | `MapperConfigurer` 빈 | `src/main/resources/egovframework/spring/context-mapper.xml` |
| Service 부모클래스 | 없음 | `EgovAbstractServiceImpl` 상속 | `.../user/service/impl/UserServiceImpl.java` 클래스 선언부 |
| 예외 처리 | `@ControllerAdvice` 등 | AOP(`context-aspect.xml`)로 자동 처리 | `src/main/resources/egovframework/spring/context-aspect.xml` |

이름이 같은 `@Mapper`가 패키지만 다르게 두 종류 있으니 import 문에서 헷갈리지 말 것.

---

## 3. 계층 구조 규칙

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/web/UserController.java`(`@Controller`) ·
> `src/main/java/egovframework/asset/user/service/UserService.java`(`@Service` 인터페이스) ·
> `src/main/java/egovframework/asset/user/service/UserMapper.java`(`@Mapper` 인터페이스) —
> 세 파일을 열어서 `UserController`가 `UserService`만 참조하고, `UserService`(구현체)가
> `UserMapper`만 참조하는지 눈으로 확인해볼 것.

| 어노테이션 | 계층 | 뜻 |
|---|---|---|
| `@Controller` | Presentation | HTTP 요청 처리 |
| `@Service` | Business | 비즈니스 로직 |
| `@Mapper`(eGov) | Persistence | SQL 실행 인터페이스 |

컨트롤러 → 서비스 → 매퍼 순서로만 호출이 내려간다. 반대로 매퍼가 서비스를 부르거나,
서비스가 컨트롤러를 부르는 일은 없다 — 이 방향성이 다음 장의 "두 컨텍스트 분리"와 바로 연결된다.

---

## 4. 두 개의 Spring 컨텍스트

> 📂 **볼 파일**: `src/main/webapp/WEB-INF/web.xml` — `<context-param>`(Root, `context-*.xml` 전체를
> 가리킴)과 `<servlet>`의 `<init-param>`(Servlet, `dispatcher-servlet.xml` 하나만 가리킴) 두 군데를
> 비교해서 볼 것. Root 쪽 실제 파일은 `src/main/resources/egovframework/spring/context-common.xml`.

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
→ Controller는 Service를 주입받을 수 있지만, Service가 Controller를 주입받을 순 없다
(3장의 계층 방향 규칙이 컨텍스트 분리로도 강제되는 셈).

---

## 5. 설정 파일 지도

> 📂 **볼 파일**: 아래 표에 나온 파일들을 실제로 하나씩 열어서 이름과 내용을 매칭해볼 것.
> 전부 `src/main/resources/egovframework/spring/` 아래에 있고, `dispatcher-servlet.xml`만
> `src/main/webapp/WEB-INF/config/egovframework/springmvc/` 아래에 따로 있다.

| 파일 (전체 경로) | 역할 |
|---|---|
| `src/main/webapp/WEB-INF/web.xml` | Filter 등록, DispatcherServlet 등록 → 두 컨텍스트의 시작점 |
| `src/main/webapp/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml` | `@Controller` 스캔, ViewResolver(뷰이름→JSP경로 변환), 인터셉터 |
| `src/main/resources/egovframework/spring/context-common.xml` | `@Service`/`@Mapper` 스캔(Controller 제외), 다국어 MessageSource |
| `src/main/resources/egovframework/spring/context-datasource.xml` | DB 커넥션 풀(BasicDataSource) |
| `src/main/resources/egovframework/spring/context-mapper.xml` | MyBatis SqlSessionFactory, `@Mapper` 스캔 |
| `src/main/resources/egovframework/spring/context-aspect.xml` | AOP 예외 처리 |
| `src/main/resources/egovframework/spring/context-transaction.xml` | 트랜잭션 설정 — ⚠ **버그 있음, [26장](#26-알려진-이슈--남은-숙제) 참고** |

**ViewResolver 변환 공식** (자주 나오니 외워둘 것 — 위 `dispatcher-servlet.xml`의
`UrlBasedViewResolver` 빈에서 `prefix`/`suffix` 값을 직접 확인해볼 것):
```
return "user/login"
  → prefix("/WEB-INF/jsp/egovframework/asset/") + "user/login" + suffix(".jsp")
  → /WEB-INF/jsp/egovframework/asset/user/login.jsp
```

> **폴더 이름 참고**: JSP 폴더가 `user` / `equipment` / `admin` 세 개로 나뉘어 있다
> (`src/main/webapp/WEB-INF/jsp/egovframework/asset/` 아래). 원래는 `board`(게시판) 폴더 하나에
> 관리자 화면과 사용자 화면이 다 섞여 있었는데 — eGovFrame 샘플 프로젝트가 기본으로 제공하는
> "게시판" 예제 폴더명을 그대로 재활용하다 보니 실제 내용과 안 맞는 이름이 됐던 것. 지금은
> `user`(로그인/회원가입), `equipment`(비품 조회·대여·반납 등 사용자 self-service), `admin`
> (role=ADMIN 전용 관리 화면) 세 폴더로 도메인 기준 정리했다. **컨트롤러가 `return`하는
> 문자열과 실제 JSP 폴더 위치는 항상 1:1로 맞아야 한다** — 폴더를 옮기면 그 폴더를 참조하는
> 모든 `return "/xxx/Yyy"` 문자열도 같이 고쳐야 한다.

---

# Part 2. 프레임워크 문법

## 6. IoC / DI / Bean — 왜 `new`를 안 쓰는가

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/service/impl/UserServiceImpl.java`
> (클래스 위 `@Service("userService")` 확인) · `src/main/java/egovframework/asset/user/web/UserController.java`
> (`@Resource(name = "userService")` 필드 확인) · `src/main/java/egovframework/asset/equipment/EquipmentController.java`
> (생성자 파라미터로 주입받는 부분 확인)

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
→ `@Resource` 필드 주입과 생성자 주입이 섞여 있다. 기능은 같고, 생성자 주입이 최신 Spring 권장 방식
(필드 없이 생성 시점에 의존성이 확정되어 테스트하기 쉽다).

---

## 7. AOP — 예외 처리를 한 곳에 몰아넣는 이유

> 📂 **볼 파일**: `src/main/resources/egovframework/spring/context-aspect.xml`(pointcut/aspect 정의) ·
> `src/main/java/egovframework/asset/cmmn/AssetExcepHndlr.java` · `src/main/java/egovframework/asset/cmmn/AssetOthersExcepHndlr.java`
> (실제 예외를 받아서 로그만 찍는 핸들러 2개) · `src/main/java/egovframework/asset/user/service/impl/UserServiceImpl.java`
> (`insertUser()`에서 일부러 예외를 던지는 지점을 찾아 흐름을 따라가 볼 것)

**AOP 없이 매 메서드마다 try-catch를 반복하는 대신**, `*Impl`로 끝나는 클래스의 모든 메서드를
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
(위 표현식은 `context-aspect.xml`의 `<aop:pointcut id="serviceMethod" ...>`에서 그대로 확인 가능.)

**이게 왜 되냐면**: `UserServiceImpl`이 `EgovAbstractServiceImpl`을 상속하기 때문이다.
이 상속 하나로 AOP 예외처리 + eGov 추적로그(`LeaveaTrace`)에 자동으로 편입된다 —
[2장](#2-왜-전자정부표준프레임워크egovframe인가)에서 말한 "eGovFrame이 Spring 위에 얹은 표준"의 실제 사례.

---

## 8. MyBatis 핵심 3가지

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/service/UserMapper.java`(인터페이스) ·
> `src/main/resources/egovframework/mapper/asset/UserMapper.xml`(SQL 본문) ·
> `src/main/resources/egovframework/sqlmap/asset/mappers/sql-mapper-config.xml`(`mapUnderscoreToCamelCase`) ·
> `src/main/resources/egovframework/mapper/asset/equipment_SQL.xml`(동적 SQL 예시)

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
→ 여기서 오타가 나면 `Invalid bound statement` 에러가 뜬다.

**동적 SQL** (`equipment_SQL.xml`에서 실제 사용 중):
```xml
<where>
    <if test="category != null and category != ''">
        AND category = #{category}
    </if>
</where>
```
category 파라미터가 없으면 `WHERE`절 자체가 안 생김 → 전체 조회.

---

## 9. Filter vs Interceptor

> 📂 **볼 파일**: `src/main/webapp/WEB-INF/web.xml`(`<filter>`/`<filter-mapping>` 두 블록) ·
> `src/main/java/egovframework/asset/cmmn/LoginCheckInterceptor.java` ·
> `src/main/java/egovframework/asset/cmmn/AdminCheckInterceptor.java` ·
> `src/main/webapp/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml`(`<mvc:interceptors>`)

| | Filter | Interceptor |
|---|---|---|
| 위치 | 서블릿 컨테이너(Tomcat) 레벨, Spring 밖 | Spring MVC 안쪽 |
| 설정 | `web.xml` | `dispatcher-servlet.xml` |
| Spring Bean 접근 | 불가능 | 가능 (세션의 `UserVO` 같은 도메인 객체를 자유롭게 다룸) |
| 이 프로젝트 | `CharacterEncodingFilter`(UTF-8), `HTMLTagFilter`(XSS 방어) | `LocaleChangeInterceptor`, `LoginCheckInterceptor`, `AdminCheckInterceptor` |

**로그인/권한 체크는 Interceptor로 처리한다.** 왜 그렇게 리팩터링했는지는 [12장](#12-로그인권한-체크--interceptor로-리팩터링)에서
자세히 다룬다 — 요지만: Filter는 Spring Bean(세션의 로그인 객체 등)에 접근하기 불편해서,
"로그인 여부"처럼 도메인 지식이 필요한 체크는 Interceptor가 더 잘 맞는다. Interceptor는
eGov가 만든 개념이 아니라 Spring MVC 표준 기능이고, 이 프로젝트는 그걸 그대로 가져다 쓴 것이다.

---

## 10. Validation과 PRG 패턴

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/service/UserVO.java`(`@NotBlank`/`@Email`/`@Size`) ·
> `src/main/java/egovframework/asset/user/web/UserController.java`(`register()`, `login()` 메서드) ·
> `src/main/webapp/WEB-INF/jsp/egovframework/asset/user/register.jsp`(`<form:errors path="...">` 부분)

**`@Valid` 자동 검증**: `UserVO`에 `@NotBlank`, `@Email`, `@Size` 등을 붙여두면, 컨트롤러가
`@Valid @ModelAttribute("userVO") UserVO userVO, BindingResult bindingResult`를 받을 때
Spring이 자동으로 검사하고 결과를 `BindingResult`에 담아준다. `bindingResult.hasErrors()`가
true면 JSP로 되돌리고, `<form:errors path="필드명">`이 그 필드의 오류 메시지를 출력한다.

**로그인엔 `@Valid`를 안 쓰는 이유**: `UserVO`의 `@NotBlank`가 `userName`, `employeeNumber`에도
붙어있는데, 로그인 폼은 email+password만 보내므로 `@Valid`를 걸면 항상 검증 실패한다.
그래서 로그인만 컨트롤러에서 email/password 빈값을 수동으로 체크한다.

**`redirect:` vs 그냥 뷰이름 반환** — 처리(POST) 후에는 항상 `redirect:`를 쓴다(PRG 패턴):
```
return "user/main"              → Forward, URL 안 바뀜, 새로고침하면 폼 재전송 경고
return "redirect:/main.do"      → 302 응답, 브라우저가 새로 GET 요청, 새로고침 안전
```
PRG = Post/Redirect/Get. 이 프로젝트의 모든 POST 처리 메서드(로그인, 가입, 승인, 반려, 등록/수정/삭제)가
전부 이 패턴을 따른다 — `UserController.java`/`EquipmentController.java`의 `return "redirect:..."`를
전부 검색(`Ctrl+Shift+F`로 `redirect:` 찾기)해서 몇 군데인지 세어봐도 좋다.

---

# Part 3. 도메인으로 이해하기

## 11. 이 프로젝트의 핵심 도메인: 사용자 상태 4단계

> 📂 **볼 파일**: `src/main/resources/db/asset_schema.sql`(`users` 테이블의 `use_yn` 컬럼 정의) ·
> `src/main/resources/egovframework/mapper/asset/UserMapper.xml`(아래 표에 나온 select 쿼리 3개)

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

## 12. 로그인/권한 체크 — Interceptor로 리팩터링

> 📂 **볼 파일**: `src/main/java/egovframework/asset/cmmn/LoginCheckInterceptor.java`(`preHandle()`) ·
> `src/main/java/egovframework/asset/cmmn/AdminCheckInterceptor.java`(`preHandle()`) ·
> `src/main/webapp/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml`(`<mvc:interceptors>` 블록) ·
> 비교용으로 `src/main/java/egovframework/asset/equipment/EquipmentController.java`를 열어
> `HttpSession`/`UserVO` import가 없다는 것도 확인해볼 것.

**Before**: 로그인 여부를 확인하는 코드가 `UserController`, `EquipmentController`에
아래 형태로 12곳 넘게 그대로 복사돼 있었다.
```java
UserVO loginUser = (UserVO) session.getAttribute("loginUser");
if (loginUser == null) { return "redirect:/user/loginView.do"; }
```
관리자 전용 화면은 여기에 `!"ADMIN".equals(loginUser.getRole())` 체크까지 덧붙어 더 길었다.

**After**: `egovframework.asset.cmmn` 패키지에 `HandlerInterceptor`를 구현한 인터셉터 2개를
만들고, `dispatcher-servlet.xml`에 어떤 경로에 적용할지만 등록했다.

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
        <!-- ...대여/연장/신고 승인·반려, 비품/카테고리 CRUD 경로도 전부 여기 등록되어 있다 -->
        <bean class="egovframework.asset.cmmn.AdminCheckInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```

**등록 순서가 중요하다.** `<mvc:interceptors>`에 나열된 순서대로 `preHandle()`이 실행되므로,
로그인 체크가 관리자 체크보다 먼저 와야 한다. 그래야 `AdminCheckInterceptor`가 role을 확인하는
시점엔 "로그인은 이미 되어 있다"고 가정할 수 있다.

**결과**: 컨트롤러 메서드에서 세션 null 체크가 전부 사라졌다. `EquipmentController`는
`HttpSession`/`UserVO` import 자체가 필요 없어졌다. 단, `withdraw()`의 "ADMIN은 탈퇴 불가" 체크는
**인증이 아니라 업무 규칙**이라 컨트롤러에 그대로 남겨뒀다 — 로그인 여부/권한처럼 "여러 화면에
공통으로 적용되는 게이트"만 인터셉터로 뽑는 것이 기준이다.

> ⚠ **인터셉터를 추가할 때 흔한 실수**: 새 공개 페이지(로그인 필요 없는 화면)를 만들고
> `exclude-mapping`에 추가하는 걸 깜빡하면, 그 페이지 자체가 로그인 화면으로 무한 리다이렉트된다.
> 반대로 새 관리자 화면을 만들고 `AdminCheckInterceptor`의 `mvc:mapping`에 경로를 안 넣으면
> 일반 사용자도 접근할 수 있게 된다 — 두 실수 모두 눈에 잘 안 띄니 주의 ([24장](#24-새-관리자-페이지-추가-체크리스트) 체크리스트 참고).

---

## 13. 회원가입 → 승인 → 로그인 흐름

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/web/UserController.java`(`register()`, `login()`) ·
> `src/main/java/egovframework/asset/user/service/impl/UserServiceImpl.java`(`insertUser()`, `login()`) ·
> `src/main/resources/egovframework/mapper/asset/UserMapper.xml` ·
> JSP 3종: `.../user/register.jsp`, `.../user/login.jsp`, `.../user/joinResult.jsp`
> — 아래 흐름을 한 줄씩 읽으면서 대응하는 코드를 직접 찾아 밑줄 그어볼 것.

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

[관리자 승인]  (15장에서 자세히)
관리자가 /user/pendingList.do 화면에서 승인 버튼 클릭
  → POST /user/approve.do → use_yn: P → Y

[로그인]
POST /user/login.do
  UserController.login()
    email/password 빈값 수동 체크 (10장 참고 — @Valid 안 씀)
    ↓
  UserServiceImpl.login()
    selectUserByEmail(email)  ← use_yn='Y' 인 계정만 조회됨
    비밀번호 불일치 or 계정 없음(P/R/N 상태 포함) → null
    ↓
  성공 → session.setAttribute("loginUser", loginUser)
        → redirect:/main.do          ← ⚠ /user/main.do 아님, EquipmentController가 처리 (17장)
  실패 → findByEmailAnyStatus(email)로 상태 재조회 후
        P → "승인 중입니다"  /  R → "반려되었습니다"  /  N → "탈퇴한 계정입니다"
        /  없음 → "이메일 또는 비밀번호가 올바르지 않습니다"
        → login.jsp 에러 메시지 표시
```

---

## 14. 탈퇴 흐름

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/web/UserController.java`(`withdraw()`) ·
> `src/main/java/egovframework/asset/user/service/impl/UserServiceImpl.java`(`withdrawUser()`) ·
> `src/main/webapp/WEB-INF/jsp/egovframework/asset/user/myInfo.jsp`(탈퇴 버튼과 `<form>`)

```
POST /user/withdraw.do
  UserController.withdraw()
    ADMIN 이면 → 탈퇴 거부, /main.do 로 돌려보냄  (관리자 탈퇴 방지)
    ↓
  userService.withdrawUser(userId) → UPDATE users SET use_yn='N' WHERE use_yn='Y'
  session.invalidate()
  → 로그인 페이지
```
탈퇴는 실제 `DELETE`가 아니라 `use_yn='N'` 마킹(소프트 삭제)이다. 기록은 DB에 남는다.

---

## 15. 관리자 승인 화면 흐름

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/web/UserController.java`(`pendingList()`,
> `approve()`, `reject()`) · `src/main/resources/egovframework/mapper/asset/UserMapper.xml`
> (`updateUserApprove`, `updateUserReject`) · `src/main/webapp/WEB-INF/jsp/egovframework/asset/admin/ApproveUserList.jsp`

```
GET  /user/pendingList.do
  (LoginCheckInterceptor → AdminCheckInterceptor 통과해야 컨트롤러 도달, ADMIN 아니면 /main.do 로 튕겨냄)
  userService.getPendingUserList() → use_yn='P' 목록, 신청일 오름차순
  → /admin/ApproveUserList.jsp

POST /user/approve.do?userId=n  →  updateUserApprove: P→Y 로 변경 (P 상태일 때만)
POST /user/reject.do?userId=n   →  updateUserReject : P→R 로 변경 (P 상태일 때만)
  둘 다 처리 후 pendingList.do 로 다시 리다이렉트 (새로고침해도 안전)
```
`WHERE user_id=#{userId} AND use_yn='P'` 조건이 있어서, 이미 처리된 요청을 중복 클릭해도
두 번째 클릭은 아무 일도 안 일어난다 (0 rows affected) — 방어적으로 잘 짜여 있다.

---

## 16. 비품(EQUIPMENT) 목록 + 페이징 흐름

> 📂 **볼 파일**: `src/main/java/egovframework/asset/equipment/EquipmentController.java`(`mainPage()`,
> `equipmentList()`) · `EquipmentServiceImpl.java` · `EquipmentMapper.java` (모두 같은
> `src/main/java/egovframework/asset/equipment/` 폴더) · `src/main/resources/egovframework/mapper/asset/equipment_SQL.xml` ·
> `src/main/java/egovframework/asset/cmmn/PageMaker.java` · `.../cmmn/EquipmentPaging.java` ·
> JSP: `.../equipment/TestUI.jsp`, `.../equipment/EquipmentList.jsp`

user 모듈과 구조가 다르다: **생성자 주입**, **Map 파라미터로 동적 조건 전달**, **자체 페이징 클래스**.

```
GET /main.do
  (LoginCheckInterceptor 통과해야 컨트롤러 도달, 미로그인 → 로그인 페이지)
  EquipmentController.mainPage()
    equipmentService.getCategorySummary()
      → SQL: category별 GROUP BY, 전체/대여가능/대여중/신고 건수 집계
    → /equipment/TestUI.jsp (대시보드, 카테고리별 카드)

GET /equipmentList.do?category=노트북&page=2
  EquipmentController.equipmentList()
    1. EquipmentPaging 생성: page=2, perPageNum=15
    2. params = { category, pageSize=15, offset=(2-1)*15=15 }
    3. equipmentService.getEquipmentList(params)
         → SQL: WHERE category=? ORDER BY equipment_id LIMIT 15 OFFSET 15
    4. equipmentService.getEquipmentCount(params) → 전체 건수 (페이지 계산용)
    5. PageMaker.setTotalCount() → 시작페이지/끝페이지/이전유무/다음유무 자동 계산
    → /equipment/EquipmentList.jsp
```

**페이징 계산 원리** (`PageMaker.calcData()` — `src/main/java/egovframework/asset/cmmn/PageMaker.java`에서
직접 코드를 열어 아래 공식과 한 줄씩 대조):
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

---

## 17. 헷갈리기 쉬운 것 — `/main.do`는 어디서 처리되는가

> 📂 **볼 파일**: `src/main/java/egovframework/asset/user/web/UserController.java`(`main()` 메서드,
> `/user/main.do`) · `src/main/java/egovframework/asset/equipment/EquipmentController.java`
> (`mainPage()` 메서드, `/main.do`) — 두 `@RequestMapping` 값을 직접 비교해볼 것.

`UserController`에도 `main()` 메서드가 `/user/main.do`로 남아있지만, **실제 로그인 성공 후 이동하는 곳은
`/main.do`(슬래시로 시작, `/user/`가 없음)이고 이건 `EquipmentController.mainPage()`가 처리한다.**
`/user/main.do`는 현재 어디서도 호출되지 않는 사실상 죽은 코드다. 헷갈리면 URL의 `/user/` 유무를 확인할 것.

---

# Part 4. 심화 — 승인 게이팅 & 정규화

이 파트는 크게 두 가지 리팩터링을 다룬다. ① 대여/연장/신고 "요청"이 관리자 승인을 진짜로
거치게 만든 것(승인 게이팅), ② 비품의 카테고리를 문자열이 아니라 별도 테이블 + FK로 관리하게
바꾼 것(정규화). 둘 다 "이미 동작하던 기능을 왜 다시 뜯어고쳤는가"를 이해하는 게 핵심이다.

## 18. 왜 "승인 게이팅"이 필요했는가

> 📂 **볼 파일**: `src/main/java/egovframework/asset/equipment/RentalServiceImpl.java` ·
> `src/main/resources/egovframework/mapper/asset/rental_SQL.xml` ·
> `src/main/webapp/WEB-INF/jsp/egovframework/asset/admin/ApproveList.jsp`

**Before**: 사용자가 대여를 "요청"하면, 승인 절차 없이 그 즉시 모든 효과가 반영됐다.
```
POST /rentalRequest.do
  → RENTAL 행 INSERT (request_status = 'REQUESTED')
  → EQUIPMENT.status = 'RENTED'   ← 승인도 안 했는데 이미 대여중 처리!
```
`request_status` 컬럼은 있는데 그 값을 REQUESTED에서 APPROVED/REJECTED로 바꿔주는 코드가
어디에도 없었다. 관리자 승인 화면도 있었지만 더미 데이터만 보여줄 뿐, 버튼을 눌러도
`alert('승인 처리는 추후 연동 예정입니다.')`만 뜨고 실제로는 아무 일도 안 일어났다.

**After**: "요청"은 상태만 기록하고, 실제 효과는 **관리자가 승인하는 시점**에만 일어난다.
```
POST /rentalRequest.do
  → RENTAL 행 INSERT (request_status = 'REQUESTED')
  → EQUIPMENT.status 는 그대로 AVAILABLE  ← 아직 아무것도 안 바뀜

POST /approveRental.do (관리자가 승인 버튼 클릭)
  → RENTAL.request_status = 'APPROVED'
  → EQUIPMENT.status = 'RENTED'          ← 이 시점에야 비로소 바뀜

POST /rejectRental.do (관리자가 반려 버튼 클릭)
  → RENTAL.request_status = 'REJECTED'
  → EQUIPMENT 는 계속 AVAILABLE (애초에 안 바꿨으니 되돌릴 것도 없음)
```
**"게이트(gate)"라는 이름의 이유**: 승인이라는 문을 통과하기 전까지는 부수효과(side effect)가
발생하지 않고 대기 상태로만 머문다. 대여/연장/신고 셋 다 같은 패턴을 따른다 —
"요청 시점엔 상태만 저장, 승인 시점에 실제 효과 반영, 반려 시점엔 아무것도 안 함."

---

## 19. RENTAL/REPORT 테이블 — 새로 생긴 컬럼들

> 📂 **볼 파일**: `src/main/resources/db/asset_schema.sql` — `RENTAL`, `REPORT` 테이블
> `CREATE TABLE` 문에서 아래 컬럼들의 실제 타입/제약조건을 확인할 것.

```sql
RENTAL
  request_status          -- REQUESTED / APPROVED / REJECTED   (대여 자체의 승인 상태)
  extend_status            -- NULL / REQUESTED / APPROVED / REJECTED  (연장 요청의 승인 상태, 대여와 별개)
  requested_return_date    -- 연장 요청 시 "희망하는" 새 반납일 (승인 전까지 여기 임시로만 저장)
  extend_reason            -- 연장 사유

REPORT
  status                   -- PENDING / APPROVED / REJECTED
  rental_id                -- 이 신고가 어떤 대여 건에 대한 것인지 (승인 시 그 대여를 종료시키기 위해 필요)
```

`request_status`와 `extend_status`가 **분리되어 있는 이유**: 대여는 이미 승인(APPROVED)됐는데
그 이후에 "연장"을 다시 요청하는 상황이 있기 때문이다. 하나의 컬럼으로 관리하면 "대여 승인 상태"와
"연장 승인 상태"가 서로 덮어써서 구분이 안 된다. 그래서 대여 자체의 생애주기(request_status)와
연장 요청의 생애주기(extend_status)를 별도 컬럼으로 나눴다.

---

## 20. 대여 요청 승인 흐름

> 📂 **볼 파일**: `src/main/java/egovframework/asset/equipment/EquipmentController.java`
> (`rentalRequestSubmit()`, `approveRental()`, `rejectRental()`) · `RentalServiceImpl.java`
> (`insertRentalRequest()`, `approveRental()`) · `RentalMapper.java` ·
> `src/main/resources/egovframework/mapper/asset/rental_SQL.xml`

```
[요청]
POST /rentalRequest.do
  RentalServiceImpl.insertRentalRequest()
    1. equipmentMapper.selectAvailableEquipmentIdsByName() 으로 AVAILABLE 비품 id들을 quantity개 확보
    2. 재고 부족하면 예외 던지고 끝
    3. 확보한 개수만큼 RENTAL 행 INSERT (request_status 기본값 'REQUESTED')
       ← 비품 status는 여기서 안 건드림 (18장 참고)

[승인/반려]
POST /approveRental.do?rentalId=n
  rentalService.approveRental(n)
    → UPDATE RENTAL r JOIN EQUIPMENT e ON e.equipment_id = r.equipment_id
        SET r.request_status='APPROVED', e.status='RENTED'
        WHERE r.rental_id = n
      (한 번의 UPDATE로 두 테이블을 동시에 바꾸는 MySQL 멀티테이블 UPDATE 문법)

POST /rejectRental.do?rentalId=n
  rentalService.rejectRental(n)
    → UPDATE RENTAL SET request_status='REJECTED' WHERE rental_id = n
      (EQUIPMENT는 아예 건드리지 않음)
```

**멀티테이블 UPDATE가 왜 여기서 쓰였나**: "승인하면 RENTAL도 바뀌고 EQUIPMENT도 바뀐다"를
한 SQL 문으로 처리하면, Java 코드에서 두 번 나눠 호출하는 것보다 원자적(atomic)이다.
(22장에서 보듯 REPORT 승인 쪽은 멀티테이블 UPDATE 대신 여러 Mapper 호출을 한 트랜잭션으로
묶는 방식을 썼다 — 상황에 따라 방식이 다르다는 것도 봐 둘 것.)

---

## 21. 연장 요청 승인 흐름 — "임시 저장" 패턴

> 📂 **볼 파일**: `src/main/java/egovframework/asset/equipment/EquipmentController.java`
> (`extendRequestSubmit()`, `approveExtend()`, `rejectExtend()`) · `RentalServiceImpl.java`
> (`requestExtend()`, `approveExtend()`) · `src/main/resources/egovframework/mapper/asset/rental_SQL.xml` ·
> `src/main/webapp/WEB-INF/jsp/egovframework/asset/equipment/ExtendRequest.jsp`

연장은 조금 더 까다롭다. 대여 요청은 "아직 안 바뀐 상태"가 곧 원래 상태(AVAILABLE)라서
그냥 안 건드리면 됐지만, 연장은 **이미 존재하는 `return_date` 값을 덮어쓰는 것**이라
"승인 전까지 어딘가에 새 날짜를 잠깐 보관해둘 곳"이 따로 필요하다. 그게 `requested_return_date`다.

```
[요청]
POST /extendRequest.do  (rentalId, newReturnDate, reason)
  RentalServiceImpl.requestExtend()
    → UPDATE RENTAL
        SET extend_status='REQUESTED', requested_return_date=?, extend_reason=?
        WHERE rental_id=? AND user_id=?
      ← 진짜 return_date는 아직 안 바뀜! requested_return_date에만 "희망 날짜"를 임시 저장

[승인]
POST /approveExtend.do?rentalId=n
  rentalService.approveExtend(n)
    → UPDATE RENTAL
        SET return_date = requested_return_date,   ← 여기서야 비로소 실제 반납일에 반영
            extend_status = 'APPROVED'
        WHERE rental_id = n

[반려]
POST /rejectExtend.do?rentalId=n
  → UPDATE RENTAL SET extend_status='REJECTED' WHERE rental_id=n
    (return_date는 원래 값 그대로 — requested_return_date는 버려지는 값이 됨)
```

---

## 22. 신고 승인 흐름 — 왜 `rental_id`를 저장해야 했나

> 📂 **볼 파일**: `src/main/java/egovframework/asset/equipment/EquipmentController.java`
> (`reportIssueSubmit()`, `approveReport()`, `rejectReport()`) · `ReportServiceImpl.java`(`approveReport()`) ·
> `ReportMapper.java` · `src/main/resources/egovframework/mapper/asset/report_SQL.xml` ·
> `src/main/webapp/WEB-INF/jsp/egovframework/asset/equipment/ReportIssue.jsp`

신고(REPORT)가 승인되면 두 가지가 함께 일어나야 한다: **비품을 BROKEN으로 바꾸는 것**과
**그 비품을 빌려간 대여 기록(RENTAL)을 종료시키는 것**. 게이팅을 도입하면서
"신고 접수 시점엔 아무것도 안 하고, 승인 시점에만 처리"로 바꿨는데, 그러면
**승인하는 시점(나중)에는 신고 접수 시점(예전)에만 알 수 있었던 `rentalId`가 필요**해진다.
그래서 `REPORT.rental_id` 컬럼을 새로 추가해서 접수 시점에 저장해두고, 승인 시점에 꺼내 쓴다.

```
[접수]
POST /reportIssue.do
  reportService.insertReport(reportVO)
    → INSERT INTO REPORT (..., rental_id, status) VALUES (..., ?, 'PENDING')
      ← 여기서 미리 rental_id를 저장해둔다 (나중에 쓰려고)

[승인]
POST /approveReport.do?reportId=n
  ReportServiceImpl.approveReport(n)  ← @Transactional
    1. reportMapper.selectReportById(n) 로 equipmentId, rentalId 를 다시 조회
    2. reportMapper.approveReport(n) → REPORT.status = 'APPROVED'
    3. rentalMapper.updateEquipmentStatus(equipmentId, 'BROKEN')
    4. rentalMapper.deleteRental(rentalId)   ← 대여 기록 종료

[반려]
POST /rejectReport.do?reportId=n
  → REPORT.status = 'REJECTED' 만 바뀌고, 비품/대여는 그대로
```

**[26장](#26-알려진-이슈--남은-숙제)에서 다루는 `context-transaction.xml` 버그가 바로 여기서 문제가 된다.**
위 승인 로직은 Mapper를 3번 연속 호출하는데(REPORT 수정 → EQUIPMENT 수정 → RENTAL 삭제),
`@Transactional`이 제대로 안 걸려 있으면 3번 중 두 번째에서 에러가 나도 첫 번째 변경은 이미
커밋된 채로 남는다 — 데이터 일관성이 깨질 수 있는 지점.

---

## 23. 카테고리 분리 — CATEGORY 테이블과 FK

> 📂 **볼 파일**: `src/main/resources/db/asset_schema.sql`(`CATEGORY` 테이블, `EQUIPMENT.category_id` FK) ·
> `src/main/resources/egovframework/mapper/asset/equipment_SQL.xml`(`selectEquipmentList`, `insertEquipment`) ·
> `src/main/java/egovframework/asset/equipment/EquipmentController.java`
> (`categoryList()`, `categoryRegister()`, `categoryUpdate()`, `categoryDelete()`) ·
> JSP: `.../admin/CategoryList.jsp`, `.../admin/EquipmentForm.jsp`

**Before**: `EQUIPMENT.category`가 그냥 문자열(`VARCHAR`)이었다. 등록 화면의 드롭다운도
JSP에 `모니터`, `노트북` 같은 값을 하드코딩해둔 것이었다. 문제는:
- 새 카테고리를 추가하려면 JSP 코드를 직접 고쳐야 했다 (데이터가 아니라 코드였음)
- 오타가 나면("노트북" vs "노트북 ") 같은 카테고리가 두 개로 쪼개져 집계가 깨진다

**After**: `CATEGORY(category_id, category_name)` 테이블을 새로 만들고, `EQUIPMENT`는
문자열 대신 `category_id`로 그 테이블의 한 행을 참조(FK)한다.

```sql
CATEGORY
  category_id    BIGINT PK
  category_name  VARCHAR UNIQUE

EQUIPMENT
  category_id    BIGINT  → CATEGORY.category_id 를 참조하는 FK
```

**왜 이름(문자열)이 아니라 번호(id)로 연결하는가?** 이름으로 연결하면 나중에 "노트북"을
"노트북/랩탑"으로 바꾸고 싶을 때 EQUIPMENT의 모든 행을 같이 고쳐야 한다. 번호로 연결하면
CATEGORY 테이블의 그 한 줄만 고치면 그 번호를 참조하는 모든 비품에 자동으로 반영된다.
이게 관계형 DB에서 "정규화(normalization)"라고 부르는 것의 실제 이유다.

**화면/컨트롤러는 그대로 "이름" 문자열을 주고받는다** — 이게 이 리팩터링에서 손대는 범위를
최소화한 핵심 트릭이다. 모든 조회 쿼리가 `CATEGORY`를 JOIN해서 `c.category_name AS category`로
별칭을 주기 때문에, JSP 입장에서는 `${item.category}`가 여전히 "노트북" 같은 문자열로 보인다 —
DB 안에서만 번호로 연결돼 있다는 걸 SQL이 감춰준다.

```xml
<!-- 조회: JOIN 해서 이름을 category 라는 이름으로 내려줌 (JSP는 변경 몰라도 됨) -->
<select id="selectEquipmentList" resultType="...EquipmentVO">
  SELECT e.equipment_id, e.equipment_name, c.category_name AS category, ...
  FROM EQUIPMENT e JOIN CATEGORY c ON e.category_id = c.category_id
  ...
</select>

<!-- 등록: 전달받은 "이름"으로 CATEGORY를 찾아서 그 id를 저장 -->
<insert id="insertEquipment">
  INSERT INTO EQUIPMENT (equipment_name, category_id, status, created_at)
  SELECT #{equipmentName}, category_id, 'AVAILABLE', NOW()
  FROM CATEGORY WHERE category_name = #{category}
</insert>
```

**FK가 삭제를 막아주는 안전장치 역할도 한다**: 어떤 카테고리를 쓰는 비품이 하나라도 남아있으면,
`DELETE FROM CATEGORY WHERE category_id=?`는 FK 제약 위반으로 실패한다(`DataIntegrityViolationException`).
컨트롤러는 이 예외를 잡아서 "이 카테고리를 사용 중인 비품이 있어 삭제할 수 없습니다"라는
안내 메시지로 바꿔준다 — **관계형 DB의 FK가 "이 데이터는 아직 누가 쓰고 있으니 함부로 지우면
안 된다"를 코드로 검증하지 않아도 DB 스스로 지켜주는 예시다.**

```java
try {
    equipmentService.deleteCategory(categoryId);
} catch (org.springframework.dao.DataIntegrityViolationException e) {
    return "redirect:/categoryList.do?error=categoryInUse";
}
```

**`CategoryList.jsp`에 쓴 HTML5 트릭 하나**: 카테고리 이름 수정 폼과 "저장" 버튼을 표(`<table>`)의
서로 다른 `<td>`에 나눠 넣고 싶었는데, 버튼은 자기가 속한 `<form>` 안에서만 제출(submit)되는 게
기본 동작이다. 이럴 때 버튼에 `form="editForm123"` 속성을 주면, DOM 상 어디 있든 그 id를 가진
`<form>`에 소속된 것처럼 동작한다 — HTML5부터 지원되는 기능.

```html
<form id="editForm123" action="categoryUpdate.do">
  <input type="text" name="categoryName" value="노트북">
</form>
...
<!-- 이 버튼은 위 form 밖에 있지만 form="editForm123" 덕분에 그 폼을 제출한다 -->
<button type="submit" form="editForm123">저장</button>
```

---

# Part 5. 실전

## 24. 새 관리자 페이지 추가 체크리스트

> 📂 **볼 파일**: `src/main/webapp/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml`
> (세 번째 `<mvc:interceptor>` 블록) · `src/main/java/egovframework/asset/equipment/EquipmentController.java`

관리자 화면(`equipmentForm.do`, `categoryList.do` 등)을 새로 추가할 때마다 실제로 따라야 했던 순서:

1. `EquipmentController`(또는 해당 컨트롤러)에 `@RequestMapping`/`@PostMapping` 메서드 추가
2. `dispatcher-servlet.xml`의 **세 번째** `<mvc:interceptor>`(`AdminCheckInterceptor`)에
   `<mvc:mapping path="/새경로.do"/>` 추가 — **이걸 빼먹으면 일반 사용자도 URL을 직접 치면
   들어갈 수 있다.** 화면에 링크를 안 보여주는 것만으로는 보안이 되지 않는다(버튼을 숨기는 것과
   서버가 막는 것은 다른 문제 — [14장](#14-탈퇴-흐름) `withdraw()`의 ADMIN 체크와 같은 이치).
3. 리다이렉트 대상 URL에 한글 등 비ASCII 값을 붙여야 한다면 [25장](#25-트러블슈팅--자주-만나는-에러)의 인코딩 문제를 기억할 것

---

## 25. 트러블슈팅 — 자주 만나는 에러

> 📂 **볼 파일**: 에러별로 아래 표의 "확인할 곳" 경로를 그대로 열어보면 된다. 리다이렉트
> 인코딩 문제는 `src/main/java/egovframework/asset/equipment/EquipmentController.java`의
> `encode()` 메서드에서 실제 해결 코드를 확인할 것.

| 에러 메시지 | 원인 | 확인할 곳 |
|---|---|---|
| `No qualifying bean of type 'UserService'` | `@Service` 누락 또는 스캔 범위 밖 | `src/main/resources/egovframework/spring/context-common.xml`의 `base-package` |
| `Invalid bound statement (not found)` | Mapper 인터페이스 ↔ XML `id`/`namespace` 불일치 | `.../user/service/UserMapper.java` ↔ `.../mapper/asset/UserMapper.xml`의 메서드명·namespace 오타 |
| `Neither BindingResult nor plain target object for bean name 'userVO'` | `<form:form modelAttribute="userVO">`인데 Model에 없음 | GET 핸들러에 `model.addAttribute("userVO", new UserVO())` 있는지 (`UserController.java`) |
| `Table 'EQUIPMENT'/'users' doesn't exist` | 스키마 미실행 | `src/main/resources/db/asset_schema.sql` 직접 실행 |
| 새로고침 시 폼 재전송 경고 | 처리 후 `return "뷰이름"`(Forward) 사용 | `return "redirect:...";`로 변경 ([10장](#10-validation과-prg-패턴) PRG 패턴) |
| 새 공개 페이지가 로그인 화면으로 계속 튕김 | `LoginCheckInterceptor`의 `exclude-mapping`에 경로 추가를 안 함 | `dispatcher-servlet.xml` 확인 ([12장](#12-로그인권한-체크--interceptor로-리팩터링)) |
| 새 관리자 화면을 일반 사용자도 열 수 있음 | `AdminCheckInterceptor`의 `mvc:mapping`에 새 URL 추가를 깜빡함 | `dispatcher-servlet.xml`의 세 번째 `<mvc:interceptor>` 확인 ([24장](#24-새-관리자-페이지-추가-체크리스트)) |
| `Http11Processor.writeHeaders` 경고 + 리다이렉트가 안 먹힘 | `redirect:"...category=" + 한글값`처럼 헤더에 비ASCII 문자를 그대로 붙임 (`Location` 헤더는 ISO-8859-1만 허용) | 아래 상세 참고, `URLEncoder.encode(value, "UTF-8")`로 감싸기 |

**리다이렉트 URL 인코딩 — 실전에서 만난 버그**: 카테고리 이름에 "핸드폰"을 넣고 비품을 등록했더니
톰캣 로그에 이런 경고가 떴다.
```
경고: 값이 [/equipmentList.do?category=핸드폰]인 HTTP 응답 헤더 [Location](이)가
유효하지 않은 값이므로 응답에서 제거되었습니다.
```
**원인**: HTTP 스펙상 `Location` 헤더(리다이렉트 주소)는 ISO-8859-1(라틴-1, 0~255 범위)만 허용하는데,
컨트롤러가 문자열을 그냥 이어붙였다.
```java
// ❌ "핸드폰" 같은 한글이 그대로 헤더에 들어감
return "redirect:/equipmentList.do?category=" + equipmentVO.getCategory();
```
브라우저의 `<a href="...">`를 클릭할 때는 브라우저가 알아서 URL을 퍼센트 인코딩해주지만,
**서버 코드에서 문자열을 직접 이어붙여 만드는 리다이렉트는 그런 인코딩을 아무도 해주지 않는다.**
그래서 톰캣이 헤더 자체를 통째로 버려버린 것.

```java
// ✅ 붙이기 전에 직접 인코딩 (EquipmentController.java의 encode() 메서드)
private String encode(String value) {
    try {
        return URLEncoder.encode(value, "UTF-8");
    } catch (UnsupportedEncodingException e) {
        throw new RuntimeException(e);
    }
}
return "redirect:/equipmentList.do?category=" + encode(equipmentVO.getCategory());
```
**기억할 규칙**: `Controller`가 직접 만드는 `redirect:` 문자열에 사용자 입력이나 한글이
들어갈 가능성이 있다면 항상 `URLEncoder.encode(value, "UTF-8")`을 거칠 것.

---

## 26. 알려진 이슈 / 남은 숙제

> 📂 **볼 파일**: `src/main/resources/egovframework/spring/context-transaction.xml`(pointcut 값) ·
> `src/main/java/egovframework/asset/equipment/ReportServiceImpl.java`(`approveReport()`)

1. **`context-transaction.xml`의 pointcut이 이 프로젝트를 가리키지 않는다**
   ```xml
   <!-- 현재: 존재하지 않는 패키지를 가리켜서 트랜잭션이 실제로 안 걸림 -->
   <aop:pointcut id="requiredTx"
       expression="execution(* egovframework.example.sample..impl.*Impl.*(..))"/>
   <!-- 맞는 값: egovframework.asset..impl.*Impl.*(..) -->
   ```
   단순 INSERT/UPDATE 한 번짜리는 이 버그가 드러나지 않지만, `ReportServiceImpl.approveReport()`
   ([22장](#22-신고-승인-흐름--왜-rental_id를-저장해야-했나))처럼 한 메서드 안에서 여러 테이블에
   걸쳐 작업하는 경우엔 롤백이 안 걸릴 수 있는 실제 위험 지점이다 — 직접 고쳐보면 좋은 연습 문제.

2. **과거 대여 데이터의 상태 불일치** — 게이팅 도입 전에는 대여 요청 즉시 비품이 RENTED로
   바뀌었다. 게이팅 도입 이전에 만들어진 RENTAL 행은 `request_status`가 영원히 `REQUESTED`인 채로
   남아있는데, 비품은 이미 RENTED 상태다. 이런 옛날 데이터를 지금 승인 화면에서 반려하면
   `request_status`만 REJECTED로 바뀌고 비품은 RENTED로 남아버린다 — 신규 요청은 정상 동작하지만,
   과거 데이터는 수동 정리가 필요할 수 있다.

---

## 요약 카드

```
요청 흐름:  Filter → DispatcherServlet → Interceptor(Locale→Login→Admin) → Controller → Service → Mapper → DB
                                                                                    ↑ AOP가 예외를 여기서 가로챔

왜 eGovFrame: 공공 SW 사업의 벤더 종속/인수인계 문제를 풀기 위한 표준. Spring 위에 공통컴포넌트·
             표준 예외처리(AOP)·Mapper 추상화를 얹은 것 — Spring을 대체하지 않는다.

두 컨텍스트: Root(context-*.xml)=Service/Mapper   /   Servlet(dispatcher-servlet.xml)=Controller

user 상태값: P(승인대기) → Y(활성) / R(반려)      Y --탈퇴--> N

로그인 성공 후 이동: /main.do (EquipmentController가 처리, /user/main.do 아님)

페이징 3종 세트: EquipmentPaging(page,offset 계산) + PageMaker(시작/끝 페이지 계산) + Mapper의 LIMIT/OFFSET

승인 게이팅: 요청 시점엔 상태만 저장(REQUESTED) → 승인 시점에만 실제 효과 반영 → 반려는 상태만 REJECTED
  대여: 승인 시 EQUIPMENT→RENTED (멀티테이블 UPDATE)
  연장: requested_return_date에 임시저장 → 승인 시 return_date로 반영
  신고: rental_id를 미리 저장해둠 → 승인 시 EQUIPMENT→BROKEN + RENTAL 삭제

카테고리: EQUIPMENT.category_id → CATEGORY.category_id (FK). SQL이 JOIN해서 이름으로 별칭 주므로
          JSP/컨트롤러는 여전히 "이름" 문자열만 다룸. FK가 사용중인 카테고리 삭제를 자동으로 막아줌.

새 관리자 URL 추가 시 잊지 말 것: dispatcher-servlet.xml의 AdminCheckInterceptor mvc:mapping에 등록

리다이렉트에 한글 등 비ASCII 값 붙일 때: URLEncoder.encode(value, "UTF-8") 필수 (Location 헤더는 라틴-1만 허용)

⚠ 고쳐야 할 것: context-transaction.xml pointcut (ReportServiceImpl.approveReport()가 실제 다중 테이블 작업 사례)
```
