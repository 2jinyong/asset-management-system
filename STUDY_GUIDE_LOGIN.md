# 전자정부프레임워크(eGovFramework) 로그인/회원가입 완전 정복 학습 가이드

> 이 문서 하나만 보면 로그인/회원가입 기능의 구조, 흐름, 각 파일의 역할을  
> 완벽하게 이해하고 혼자서 만들 수 있을 정도를 목표로 작성했습니다.

---

## 목차

1. [전체 아키텍처 - 레이어드 구조](#1-전체-아키텍처)
2. [HTTP 요청 처리 흐름 (전체 그림)](#2-http-요청-처리-흐름)
3. [파일별 역할과 연결 관계](#3-파일별-역할과-연결-관계)
4. [설정 파일 완전 해설](#4-설정-파일-완전-해설)
5. [Java 코드 계층별 완전 해설](#5-java-코드-계층별-완전-해설)
6. [MyBatis(SQL) 완전 해설](#6-mybatis-sql-완전-해설)
7. [JSP 완전 해설](#7-jsp-완전-해설)
8. [유효성 검증 이중 구조 — 프론트엔드 JS + 백엔드 Spring Validation](#8-유효성-검증-이중-구조)
9. [세션과 역할(Role) 기반 분기](#9-세션과-역할role-기반-분기)
10. [로그인 흐름 전체 추적 (Step-by-Step)](#10-로그인-흐름-전체-추적)
11. [회원가입 흐름 전체 추적 (Step-by-Step)](#11-회원가입-흐름-전체-추적)
12. [eGov 특유 개념 정리](#12-egov-특유-개념-정리)
13. [자주 만나는 오류와 해결책](#13-자주-만나는-오류와-해결책)

---

## 1. 전체 아키텍처

전자정부프레임워크는 **Spring MVC + MyBatis** 기반으로,  
코드를 4개 계층으로 분리합니다.

```
┌─────────────────────────────────────────────────────────┐
│                     브라우저 (사용자)                      │
│         GET /user/loginView.do, POST /user/login.do      │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP 요청
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Presentation Layer (화면 계층)               │
│  web.xml → DispatcherServlet → UserController.java       │
│  → JSP (login.jsp, register.jsp, main.jsp)               │
└──────────────────────┬──────────────────────────────────┘
                       │ 서비스 호출
                       ▼
┌─────────────────────────────────────────────────────────┐
│               Business Layer (비즈니스 계층)              │
│  UserService.java (인터페이스)                            │
│  UserServiceImpl.java (구현체) ← AOP 예외처리             │
└──────────────────────┬──────────────────────────────────┘
                       │ Mapper 호출
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Persistence Layer (데이터 계층)              │
│  UserMapper.java (인터페이스) + UserMapper.xml (SQL)      │
└──────────────────────┬──────────────────────────────────┘
                       │ JDBC
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Database — users 테이블                      │
└─────────────────────────────────────────────────────────┘
```

### 핵심 원칙: 각 계층은 바로 아래 계층에만 접근한다

- Controller → Service O, Mapper X (Controller가 Mapper를 직접 호출하면 안 됨)
- Service → Mapper O, Controller X
- Mapper → DB O

---

## 2. HTTP 요청 처리 흐름

브라우저에서 `/user/loginView.do` 를 입력했을 때 무슨 일이 일어나는가:

```
[1] 브라우저: GET /user/loginView.do
        │
        ▼
[2] web.xml: *.do 패턴에 매핑된 DispatcherServlet 이 요청 수신
        │
        ▼
[3] dispatcher-servlet.xml:
    HandlerMapping이 "/user/loginView.do" 에 맞는 컨트롤러 메서드를 찾음
        │  → UserController.loginView() 발견!
        ▼
[4] UserController.loginView():
    model.addAttribute("userVO", new UserVO());  ← JSP에 전달할 데이터 준비
    return "user/login";                          ← 뷰 이름 반환
        │
        ▼
[5] ViewResolver:
    prefix + "user/login" + suffix
    = "/WEB-INF/jsp/egovframework/asset/" + "user/login" + ".jsp"
    = "/WEB-INF/jsp/egovframework/asset/user/login.jsp"
        │
        ▼
[6] login.jsp 가 HTML로 변환되어 브라우저로 전송
```

---

## 3. 파일별 역할과 연결 관계

```
src/main/
├── java/egovframework/asset/
│   ├── cmmn/
│   │   ├── AssetExcepHndlr.java         ← AOP 예외 처리기
│   │   └── AssetOthersExcepHndlr.java   ← AOP 예외 처리기
│   └── user/
│       ├── service/
│       │   ├── UserVO.java              ← DB 한 행 = Java 객체 1개
│       │   ├── UserService.java         ← 비즈니스 인터페이스 (설계도)
│       │   ├── UserMapper.java          ← SQL 실행 인터페이스
│       │   └── impl/
│       │       └── UserServiceImpl.java ← 비즈니스 로직 실제 구현
│       └── web/
│           └── UserController.java      ← HTTP 요청 처리 + 뷰 반환
│
├── resources/
│   ├── db/
│   │   ├── db.properties               ← DB 접속 정보
│   │   └── asset_schema.sql            ← 테이블 생성 SQL (users 테이블)
│   └── egovframework/
│       ├── mapper/asset/
│       │   └── UserMapper.xml          ← 실제 SQL 쿼리
│       ├── sqlmap/asset/mappers/
│       │   └── sql-mapper-config.xml   ← MyBatis 전역 설정 (typeAlias)
│       └── spring/
│           ├── context-aspect.xml      ← AOP 예외 처리 설정
│           ├── context-common.xml      ← 컴포넌트 스캔, 메시지 소스
│           ├── context-datasource.xml  ← DB 연결 설정
│           ├── context-mapper.xml      ← MyBatis SqlSession 설정
│           └── context-transaction.xml ← 트랜잭션 설정
│
└── webapp/
    ├── index.jsp                       ← /user/loginView.do 로 forward
    ├── js/jquery.min.js
    ├── css/egovframework/bootstrap/
    └── WEB-INF/
        ├── web.xml                     ← DispatcherServlet 등록
        ├── config/egovframework/springmvc/
        │   └── dispatcher-servlet.xml  ← Spring MVC 설정
        └── jsp/egovframework/asset/
            ├── cmmn/egovError.jsp      ← 공통 에러 화면
            └── user/
                ├── login.jsp           ← 로그인 화면
                ├── register.jsp        ← 회원가입 화면 (사원번호 필수)
                ├── joinResult.jsp      ← 가입 완료 화면
                └── main.jsp            ← 역할 분기 메인 화면
```

### 파일 간 핵심 연결 고리

```
UserController.java
    @Resource(name = "userService")  ────────→ UserServiceImpl.java
                                                      │ @Service("userService")
                                               @Resource(name = "userMapper")
                                                      │
                                               UserMapper.java (@Mapper)
                                                      │ namespace 매핑
                                               UserMapper.xml (SQL)
                                                      │
                                                   DB (users 테이블)
```

---

## 4. 설정 파일 완전 해설

### 4-1. web.xml — 웹 앱의 뼈대

```xml
<!-- ① ContextLoaderListener: context-*.xml 파일을 읽어 Spring 루트 컨텍스트 생성 -->
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath*:egovframework/spring/context-*.xml</param-value>
</context-param>

<!-- ② DispatcherServlet: 모든 *.do 요청을 받아 컨트롤러에게 분배 -->
<servlet>
    <servlet-name>action</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>
<servlet-mapping>
    <servlet-name>action</servlet-name>
    <url-pattern>*.do</url-pattern>
</servlet-mapping>
```

**핵심:** `web.xml` = 서버 시작 시 제일 먼저 읽히는 파일. Spring 컨텍스트를 띄우고 DispatcherServlet을 등록한다.

### 4-2. dispatcher-servlet.xml — Spring MVC 설정

```xml
<!-- @Controller 어노테이션 클래스를 egovframework.asset 아래에서 자동 탐색 -->
<context:component-scan base-package="egovframework.asset">
    <context:include-filter type="annotation"
        expression="org.springframework.stereotype.Controller"/>
</context:component-scan>

<!-- 뷰 리졸버: return "user/login" → /WEB-INF/jsp/egovframework/asset/user/login.jsp -->
<bean class="org.springframework.web.servlet.view.UrlBasedViewResolver"
    p:prefix="/WEB-INF/jsp/egovframework/asset/"
    p:suffix=".jsp"/>
```

**ViewResolver 동작 원리:**
```
컨트롤러: return "user/login"
ViewResolver: prefix + 뷰이름 + suffix
            = "/WEB-INF/jsp/egovframework/asset/" + "user/login" + ".jsp"
            = "/WEB-INF/jsp/egovframework/asset/user/login.jsp"
```

### 4-3. context-mapper.xml — MyBatis 연결 설정

```xml
<!-- SqlSessionFactory: MyBatis ↔ DB 연결의 핵심 객체 -->
<bean id="sqlSession" class="org.mybatis.spring.SqlSessionFactoryBean">
    <property name="dataSource" ref="dataSource" />
    <!-- MyBatis 전역 설정 (typeAlias 등) -->
    <property name="configLocation"
        value="classpath:/egovframework/sqlmap/asset/mappers/sql-mapper-config.xml" />
    <!-- SQL XML 파일 위치 (하위 폴더 모두 스캔) -->
    <property name="mapperLocations"
        value="classpath:/egovframework/mapper/**/*.xml" />
</bean>

<!-- @Mapper 어노테이션 스캔 → UserMapper.java 를 자동으로 빈 등록 -->
<bean class="org.egovframe.rte.psl.dataaccess.mapper.MapperConfigurer">
    <property name="basePackage" value="egovframework.asset" />
</bean>
```

### 4-4. context-aspect.xml — AOP 예외 처리

```xml
<aop:config>
    <!-- UserServiceImpl 등 *Impl 클래스의 모든 메서드가 대상 -->
    <aop:pointcut id="serviceMethod"
        expression="execution(* egovframework.asset..impl.*Impl.*(..))" />
    <!-- 예외 발생 시 → AssetExcepHndlr.occur() 자동 실행 -->
    <aop:aspect ref="exceptionTransfer">
        <aop:after-throwing throwing="exception"
            pointcut-ref="serviceMethod" method="transfer" />
    </aop:aspect>
</aop:config>
```

**AOP 를 쓰는 이유:** 서비스 메서드마다 try-catch 를 반복하지 않아도 됨. 예외 처리 로직을 한 곳에 모아 관리.

---

## 5. Java 코드 계층별 완전 해설

### 5-1. UserVO.java — DB 한 행 = Java 객체

```java
@Data  // Lombok: getter/setter/toString 자동 생성
public class UserVO {
    private Long userId;          // DB: user_id  (PK, AUTO_INCREMENT)
    private String userName;      // DB: user_name
    private String email;         // DB: email    (UNIQUE, 로그인 아이디)
    private String password;      // DB: password
    private String employeeNumber;// DB: employee_number (필수)
    private String role;          // DB: role ("ADMIN" / "USER")
    private String useYn;         // DB: use_yn ("Y"=활성 / "N"=비활성)
    private LocalDateTime regDate;
    private LocalDateTime updateDate;
}
```

**DB 컬럼명 ↔ Java 필드명 자동 변환:**  
`sql-mapper-config.xml` 의 `mapUnderscoreToCamelCase=true` 덕분에  
`user_name(DB)` → `userName(Java)` 자동 변환. resultMap 없이도 매핑됨.

### 5-2. UserService.java — 인터페이스 (계약서)

```java
public interface UserService {
    int insertUser(UserVO userVO);  // 회원가입: 1=성공, 0=중복이메일
    UserVO login(UserVO userVO);    // 로그인: 성공 시 UserVO, 실패 시 null
}
```

**왜 인터페이스인가?**  
컨트롤러는 `UserService` 인터페이스에만 의존 → 구현체가 바뀌어도 컨트롤러 코드 수정 불필요.  
테스트 시 가짜 구현체(Mock)를 주입해 DB 없이 테스트 가능.

### 5-3. UserServiceImpl.java — 비즈니스 로직

```java
@Service("userService")  // Spring 빈 이름 = "userService"
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService {

    @Resource(name = "userMapper")
    private UserMapper userMapper;

    @Override
    public int insertUser(UserVO userVO) {
        // 1. 이메일 중복 체크
        if (userMapper.selectUserByEmail(userVO.getEmail()) != null) return 0;
        // 2. 기본값 설정
        userVO.setRole("USER");
        userVO.setUseYn("Y");
        // 3. DB 저장
        return userMapper.insertUser(userVO);
    }

    @Override
    public UserVO login(UserVO userVO) {
        UserVO findUser = userMapper.selectUserByEmail(userVO.getEmail());
        if (findUser == null) return null;                          // 이메일 없음
        if (!findUser.getPassword().equals(userVO.getPassword())) return null; // 비번 불일치
        return findUser;  // 성공
    }
}
```

**`EgovAbstractServiceImpl` 상속 이유:**  
eGov의 공통 예외 처리 메커니즘에 편입됨. `context-aspect.xml` 의 AOP가 이 클래스에 자동 적용됨.

### 5-4. UserMapper.java — SQL 연결 인터페이스

```java
@Mapper("userMapper")  // eGov @Mapper: "userMapper" 이름으로 Spring 빈 등록
public interface UserMapper {
    int insertUser(UserVO userVO);           // UserMapper.xml <insert id="insertUser">
    UserVO selectUserByEmail(String email);  // UserMapper.xml <select id="selectUserByEmail">
}
```

**중요 — eGov @Mapper vs MyBatis @Mapper:**
- eGov: `org.egovframe.rte.psl.dataaccess.mapper.Mapper` ← 이 프로젝트에서 사용
- MyBatis: `org.apache.ibatis.annotations.Mapper` ← 다른 패키지!

### 5-5. UserController.java — 요청/응답 처리

```java
@Controller
@RequestMapping("/user")
public class UserController {

    @Resource(name = "userService")
    private UserService userService;

    // [GET /user/loginView.do] 로그인 화면
    @GetMapping("/loginView.do")
    public String loginView(Model model) {
        model.addAttribute("userVO", new UserVO());  // <form:form> 바인딩용
        return "user/login";
    }

    // [POST /user/login.do] 로그인 처리
    @PostMapping("/login.do")
    public String login(@ModelAttribute("userVO") UserVO userVO,
                        HttpSession session, Model model) {
        UserVO loginUser = userService.login(userVO);
        if (loginUser != null) {
            session.setAttribute("loginUser", loginUser);  // 세션 저장
            return "redirect:/user/main.do";               // PRG 패턴
        }
        model.addAttribute("errorMsg", "이메일 또는 비밀번호가 올바르지 않습니다.");
        return "user/login";
    }

    // [GET /user/registerView.do] 회원가입 화면
    @GetMapping("/registerView.do")
    public String registerView(@ModelAttribute("userVO") UserVO userVO) {
        return "user/register";
    }

    // [POST /user/register.do] 회원가입 처리
    @PostMapping("/register.do")
    public String register(@ModelAttribute("userVO") UserVO userVO, Model model) {
        int result = userService.insertUser(userVO);
        if (result == 1) {
            model.addAttribute("userName", userVO.getUserName());
            return "user/joinResult";
        }
        model.addAttribute("errorMsg", "이미 사용 중인 이메일입니다.");
        return "user/register";
    }

    // [GET /user/main.do] 메인 화면 (세션 체크 + 역할 분기는 JSP에서)
    @GetMapping("/main.do")
    public String main(HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/user/loginView.do";  // 미로그인 차단
        model.addAttribute("loginUser", loginUser);
        return "user/main";
    }

    // [GET /user/logout.do] 로그아웃
    @GetMapping("/logout.do")
    public String logout(HttpSession session) {
        session.invalidate();  // 세션 전체 삭제
        return "redirect:/user/loginView.do";
    }
}
```

**주요 어노테이션 정리:**

| 어노테이션 | 역할 |
|-----------|------|
| `@Controller` | 이 클래스가 컨트롤러임을 Spring에 알림 |
| `@RequestMapping("/user")` | 클래스 레벨 URL 접두사 |
| `@GetMapping("/loginView.do")` | GET 요청만 처리 |
| `@PostMapping("/login.do")` | POST 요청만 처리 |
| `@ModelAttribute("userVO")` | 폼 파라미터 → UserVO 자동 바인딩 + Model 자동 등록 |
| `@Resource(name="...")` | 이름으로 Spring 빈 주입 |

**`return "redirect:..."` vs `return "뷰이름"` 차이:**

```
return "user/login"
  → 현재 요청에서 바로 login.jsp 렌더링 (Forward)
  → URL 은 여전히 POST URL → 새로고침 시 폼 재전송 문제!

return "redirect:/user/main.do"
  → 브라우저에게 "이 URL로 다시 GET 요청해라" (HTTP 302)
  → 새로고침해도 안전 (PRG 패턴 = Post-Redirect-Get)
```

---

## 6. MyBatis(SQL) 완전 해설

### 6-1. sql-mapper-config.xml — MyBatis 전역 설정

```xml
<configuration>
    <settings>
        <!-- user_name(DB) → userName(Java) 자동 변환 -->
        <setting name="mapUnderscoreToCamelCase" value="true" />
    </settings>
    <typeAliases>
        <!-- "egovframework.asset.user.service.UserVO" 대신 "userVO" 로 쓸 수 있게 -->
        <typeAlias alias="userVO" type="egovframework.asset.user.service.UserVO"/>
    </typeAliases>
</configuration>
```

### 6-2. UserMapper.xml — SQL 쿼리

```xml
<!-- namespace = UserMapper.java 인터페이스 경로와 반드시 일치 -->
<mapper namespace="egovframework.asset.user.service.UserMapper">

    <!-- id = UserMapper.java 의 insertUser() 메서드명과 일치 -->
    <insert id="insertUser" parameterType="userVO">
        INSERT INTO users (user_name, email, password, employee_number, role, use_yn)
        VALUES (#{userName}, #{email}, #{password}, #{employeeNumber}, #{role}, #{useYn})
    </insert>

    <!-- 로그인용 조회: 이메일 + 활성계정(use_yn='Y') 조건 -->
    <select id="selectUserByEmail" parameterType="String" resultType="userVO">
        SELECT user_id, user_name, email, password, employee_number,
               role, use_yn, reg_date, update_date
        FROM users
        WHERE email = #{email}
          AND use_yn = 'Y'
    </select>

</mapper>
```

**`#{}` 파라미터 바인딩 이해:**
```
String email 전달 시:  WHERE email = #{email}
                                       ↑ 파라미터 변수명과 일치

UserVO 객체 전달 시:  VALUES (#{userName}, #{email})
                               ↑ UserVO.getUserName(), UserVO.getEmail() 자동 호출
```

**`resultType="userVO"` 가 객체를 만드는 과정:**
```
DB 조회 결과: user_id=1, user_name="홍길동", email="hong@test.com"
              ↓ mapUnderscoreToCamelCase=true 자동 변환
              userId=1, userName="홍길동", email="hong@test.com"
              ↓ UserVO setter 자동 호출
              new UserVO() { userId=1, userName="홍길동", ... }
```

### 6-3. users 테이블 구조 (asset_schema.sql)

```sql
CREATE TABLE IF NOT EXISTS `users` (
    user_id         BIGINT       NOT NULL AUTO_INCREMENT,  -- PK, 자동증가
    user_name       VARCHAR(50)  NOT NULL,                 -- 이름
    email           VARCHAR(100) NOT NULL UNIQUE,          -- 이메일(로그인 ID), 중복 불가
    password        VARCHAR(255) NOT NULL,                 -- 비밀번호 (실무: BCrypt 암호화)
    employee_number VARCHAR(20)  NOT NULL,                 -- 사원번호 (필수)
    role            VARCHAR(20)  NOT NULL DEFAULT 'USER',  -- 권한 (ADMIN / USER)
    use_yn          CHAR(1)      NOT NULL DEFAULT 'Y',     -- Y=활성, N=비활성
    reg_date        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    update_date     DATETIME     ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);
```

> ⚠ **테이블명을 `user` 가 아닌 `users` 로 사용하는 이유:**  
> `user` 는 MySQL/MariaDB에서 시스템 예약어입니다.  
> `users` 로 쓰면 충돌 없이 안전하게 사용할 수 있습니다.

---

## 7. JSP 완전 해설

### 7-1. 핵심 태그 라이브러리

```jsp
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>    ← JSTL 기본
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %> ← Spring 폼
```

### 7-2. EL 표현식 (Expression Language)

```jsp
${userName}                        ← Model 의 "userName" 값 출력
${loginUser.userName}              ← loginUser 객체의 getUserName() 출력
${sessionScope.loginUser.userName} ← 세션에서 직접 꺼내서 출력
${not empty errorMsg}              ← errorMsg 가 null/빈문자열이 아니면 true
```

### 7-3. JSTL 제어 태그

```jsp
<%-- if 문 --%>
<c:if test="${not empty errorMsg}">
    <div class="alert alert-danger">${errorMsg}</div>
</c:if>

<%-- if-else if-else 문 --%>
<c:choose>
    <c:when test="${loginUser.role == 'ADMIN'}">관리자 메뉴</c:when>
    <c:otherwise>일반사용자 메뉴</c:otherwise>
</c:choose>

<%-- for 반복 (목록 출력) --%>
<c:forEach var="item" items="${itemList}" varStatus="status">
    ${status.index + 1}. ${item.name}
</c:forEach>

<%-- URL 생성 (컨텍스트 경로 자동 처리) --%>
<c:url value='/user/loginView.do'/>
```

### 7-4. Spring form 태그

```jsp
<%--
  modelAttribute="userVO"
  → 컨트롤러에서 model.addAttribute("userVO", new UserVO()) 로 전달한 객체와 연결
  → 이 이름과 Model에 담긴 이름이 반드시 일치해야 함!
  
  action 에 ${pageContext.request.contextPath} 를 쓰는 이유:
  → 앱이 /asset-management-system/ 같은 컨텍스트 경로로 배포될 때
  → 절대 경로만 쓰면 컨텍스트 경로가 빠져서 URL이 틀려짐
--%>
<form:form action="${pageContext.request.contextPath}/user/login.do"
           method="post" modelAttribute="userVO">

    <%-- path="email" → UserVO.email 필드와 연결 --%>
    <form:input path="email" cssClass="form-control"/>

    <%-- form:password 는 type="password" 자동 적용 --%>
    <form:password path="password" cssClass="form-control"/>

</form:form>
```

**왜 `<form:form>` 을 쓰는가?**  
유효성 오류로 폼을 다시 보여줄 때, 이전에 입력한 값이 자동으로 채워짐.  
일반 `<form>` 태그는 이 기능이 없어서 입력값이 모두 사라짐.

### 7-5. 회원가입 폼 — 사원번호 필수 처리 (JS 유효성 검사)

```javascript
$('#registerForm').on('submit', function (e) {
    const userName  = $('#userName').val().trim();   // .trim() = 앞뒤 공백 제거
    const email     = $('#email').val().trim();
    const password  = $('#password').val();
    const pwConfirm = $('#passwordConfirm').val();
    const employee  = $('#employeeNumber').val().trim();

    // 이름 필수
    if (userName.length === 0) {
        alert('이름을 입력해주세요.'); $('#userName').focus();
        e.preventDefault(); return;
    }
    // 이메일 형식
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        alert('올바른 이메일 형식을 입력해주세요.'); $('#email').focus();
        e.preventDefault(); return;
    }
    // 비밀번호 일치
    if (password !== pwConfirm) {
        alert('비밀번호가 일치하지 않습니다.'); $('#passwordConfirm').focus();
        e.preventDefault(); return;
    }
    // 사원번호 필수 ← 추가됨
    if (employee.length === 0) {
        alert('사원번호를 입력해주세요.'); $('#employeeNumber').focus();
        e.preventDefault(); return;
    }
});
```

> **`.trim()` 을 쓰는 이유:**  
> `"   "` (공백만 있는 경우) 도 길이가 0이 아니라 그냥 통과되기 때문.  
> `.trim()` 으로 앞뒤 공백을 제거한 뒤 길이를 체크해야 실제로 입력이 없는지 정확히 판단 가능.

---

## 8. 유효성 검증 이중 구조

### 8-1. 왜 이중 검증이 필요한가?

```
[프론트엔드 JS 검증만 있을 때의 문제]

정상 사용자:  브라우저 → JS 검증 → 서버 전송    (정상 흐름)
악의적 사용자: 브라우저 → JS 끔 → 서버에 직접 빈값/이상한값 전송 가능!

개발자 도구(F12) → Network 탭 → XHR로 직접 POST 요청 → JS 검증 완전 우회

결론: JS 검증은 UX(사용자 경험) 향상용, 실제 보안은 서버에서 해야 한다.
```

### 8-2. 이중 검증 흐름

```
사용자 폼 입력 → 가입하기 클릭
         │
         ▼
[1단계] JS 유효성 검사 (register.jsp jQuery 코드)
         - 이름 빈값 체크 (.trim().length === 0)
         - 이메일 형식 정규식 검사
         - 비밀번호 8자 미만 체크
         - 비밀번호 확인 일치 여부
         - 사원번호 빈값 체크 (.trim().length === 0)
         ↓ 실패: alert() + e.preventDefault() → 폼 제출 중단
         ↓ 성공: POST /user/register.do 서버 전송
         │
         ▼
[2단계] Spring Validation 서버 검증 (UserController + UserVO 어노테이션)
         - UserVO 의 @NotBlank, @Email, @Size 어노테이션 검사
         - @Valid 파라미터 → Spring이 자동으로 검증 실행
         - 결과가 BindingResult 에 저장됨
         ↓ 실패: bindingResult.hasErrors() == true
         │         → return "user/register"
         │         → JSP의 <form:errors> 가 오류 메시지 출력
         │         → Spring form 태그가 이전 입력값 자동 복원
         ↓ 성공: 서비스 호출 → DB 저장
```

### 8-3. Spring Validation 구성 요소

#### ① pom.xml — 의존성 추가
```xml
<!-- Bean Validation API: @NotBlank, @Email 등 어노테이션 제공 -->
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
    <version>2.0.1.Final</version>
</dependency>
<!-- Hibernate Validator: 실제 검증 실행 엔진 (Bean Validation 구현체) -->
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.2.5.Final</version>
</dependency>
```

#### ② dispatcher-servlet.xml — `<mvc:annotation-driven/>` 필수

```xml
<!-- 이 설정이 있어야 @Valid 가 자동으로 작동함 -->
<!-- Hibernate Validator 가 classpath 에 있으면 Bean Validation 자동 활성화 -->
<mvc:annotation-driven/>
```

**왜 `<mvc:annotation-driven/>` 이 필요한가?**
```
기존: RequestMappingHandlerAdapter 를 수동으로 빈 등록
     → Bean Validation 연결 안 됨 (수동 설정 필요)

변경: <mvc:annotation-driven/> 사용
     → RequestMappingHandlerAdapter 를 Spring이 올바르게 자동 구성
     → classpath 에 Hibernate Validator 발견 → Bean Validation 자동 연결
     → @Valid 어노테이션이 즉시 동작
```

#### ③ UserVO.java — 검증 어노테이션

```java
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@NotBlank(message = "이름을 입력해주세요.")
private String userName;

@NotBlank(message = "이메일을 입력해주세요.")
@Email(message = "올바른 이메일 형식이 아닙니다.")
private String email;

@NotBlank(message = "비밀번호를 입력해주세요.")
@Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
private String password;

@NotBlank(message = "사원번호를 입력해주세요.")
private String employeeNumber;
```

**주요 어노테이션 비교:**

| 어노테이션 | null | `""` | `"   "` | 용도 |
|-----------|------|------|---------|------|
| `@NotNull` | ❌ 실패 | ✅ 통과 | ✅ 통과 | 객체 null 체크 |
| `@NotEmpty` | ❌ 실패 | ❌ 실패 | ✅ 통과 | 컬렉션/배열 빈값 체크 |
| `@NotBlank` | ❌ 실패 | ❌ 실패 | ❌ 실패 | **문자열 필수 입력** (권장) |
| `@Email` | ✅ 통과 | ✅ 통과 | - | 이메일 형식 (@NotBlank 와 함께) |
| `@Size(min=8)` | ✅ 통과 | ❌ 실패 | ❌ 실패 | 길이 범위 |

> **@NotBlank 를 쓰는 이유:**  
> 사용자가 스페이스바만 입력해도 `"   "` 는 `@NotEmpty` 를 통과합니다.  
> `@NotBlank` 는 공백만 있는 문자열도 거부하므로 가장 안전합니다.

#### ④ UserController.java — @Valid + BindingResult

```java
@PostMapping("/register.do")
public String register(
        @Valid @ModelAttribute("userVO") UserVO userVO,  // ← @Valid: 검증 실행
        BindingResult bindingResult,                      // ← 반드시 @Valid 바로 다음!
        Model model) {

    if (bindingResult.hasErrors()) {
        // 검증 실패 → 폼으로 되돌아감
        // Spring form 태그가 이전 입력값을 자동으로 복원
        return "user/register";
    }
    // 검증 성공 → 서비스 호출
    ...
}
```

**BindingResult 위치가 중요한 이유:**
```java
// ✅ 올바른 순서: @Valid 파라미터 바로 다음에 BindingResult
public String register(@Valid @ModelAttribute UserVO userVO,
                       BindingResult bindingResult, ...)

// ❌ 잘못된 순서: BindingResult 위치가 다른 파라미터 뒤에 있으면
//   검증 실패 시 Spring 이 직접 예외를 던져버림
public String register(@Valid @ModelAttribute UserVO userVO,
                       Model model,
                       BindingResult bindingResult)  // ← 여기 두면 안 됨!
```

#### ⑤ register.jsp — form:errors 태그

```jsp
<%-- form:input 아래에 form:errors 를 배치 --%>
<form:input path="userName" id="userName" cssClass="form-control"/>
<form:errors path="userName" cssClass="text-danger small d-block mt-1"/>
<%--
  - path="userName"    : UserVO.userName 필드의 오류 메시지 표시
  - cssClass           : 출력되는 <span> 태그에 적용할 CSS
  - text-danger        : Bootstrap 빨간색
  - small d-block mt-1 : 작은 글씨, 블록 표시, 위 여백
  - 오류 없으면 아무것도 출력하지 않음 (태그 자체가 사라짐)
--%>
```

**form:errors 와 Spring form 태그의 시너지:**
```
검증 실패 시 register() → return "user/register"
JSP 렌더링 시:
  <form:input path="userName">    → 이전에 입력한 값이 자동으로 채워짐
  <form:errors path="userName">   → "@NotBlank 실패 시 message" 가 출력됨

일반 <input> 태그였다면?
  → 이전 입력값 사라짐 (사용자가 다시 입력해야 함)
  → 오류 메시지 수동으로 model 에 담아서 출력해야 함
```

### 8-4. 로그인에 @Valid 를 안 쓰는 이유

```java
// 로그인 폼은 email + password 만 전송
// UserVO 에 @NotBlank 가 userName, employeeNumber 에도 붙어있음
// @Valid 를 쓰면 userName, employeeNumber 가 빈값이라 항상 검증 실패!

// 해결 방법 3가지:
// 1. (현재 방법) 로그인에는 @Valid 안 쓰고 수동 빈값 체크
// 2. (고급)  Validation Groups 사용 — @NotBlank(groups=RegisterGroup.class)
// 3. (고급)  로그인용 별도 VO 클래스 (LoginVO) 를 만들어서 분리

// 현재 이 프로젝트: 방법 1 사용 (가장 단순, 학습용으로 적합)
if (email == null || email.trim().isEmpty()) {
    model.addAttribute("errorMsg", "이메일과 비밀번호를 모두 입력해주세요.");
    return "user/login";
}
```

---

## 9. 세션과 역할(Role) 기반 분기

### 8-1. 세션이란?

```
서버 메모리에 사용자별로 저장되는 공간입니다.
브라우저가 열려 있는 동안 (또는 세션 타임아웃 전까지) 유지됩니다.

로그인 성공 → session.setAttribute("loginUser", loginUser)
다른 페이지 → session.getAttribute("loginUser") 로 꺼내서 사용
로그아웃 → session.invalidate() 로 세션 전체 삭제
```

### 8-2. 세션 저장과 꺼내기

```java
// [컨트롤러: 세션에 저장]
session.setAttribute("loginUser", loginUser);  // 로그인 시

// [컨트롤러: 세션에서 꺼내기]
UserVO loginUser = (UserVO) session.getAttribute("loginUser");
if (loginUser == null) return "redirect:/user/loginView.do"; // 미로그인 차단

// [JSP: Model을 통해 꺼내기 (컨트롤러가 model.addAttribute 한 경우)]
${loginUser.userName}

// [JSP: 세션에서 직접 꺼내기]
${sessionScope.loginUser.userName}
```

### 8-3. 역할(Role) 기반 화면 분기 — main.jsp

```jsp
<c:choose>
    <%-- loginUser.role == "ADMIN" 이면 관리자 화면 --%>
    <c:when test="${loginUser.role == 'ADMIN'}">
        <div>관리자 대시보드 — 비품 관리, 사용자 관리 등</div>
    </c:when>

    <%-- 그 외 (USER 등) 이면 일반사용자 화면 (병합 예정) --%>
    <c:otherwise>
        <div>일반사용자 화면 — 병합 예정</div>
    </c:otherwise>
</c:choose>
```

**역할 값이 어디서 오는가:**
```
회원가입 시 → UserServiceImpl.insertUser() 에서 userVO.setRole("USER") 고정
로그인 시   → DB에서 조회한 UserVO.role 값 그대로 사용
세션 저장   → session.setAttribute("loginUser", loginUser)
JSP 출력   → ${loginUser.role} 으로 꺼내서 c:choose 로 분기
```

**관리자 계정 만드는 방법:**
```sql
-- DB에서 직접 role 을 'ADMIN' 으로 설정
INSERT INTO users (user_name, email, password, employee_number, role, use_yn)
VALUES ('시스템관리자', 'admin@company.com', 'admin1234', 'ADM001', 'ADMIN', 'Y');

-- 또는 기존 계정의 role 변경
UPDATE users SET role = 'ADMIN' WHERE email = 'hong@test.com';
```

### 8-4. 팀 협업을 위한 main.jsp 구조

```
main.jsp
  ├── 공통 네비게이션 (역할에 따라 색상 다름)
  ├── c:when test="role == 'ADMIN'"
  │     └── 관리자 영역 (이 브랜치 담당 - 개발 예정)
  └── c:otherwise
        └── 일반사용자 영역 (형 브랜치 담당 - 병합 예정)

Git 병합 시:
  - 관리자 영역은 이 브랜치(feature/login-jinyong)에서 개발
  - 사용자 영역은 팀원 브랜치에서 개발
  - 나중에 main.jsp 를 GitHub에서 병합
```

---

## 10. 로그인 흐름 전체 추적

```
[사용자] 브라우저에 /user/loginView.do 입력

Step 1  web.xml: *.do → DispatcherServlet 수신
Step 2  dispatcher-servlet.xml: "/user/loginView.do" → UserController.loginView() 매핑
Step 3  UserController.loginView():
          model.addAttribute("userVO", new UserVO())
          return "user/login"
Step 4  ViewResolver: → /WEB-INF/jsp/.../user/login.jsp 렌더링
Step 5  login.jsp HTML 브라우저 전송

[사용자] 이메일/비밀번호 입력 후 로그인 버튼 클릭

Step 6  POST /user/login.do 전송
Step 7  UserController.login():
          @ModelAttribute → UserVO { email="hong@test.com", password="1234" } 자동 생성
Step 8  userService.login(userVO) 호출
Step 9  UserServiceImpl.login():
          userMapper.selectUserByEmail("hong@test.com") 호출
Step 10 MyBatis: UserMapper.xml selectUserByEmail SQL 실행
          SELECT ... FROM users WHERE email='hong@test.com' AND use_yn='Y'
Step 11 결과 처리:
          조회 안 됨 → null 반환
          비번 불일치 → null 반환
          일치 → UserVO 반환
Step 12 UserController.login() 복귀:
          null(실패) → model.addAttribute("errorMsg", "...") + return "user/login"
          UserVO(성공) → session.setAttribute("loginUser", loginUser)
                       + return "redirect:/user/main.do"

Step 13 (성공 시) GET /user/main.do 자동 요청
Step 14 UserController.main():
          session.getAttribute("loginUser") 확인 (있으면 통과)
          model.addAttribute("loginUser", loginUser)
          return "user/main"
Step 15 main.jsp:
          ${loginUser.role} 값으로 c:choose 분기
          ADMIN → 관리자 대시보드 표시
          USER  → 일반사용자 영역 표시
```

---

## 11. 회원가입 흐름 전체 추적

```
Step 1  GET /user/registerView.do → UserController.registerView()
          @ModelAttribute("userVO") → 빈 UserVO 객체 model에 자동 추가
          return "user/register" → register.jsp 렌더링

Step 2  사용자 입력: 이름, 이메일, 비밀번호, 비번확인, 사원번호(필수)
        jQuery 유효성 검사:
          - .trim() 으로 공백 제거 후 빈값 체크
          - 이메일 형식 정규식 검사
          - 비밀번호 확인 일치 여부
          - 사원번호 필수 체크
        통과하면 POST /user/register.do 전송

Step 3  UserController.register():
          @ModelAttribute → UserVO { userName, email, password, employeeNumber } 자동 생성

Step 4  userService.insertUser(userVO) 호출

Step 5  UserServiceImpl.insertUser():
          1. selectUserByEmail(email) → 중복 이메일 체크
             있으면 → return 0
          2. userVO.setRole("USER"), userVO.setUseYn("Y") 기본값 설정
          3. userMapper.insertUser(userVO) → DB INSERT

Step 6  MyBatis: UserMapper.xml insertUser SQL 실행
          INSERT INTO users (user_name, email, password, employee_number, role, use_yn)
          VALUES ('홍길동', 'hong@test.com', '1234', 'E001', 'USER', 'Y')

Step 7  UserController.register() 복귀:
          0(중복) → model.addAttribute("errorMsg", "...") + return "user/register"
          1(성공) → model.addAttribute("userName", "홍길동") + return "user/joinResult"

Step 8  joinResult.jsp: "${userName}님, 환영합니다!" 출력
```

---

## 12. eGov 특유 개념 정리

### 순수 Spring vs eGovFramework 비교

| 항목 | 순수 Spring | eGovFramework |
|------|------------|---------------|
| Mapper 어노테이션 | `@Mapper` (MyBatis, ibatis 패키지) | `@Mapper` (eGov, rte 패키지) |
| Mapper 등록 방식 | `@MapperScan` | `MapperConfigurer` bean |
| Service 상속 | 없음 | `EgovAbstractServiceImpl` 상속 |
| 예외 처리 | 직접 try-catch | AOP `context-aspect.xml` 자동 처리 |

### 컴포넌트 스캔 범위 이해

```
context-common.xml     → egovframework 전체 스캔 (@Controller 제외)
                           @Service("userService"), @Mapper("userMapper") 등록

dispatcher-servlet.xml → egovframework.asset 스캔 (@Controller 만)
                           @Controller (UserController) 등록

결합 결과:
  UserController(@Controller)   → dispatcher 컨텍스트에 등록
  UserServiceImpl(@Service)     → root 컨텍스트에 등록
  UserMapper(@Mapper)           → root 컨텍스트에 등록
```

---

## 13. 자주 만나는 오류와 해결책

### 오류 1: "No qualifying bean of type 'UserService'"
```
원인: @Service 없거나 component-scan 범위 밖
확인: UserServiceImpl 에 @Service("userService") 있는가?
      context-common.xml 의 base-package 올바른가?
```

### 오류 2: "Invalid bound statement: UserMapper.insertUser"
```
원인: Mapper 인터페이스 ↔ XML 연결 안 됨
확인: UserMapper.xml namespace = "egovframework.asset.user.service.UserMapper" 맞는가?
      메서드명 = XML id 일치하는가?
      context-mapper.xml 의 mapperLocations 경로 맞는가?
```

### 오류 3: "Neither BindingResult nor plain target object for bean name 'userVO'"
```
원인: <form:form modelAttribute="userVO"> 에서 "userVO" 를 Model 에서 못 찾음
해결: GET 핸들러에서 반드시 model.addAttribute("userVO", new UserVO()) 추가
```

### 오류 4: "Table 'users' doesn't exist"
```
해결: src/main/resources/db/asset_schema.sql 을 DB에서 실행
     (테이블명: users 주의 — user 아님!)
```

### 오류 5: 새로고침 시 폼 재전송 경고
```
원인: 로그인 성공 후 redirect 없이 return "user/main" 사용
해결: 반드시 return "redirect:/user/main.do" (PRG 패턴)
```

### 오류 6: 역할(role) 분기가 안 됨
```
원인: session 에 loginUser 가 없거나, role 값이 다름
확인: DB users 테이블에 role = 'ADMIN' (대문자) 로 저장되어 있는가?
      JSP: ${loginUser.role == 'ADMIN'} (대소문자 일치)
      관리자 계정: INSERT 시 role='ADMIN' 또는 UPDATE 로 변경
```

---

## 요약: 핵심 연결 고리 암기 카드

```
┌────────────────────────────────────────────────────────────┐
│ URL 요청 → Controller → Service → Mapper → DB              │
│                                                            │
│ @GetMapping    @Service      @Mapper    <select id="...">  │
│ @PostMapping   @Resource     @Resource  parameterType      │
│ return "뷰"    implements    메서드명=id  resultType        │
└────────────────────────────────────────────────────────────┘

설정 파일 역할 한 줄 요약:
  web.xml              → DispatcherServlet 등록, context-*.xml 로드
  dispatcher-servlet   → @Controller 스캔, ViewResolver prefix/suffix
  context-common       → @Service/@Repository 스캔
  context-mapper       → SqlSession 설정, @Mapper 스캔
  context-aspect       → AOP 예외 처리 (서비스 Impl 대상)

세션 3단계:
  저장: session.setAttribute("loginUser", loginUser)
  조회: (UserVO) session.getAttribute("loginUser")
  삭제: session.invalidate()

역할 분기:
  서비스에서 setRole("USER") / DB에서 role='ADMIN'
  JSP: <c:when test="${loginUser.role == 'ADMIN'}">
  컨트롤러: session.getAttribute 후 role 확인 가능

테이블명: users (user 는 MySQL 예약어라 충돌 위험)
사원번호: 필수 필드 (JS .trim() 후 빈값 체크)
```
