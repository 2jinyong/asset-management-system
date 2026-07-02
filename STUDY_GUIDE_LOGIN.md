# 전자정부프레임워크(eGovFramework) 완전 정복 학습 가이드

> 이 문서 하나만 보면 Spring 핵심 개념부터 eGovFramework 특유 구조, AOP 예외처리,
> MyBatis, JSP, 세션까지 이 프로젝트에서 사용하는 모든 것을 이해할 수 있도록 작성했습니다.
> Spring을 완전히 마스터하지 않은 상태에서 읽어도 이해할 수 있게 기초부터 설명합니다.

---

## 목차

1. [Spring의 핵심 철학 — IoC와 DI](#1-spring의-핵심-철학--ioc와-di)
2. [Bean이란 무엇인가](#2-bean이란-무엇인가)
3. [두 개의 Spring 컨텍스트 — Root vs Servlet](#3-두-개의-spring-컨텍스트--root-vs-servlet)
4. [전체 아키텍처 — 레이어드 구조](#4-전체-아키텍처--레이어드-구조)
5. [HTTP 요청 처리 흐름 (전체 그림)](#5-http-요청-처리-흐름-전체-그림)
6. [설정 파일 완전 해설](#6-설정-파일-완전-해설)
7. [AOP 완전 정복 — context-aspect.xml](#7-aop-완전-정복--context-aspectxml)
8. [트랜잭션 완전 해설 — context-transaction.xml](#8-트랜잭션-완전-해설--context-transactionxml)
9. [Filter vs Interceptor — 요청을 가로채는 두 가지 방법](#9-filter-vs-interceptor--요청을-가로채는-두-가지-방법)
10. [Java 코드 계층별 완전 해설](#10-java-코드-계층별-완전-해설)
11. [MyBatis 완전 해설](#11-mybatis-완전-해설)
12. [JSP 완전 해설](#12-jsp-완전-해설)
13. [유효성 검증 이중 구조 — JS + Spring Validation](#13-유효성-검증-이중-구조--js--spring-validation)
14. [세션과 역할(Role) 기반 분기](#14-세션과-역할role-기반-분기)
15. [로그인 흐름 전체 추적 (Step-by-Step)](#15-로그인-흐름-전체-추적-step-by-step)
16. [회원가입 흐름 전체 추적 (Step-by-Step)](#16-회원가입-흐름-전체-추적-step-by-step)
17. [eGov 특유 개념 정리](#17-egov-특유-개념-정리)
18. [파일별 역할과 연결 관계](#18-파일별-역할과-연결-관계)
19. [자주 만나는 오류와 해결책](#19-자주-만나는-오류와-해결책)

---

## 1. Spring의 핵심 철학 — IoC와 DI

### IoC (Inversion of Control, 제어의 역전)

Spring을 이해하려면 먼저 "제어의 역전"이 무슨 뜻인지 알아야 합니다.

**일반적인 프로그래밍 (제어의 역전 없음):**
```java
// 내가 직접 객체를 생성하고 조립한다
public class UserController {
    private UserService userService;

    public UserController() {
        // 개발자가 직접 생성
        UserMapper userMapper = new UserMapperImpl();
        this.userService = new UserServiceImpl(userMapper);
    }
}
```

문제점: `UserController`가 `UserServiceImpl`과 `UserMapperImpl`을 직접 알아야 한다.
나중에 `UserServiceImpl`을 다른 구현체로 교체하면 `UserController` 코드도 바꿔야 한다.

**Spring 방식 (IoC 적용):**
```java
// 객체 생성과 조립을 Spring이 알아서 한다
@Controller
public class UserController {
    @Resource(name = "userService")
    private UserService userService;  // Spring이 알아서 넣어준다
}
```

Spring(IoC 컨테이너)이 객체를 만들고, 의존 관계를 연결하고, 생명주기를 관리한다.
개발자는 "어떻게 만들지"를 신경 쓰지 않고 "무엇을 쓸지"만 선언하면 된다.

이것이 **제어의 역전**: 객체 생성의 제어권이 개발자 → Spring으로 넘어간다.

---

### DI (Dependency Injection, 의존성 주입)

IoC를 구현하는 구체적인 방법이 DI다.
"내가 필요한 객체를 외부(Spring)에서 주입받는다"는 개념.

**의존성이란?**
```java
// UserController는 UserService 없이 동작 불가능
// = UserController는 UserService에 의존한다
public class UserController {
    private UserService userService;  // 이게 "의존성"
}
```

**DI의 3가지 방식:**

```java
// 방식 1: 필드 주입 (이 프로젝트에서 사용하는 방식)
@Controller
public class UserController {
    @Resource(name = "userService")
    private UserService userService;  // Spring이 필드에 직접 주입
}

// 방식 2: 생성자 주입 (현재 Spring 공식 권장 방식)
@Controller
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {  // 생성자 파라미터로 주입
        this.userService = userService;
    }
}

// 방식 3: 세터 주입
@Controller
public class UserController {
    private UserService userService;

    @Autowired
    public void setUserService(UserService userService) {
        this.userService = userService;
    }
}
```

이 프로젝트는 `@Resource(name="...")` 방식을 사용한다.

---

### @Resource vs @Autowired vs @Inject 차이

| 어노테이션 | 패키지 | 주입 기준 | 출처 |
|-----------|--------|----------|------|
| `@Autowired` | Spring | **타입**(Type) 기준 | Spring 전용 |
| `@Resource` | Java EE (javax) | **이름**(Name) 기준, 없으면 타입 | Java 표준 |
| `@Inject` | Java EE (javax) | 타입 기준 | Java 표준 |

```java
// @Autowired: UserService 타입의 빈을 찾아서 주입
// 같은 타입의 빈이 2개 이상이면 오류 발생
@Autowired
private UserService userService;

// @Resource(name="userService"): 이름이 "userService"인 빈을 찾아서 주입
// 이름으로 정확히 지정하므로 모호성 없음 ← 이 프로젝트 방식
@Resource(name = "userService")
private UserService userService;
```

**이 프로젝트가 `@Resource(name="...")` 을 쓰는 이유:**
eGovFramework 관례상 빈에 명시적 이름을 부여하고(`@Service("userService")`),
그 이름으로 주입받는 패턴을 권장한다. 어떤 빈이 주입되는지 코드만 봐도 명확하다.

---

## 2. Bean이란 무엇인가

**Bean = Spring이 생성하고 관리하는 객체**

일반 Java 객체와 Bean의 차이:
```java
// 일반 Java 객체: 개발자가 new로 직접 생성
UserService svc = new UserServiceImpl();

// Bean: Spring이 생성하고 ApplicationContext에 등록한 객체
// 개발자는 그냥 @Resource / @Autowired 로 꺼내 쓰기만 한다
```

### Bean 등록 방법 2가지

**방법 1: XML에 직접 등록 (설정 파일 방식)**
```xml
<!-- context-aspect.xml 에서 이 방식 사용 -->
<bean id="assetHandler" class="egovframework.asset.cmmn.AssetExcepHndlr" />
```
`id`가 빈 이름, `class`가 실제 클래스.

**방법 2: 어노테이션으로 자동 등록 (컴포넌트 스캔 방식)**
```java
@Service("userService")      // 이름이 "userService"인 Bean으로 등록
public class UserServiceImpl { ... }

@Controller                  // 이름이 "userController"(소문자 시작)인 Bean으로 등록
public class UserController { ... }
```
이 방식은 `<context:component-scan>` 설정이 있어야 작동한다.

### 어노테이션별 용도 구분

| 어노테이션 | 계층 | 역할 |
|-----------|------|------|
| `@Controller` | Presentation | HTTP 요청 처리, Spring MVC에서만 인식 |
| `@Service` | Business | 비즈니스 로직, AOP 적용 대상 |
| `@Repository` | Persistence | DB 접근, 예외 변환 기능 포함 |
| `@Component` | 공통 | 위 3개에 해당하지 않는 범용 Bean |

기능적으로는 4개 모두 Bean 등록이라는 점에서 동일하다.
다만 의미론적 구분(어느 계층인지 표시)과 Spring 내부 처리에서 차이가 있다.

---

## 3. 두 개의 Spring 컨텍스트 — Root vs Servlet

이 프로젝트에는 **Spring 컨텍스트가 두 개** 존재한다. 이것을 모르면 구조가 계속 헷갈린다.

```
┌──────────────────────────────────────────────────────────┐
│              Root ApplicationContext (부모)               │
│  ContextLoaderListener가 서버 시작 시 생성                │
│  context-*.xml 파일들을 읽어서 구성                       │
│                                                          │
│  ✅ 등록되는 Bean들:                                      │
│    @Service (UserServiceImpl)                            │
│    @Mapper  (UserMapper)                                 │
│    dataSource, txManager, sqlSession                     │
│    exceptionTransfer, messageSource 등                   │
└──────────────────┬───────────────────────────────────────┘
                   │ 자식 컨텍스트는 부모의 Bean을 참조 가능
                   │ (부모는 자식을 모른다)
                   ▼
┌──────────────────────────────────────────────────────────┐
│           Servlet ApplicationContext (자식)               │
│  DispatcherServlet이 초기화 시 생성                       │
│  dispatcher-servlet.xml 파일을 읽어서 구성               │
│                                                          │
│  ✅ 등록되는 Bean들:                                      │
│    @Controller (UserController)                          │
│    ViewResolver, LocaleResolver, ExceptionResolver       │
└──────────────────────────────────────────────────────────┘
```

### 왜 둘로 나누는가?

| 구분 | Root Context | Servlet Context |
|------|-------------|-----------------|
| 목적 | 앱 전체 공용 비즈니스 로직 | 웹 요청 처리 전용 |
| 생성 시점 | 서버 시작 (`ContextLoaderListener`) | DispatcherServlet 초기화 |
| 설정 파일 | `context-*.xml` | `dispatcher-servlet.xml` |
| 접근 방향 | 자식에서 부모 참조 O | 부모에서 자식 참조 X |

컨트롤러는 서비스 Bean을 `@Resource`로 주입받을 수 있다.
반대로 서비스에서 컨트롤러를 주입받으려 하면 오류 난다(그럴 일도 없어야 한다).

### web.xml에서 두 컨텍스트 설정 위치

```xml
<!-- ① Root Context: ContextLoaderListener가 context-*.xml 읽어서 생성 -->
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath*:egovframework/spring/context-*.xml</param-value>
</context-param>
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<!-- ② Servlet Context: DispatcherServlet이 dispatcher-servlet.xml 읽어서 생성 -->
<servlet>
    <servlet-name>action</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/config/egovframework/springmvc/dispatcher-servlet.xml</param-value>
    </init-param>
</servlet>
```

---

## 4. 전체 아키텍처 — 레이어드 구조

전자정부프레임워크는 **Spring MVC + MyBatis** 기반으로 코드를 4개 계층으로 분리한다.

```
┌─────────────────────────────────────────────────────────┐
│                     브라우저 (사용자)                     │
│         GET /user/loginView.do, POST /user/login.do      │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP 요청
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Presentation Layer (화면 계층)               │
│  web.xml → DispatcherServlet → UserController.java       │
│  → JSP (login.jsp, register.jsp, joinResult.jsp)         │
└──────────────────────┬──────────────────────────────────┘
                       │ 서비스 호출
                       ▼
┌─────────────────────────────────────────────────────────┐
│               Business Layer (비즈니스 계층)              │
│  UserService.java (인터페이스)                            │
│  UserServiceImpl.java (구현체) ← AOP 예외처리 자동 적용  │
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
│              Database — users 테이블 (MySQL)              │
└─────────────────────────────────────────────────────────┘
```

### 핵심 원칙: 각 계층은 바로 아래 계층에만 접근한다

```
Controller → Service   O  (컨트롤러가 서비스를 호출)
Controller → Mapper    X  (컨트롤러가 Mapper를 직접 호출하면 안 됨)
Service    → Mapper    O  (서비스가 Mapper를 호출)
Service    → Controller X
Mapper     → DB        O
```

이 규칙을 지키면 각 계층을 독립적으로 수정하거나 테스트할 수 있다.

---

## 5. HTTP 요청 처리 흐름 (전체 그림)

브라우저에서 `/user/loginView.do`를 입력했을 때 무슨 일이 일어나는가:

```
[1] 브라우저: GET /user/loginView.do
        │
        ▼
[2] web.xml:
    *.do 패턴에 매핑된 DispatcherServlet이 요청 수신
    (Filter가 먼저 동작: 인코딩 처리, HTML 태그 필터링)
        │
        ▼
[3] DispatcherServlet 내부:
    HandlerMapping이 "/user/loginView.do"에 맞는 컨트롤러를 찾음
    → @RequestMapping("/user") + @GetMapping("/loginView.do")
    → UserController.loginView() 발견!
        │
        ▼
[4] (Interceptor 동작: preHandle 실행)
        │
        ▼
[5] UserController.loginView():
    model.addAttribute("userVO", new UserVO())
    return "user/login"   ← 뷰 이름만 반환 (JSP 경로가 아님!)
        │
        ▼
[6] ViewResolver:
    prefix + 뷰이름 + suffix
    = "/WEB-INF/jsp/egovframework/asset/" + "user/login" + ".jsp"
    = "/WEB-INF/jsp/egovframework/asset/user/login.jsp"
        │
        ▼
[7] login.jsp가 HTML로 변환되어 브라우저로 전송
```

---

## 6. 설정 파일 완전 해설

### 6-1. web.xml — 웹 앱의 뼈대

서버(Tomcat)가 처음 시작할 때 제일 먼저 읽는 파일이다.
Spring과 무관한 서블릿 표준 설정 파일이다.

```xml
<!-- ① 인코딩 필터: 한글 깨짐 방지. *.do 요청의 인코딩을 UTF-8로 강제 변환 -->
<filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    <init-param>
        <param-name>encoding</param-name>
        <param-value>utf-8</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>*.do</url-pattern>
</filter-mapping>

<!-- ② HTML 태그 필터: XSS(크로스사이트스크립팅) 공격 방어
     사용자가 <script>alert('해킹')</script> 같은 입력을 하면 무력화 -->
<filter>
    <filter-name>HTMLTagFilter</filter-name>
    <filter-class>org.egovframe.rte.ptl.mvc.filter.HTMLTagFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>HTMLTagFilter</filter-name>
    <url-pattern>*.do</url-pattern>
</filter-mapping>

<!-- ③ Root ApplicationContext 생성
     context-*.xml 파일들을 읽어서 @Service, @Mapper, dataSource 등을 빈으로 등록 -->
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath*:egovframework/spring/context-*.xml</param-value>
</context-param>
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<!-- ④ DispatcherServlet: 모든 *.do 요청을 받아 컨트롤러에 분배
     load-on-startup=1: 서버 시작 시 즉시 초기화 (숫자가 낮을수록 먼저) -->
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
    <url-pattern>*.do</url-pattern>   ← .do 로 끝나는 모든 URL을 DispatcherServlet이 처리
</servlet-mapping>

<!-- ⑤ 시작 페이지: / 로 접근 시 index.jsp → /user/loginView.do 로 포워드 -->
<welcome-file-list>
    <welcome-file>index.jsp</welcome-file>
</welcome-file-list>
```

---

### 6-2. dispatcher-servlet.xml — Spring MVC 설정 (Servlet Context)

```xml
<!-- ① Spring MVC 어노테이션 일괄 활성화
     @Controller, @RequestMapping, @Valid, @ModelAttribute 등이 동작하게 됨
     Bean Validation (Hibernate Validator)도 자동 연결됨 -->
<mvc:annotation-driven/>

<!-- ② Servlet Context에서 @Controller 클래스만 스캔
     @Service, @Repository는 Root Context(context-common.xml)에서 스캔하므로 제외 -->
<context:component-scan base-package="egovframework.asset">
    <context:include-filter type="annotation"
        expression="org.springframework.stereotype.Controller"/>
    <context:exclude-filter type="annotation"
        expression="org.springframework.stereotype.Service"/>
    <context:exclude-filter type="annotation"
        expression="org.springframework.stereotype.Repository"/>
</context:component-scan>

<!-- ③ 인터셉터: LocaleChangeInterceptor
     URL에 ?language=ko 파라미터를 붙이면 언어 변경됨 -->
<mvc:interceptors>
    <mvc:interceptor>
        <mvc:mapping path="/**"/>
        <bean class="org.springframework.web.servlet.i18n.LocaleChangeInterceptor">
            <property name="paramName" value="language"/>
        </bean>
    </mvc:interceptor>
</mvc:interceptors>

<!-- ④ LocaleResolver: 선택한 언어를 세션에 저장 (브라우저 닫을 때까지 유지) -->
<bean id="localeResolver" class="org.springframework.web.servlet.i18n.SessionLocaleResolver"/>

<!-- ⑤ Spring MVC 예외 처리: 예외 종류에 따라 보여줄 JSP를 매핑
     DataAccessException 발생 → cmmn/dataAccessFailure.jsp 렌더링
     뷰 이름은 ViewResolver가 WEB-INF/jsp/egovframework/asset/ + 이름 + .jsp 로 변환 -->
<bean class="org.springframework.web.servlet.handler.SimpleMappingExceptionResolver">
    <property name="defaultErrorView" value="cmmn/egovError"/>
    <property name="exceptionMappings">
        <props>
            <prop key="org.springframework.dao.DataAccessException">cmmn/dataAccessFailure</prop>
            <prop key="org.springframework.transaction.TransactionException">cmmn/transactionFailure</prop>
            <prop key="org.egovframe.rte.fdl.cmmn.exception.EgovBizException">cmmn/egovError</prop>
        </props>
    </property>
</bean>

<!-- ⑥ ViewResolver: 컨트롤러가 return "user/login" 하면 실제 JSP 경로로 변환
     prefix + 뷰이름 + suffix = /WEB-INF/jsp/egovframework/asset/user/login.jsp -->
<bean class="org.springframework.web.servlet.view.UrlBasedViewResolver"
      p:order="1"
      p:viewClass="org.springframework.web.servlet.view.JstlView"
      p:prefix="/WEB-INF/jsp/egovframework/asset/"
      p:suffix=".jsp"/>
```

---

### 6-3. context-common.xml — Root Context 공통 설정

```xml
<!-- ① @Controller 제외하고 egovframework 패키지 전체 스캔
     @Service(UserServiceImpl), @Mapper(UserMapper) 등이 Root Context에 빈으로 등록됨
     @Controller는 Servlet Context(dispatcher-servlet.xml)에서 처리하므로 여기서 제외 -->
<context:component-scan base-package="egovframework">
    <context:exclude-filter type="annotation"
        expression="org.springframework.stereotype.Controller" />
</context:component-scan>

<!-- ② MessageSource: 다국어 메시지 관리
     message-common.properties 파일에서 메시지 코드→텍스트 변환
     JSP에서 <spring:message code="title.login"/> 형태로 사용 -->
<bean id="messageSource"
    class="org.springframework.context.support.ReloadableResourceBundleMessageSource">
    <property name="basenames">
        <list>
            <value>classpath:/egovframework/message/message-common</value>
        </list>
    </property>
    <property name="cacheSeconds" value="60"/>  ← 60초마다 파일 다시 읽음 (재시작 불필요)
</bean>

<!-- ③ LeaveaTrace + traceHandlerService: eGov 내부 추적 로그 시스템
     예외 발생 시 스택 트레이스를 로그에 기록하는 eGov 전용 인프라 -->
<bean id="leaveaTrace" class="org.egovframe.rte.fdl.cmmn.trace.LeaveaTrace">
    ...
</bean>

<!-- ④ antPathMater: Ant 스타일 경로 패턴 매처
     context-aspect.xml 의 AOP 패턴 매칭에 사용 -->
<bean id="antPathMater" class="org.springframework.util.AntPathMatcher" />
```

---

### 6-4. context-datasource.xml — DB 연결 설정

```xml
<!-- ① properties 파일 로드: db/db.properties 에서 ${jdbc.driver} 등 변수 읽어옴 -->
<context:property-placeholder location="classpath:db/db.properties" />

<!-- ② BasicDataSource: 커넥션 풀(Connection Pool) 설정
     커넥션 풀이란: DB 연결을 미리 여러 개 만들어 놓고 재사용하는 기술.
     매 요청마다 DB 연결을 새로 맺으면 시간이 걸리므로 미리 풀에 담아둔다.
     destroy-method="close": 앱 종료 시 풀에 있는 모든 연결 닫음 -->
<bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource"
      destroy-method="close">
    <property name="driverClassName" value="${jdbc.driver}"/>   ← db.properties 값
    <property name="url" value="${jdbc.url}"/>
    <property name="username" value="${jdbc.username}"/>
    <property name="password" value="${jdbc.password}"/>
</bean>
```

**db.properties 파일 예시:**
```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/asset_db?useSSL=false&serverTimezone=Asia/Seoul
jdbc.username=root
jdbc.password=1234
```

---

### 6-5. context-mapper.xml — MyBatis 연결 설정

```xml
<!-- ① SqlSessionFactoryBean: MyBatis의 핵심 팩토리 객체
     MyBatis가 DB와 통신하는 방법(드라이버, SQL 위치 등)을 알려주는 설정 -->
<bean id="sqlSession" class="org.mybatis.spring.SqlSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>           ← 위에서 만든 dataSource 주입
    <property name="configLocation"
        value="classpath:/egovframework/sqlmap/asset/mappers/sql-mapper-config.xml"/>
    <property name="mapperLocations"
        value="classpath:/egovframework/mapper/**/*.xml"/>   ← SQL XML 파일 위치 (하위 모두)
</bean>

<!-- ② MapperConfigurer: @Mapper 어노테이션 스캔 → 빈으로 자동 등록
     UserMapper.java에 @Mapper 붙어있으면 "userMapper" 이름의 빈이 자동 생성됨 -->
<bean class="org.egovframe.rte.psl.dataaccess.mapper.MapperConfigurer">
    <property name="basePackage" value="egovframework.asset"/>
</bean>
```

---

## 7. AOP 완전 정복 — context-aspect.xml

### AOP란 무엇인가

AOP(Aspect-Oriented Programming, 관점 지향 프로그래밍)는
**여러 클래스에 공통으로 필요한 코드를 한 곳에 모아서 자동으로 적용**하는 기법이다.

**AOP가 없다면:**
```java
// UserServiceImpl.java
public int insertUser(UserVO userVO) {
    try {
        return userMapper.insertUser(userVO);
    } catch (Exception e) {
        logger.error("insertUser 오류: " + e.getMessage());  // 반복되는 코드!
        throw new EgovBizException("가입 실패");
    }
}

public UserVO login(UserVO userVO) {
    try {
        return userMapper.selectUserByEmail(userVO.getEmail());
    } catch (Exception e) {
        logger.error("login 오류: " + e.getMessage());      // 또 반복!
        throw new EgovBizException("로그인 실패");
    }
}
// 메서드가 100개면 try-catch를 100번 써야 한다...
```

**AOP를 사용하면:**
```java
// UserServiceImpl.java — 비즈니스 로직만!
public int insertUser(UserVO userVO) {
    return userMapper.insertUser(userVO);  // 깔끔!
}

public UserVO login(UserVO userVO) {
    return userMapper.selectUserByEmail(userVO.getEmail());  // 깔끔!
}
// 예외 처리는 AOP가 알아서 한다
```

---

### AOP 핵심 용어 6개

```
┌─────────────────────────────────────────────────────────────────┐
│ Target (대상 객체)                                               │
│   AOP를 적용받는 실제 비즈니스 로직 클래스                        │
│   이 프로젝트: UserServiceImpl                                   │
├─────────────────────────────────────────────────────────────────┤
│ JoinPoint (결합 지점)                                            │
│   AOP가 끼어들 수 있는 지점 (메서드 호출 전, 후, 예외 발생 시 등) │
│   이 프로젝트: UserServiceImpl의 모든 메서드 호출 시점            │
├─────────────────────────────────────────────────────────────────┤
│ Pointcut (포인트컷)                                              │
│   JoinPoint들 중 실제로 AOP를 적용할 지점을 골라내는 표현식       │
│   이 프로젝트: execution(* egovframework.asset..impl.*Impl.*(..))│
├─────────────────────────────────────────────────────────────────┤
│ Advice (어드바이스)                                              │
│   Pointcut에 매칭된 지점에서 실행할 실제 코드 (무엇을 할 것인가) │
│   이 프로젝트: exceptionTransfer.transfer()                      │
├─────────────────────────────────────────────────────────────────┤
│ Aspect (애스펙트)                                                │
│   Pointcut + Advice의 묶음 = AOP 모듈 하나                      │
│   이 프로젝트: context-aspect.xml 의 <aop:aspect ref="...">     │
├─────────────────────────────────────────────────────────────────┤
│ Weaving (위빙)                                                   │
│   Aspect를 Target에 실제로 적용하는 과정                          │
│   Spring은 런타임에 Proxy 객체를 만들어서 Weaving을 수행한다      │
└─────────────────────────────────────────────────────────────────┘
```

---

### Advice 종류 5가지

```java
// @Before: 메서드 실행 전에 실행
@Before("execution(* egovframework.asset..impl.*Impl.*(..))")
public void before(JoinPoint jp) {
    System.out.println("메서드 실행 전: " + jp.getSignature().getName());
}

// @AfterReturning: 메서드가 정상적으로 종료된 후 실행
@AfterReturning(pointcut="...", returning="result")
public void afterReturning(Object result) {
    System.out.println("정상 반환값: " + result);
}

// @AfterThrowing: 메서드에서 예외가 발생했을 때 실행  ← 이 프로젝트에서 사용!
@AfterThrowing(throwing="exception", pointcut-ref="serviceMethod")
public void transfer(Exception exception) {
    // 예외 발생 시 이 코드가 자동으로 실행됨
}

// @After: 메서드 종료 후 항상 실행 (정상/예외 모두)
@After("...")
public void after() { ... }

// @Around: 메서드 실행 전/후 모두 제어 (가장 강력)
@Around("...")
public Object around(ProceedingJoinPoint pjp) throws Throwable {
    // 전처리
    Object result = pjp.proceed();  // 실제 메서드 실행
    // 후처리
    return result;
}
```

---

### Pointcut 표현식 읽는 법

```
execution(* egovframework.asset..impl.*Impl.*(..))
           │ └──────────────────────┘└─────┘└──┘└──┘
           │              │             │     │   │
           │         패키지 경로        │     │   └─ 파라미터: (..) = 모든 파라미터
           │      (..은 하위패키지 포함) │     └─── 메서드명: * = 모든 메서드
           │                           └───────── 클래스명: *Impl = Impl로 끝나는 모든 클래스
           └─ 반환타입: * = 모든 타입
```

해석: `egovframework.asset` 패키지 아래 어느 하위 패키지에 있든,
이름이 `Impl`로 끝나는 클래스의, 어떤 메서드든, 어떤 파라미터든, 어떤 반환 타입이든
→ 모두 AOP 적용 대상.

---

### 이 프로젝트의 AOP 예외 처리 전체 흐름

```xml
<!-- context-aspect.xml -->
<aop:config>
    <!-- 1. Pointcut: Impl로 끝나는 클래스의 모든 메서드 -->
    <aop:pointcut id="serviceMethod"
        expression="execution(* egovframework.asset..impl.*Impl.*(..))" />

    <!-- 2. Advice 종류: after-throwing = 예외 발생 시에만 실행
         exceptionTransfer 빈의 transfer() 메서드를 호출 -->
    <aop:aspect ref="exceptionTransfer">
        <aop:after-throwing throwing="exception"
            pointcut-ref="serviceMethod"
            method="transfer" />
    </aop:aspect>
</aop:config>

<!-- 3. exceptionTransfer: eGov 제공 ExceptionTransfer 클래스
     예외를 받아서 등록된 핸들러들에게 순서대로 전달 -->
<bean id="exceptionTransfer" class="org.egovframe.rte.fdl.cmmn.aspect.ExceptionTransfer">
    <property name="exceptionHandlerService">
        <list>
            <ref bean="defaultExceptionHandleManager" />
            <ref bean="otherExceptionHandleManager" />
        </list>
    </property>
</bean>

<!-- 4. 핸들러 매니저: **service.impl.* 패턴에 매칭되면 assetHandler 호출 -->
<bean id="defaultExceptionHandleManager"
    class="org.egovframe.rte.fdl.cmmn.exception.manager.DefaultExceptionHandleManager">
    <property name="patterns">
        <list><value>**service.impl.*</value></list>
    </property>
    <property name="handlers">
        <list><ref bean="assetHandler"/></list>
    </property>
</bean>

<!-- 5. 실제 핸들러: 우리가 만든 클래스 -->
<bean id="assetHandler" class="egovframework.asset.cmmn.AssetExcepHndlr"/>
```

**이 흐름을 코드 레벨로 추적하면:**

```
UserServiceImpl.insertUser() 에서 예외 발생
        │
        ▼ (AOP 프록시가 가로챔, @AfterThrowing)
ExceptionTransfer.transfer(exception, "egovframework.asset.user.service.impl.UserServiceImpl")
        │
        ▼ (패키지명이 **service.impl.* 에 매칭?)
        ├─ defaultExceptionHandleManager: 매칭 → AssetExcepHndlr.occur() 호출
        │       → LOGGER.debug("AssetExcepHndlr - 예외 발생: " + ex.getMessage())
        └─ otherExceptionHandleManager:  매칭 → AssetOthersExcepHndlr.occur() 호출
                → LOGGER.debug("AssetOthersExcepHndlr - 예외 발생: " + ex.getMessage())
        │
        ▼
예외가 다시 위로 전파됨 (AOP는 예외를 삼키지 않음)
        │
        ▼
SimpleMappingExceptionResolver가 예외 종류에 따라 cmmn/egovError.jsp 렌더링
```

**AssetExcepHndlr.java가 하는 일:**
```java
// 지금은 로그만 찍는다. 추후 슬랙 알림, DB 오류 기록 등으로 확장 가능
public class AssetExcepHndlr implements ExceptionHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(AssetExcepHndlr.class);

    @Override
    public void occur(Exception ex, String packageName) {
        LOGGER.debug("AssetExcepHndlr - 예외 발생: {}", ex.getMessage());
        // {} 는 SLF4J 포맷 플레이스홀더: ex.getMessage() 값이 {} 위치에 삽입됨
        // String.format("... %s", ex.getMessage()) 와 같은 효과
        // 차이점: {} 방식은 로그 레벨이 DEBUG 이하일 때만 문자열을 조합 → 성능 유리
    }
}
```

### Spring AOP의 Proxy 동작 원리

AOP가 어떻게 메서드 호출을 "가로채는지" 이해하면 전체 그림이 명확해진다.

```
Spring이 UserServiceImpl을 빈으로 등록할 때:
1. 원본 UserServiceImpl 객체 생성
2. AOP Pointcut이 적용되는 클래스임을 감지
3. 원본을 감싸는 Proxy 객체 생성
4. 컨테이너에는 Proxy 객체를 등록

UserController가 @Resource로 주입받는 것은 UserServiceImpl이 아니라 Proxy다!

UserController.login() 호출
        │
        ▼
Proxy.login() 호출 (사용자는 이 사실을 모름)
        │
        ├─ (예외 없으면) 원본 UserServiceImpl.login() 실행 후 결과 반환
        └─ (예외 발생) AfterThrowing Advice(transfer()) 실행 → 예외 재전파
```

---

## 8. 트랜잭션 완전 해설 — context-transaction.xml

### 트랜잭션이란

트랜잭션 = **여러 DB 작업을 하나의 단위로 묶는 것**
모두 성공하거나, 하나라도 실패하면 모두 취소(롤백)된다.

```
예: 송금 기능
  1. A 계좌에서 10만원 출금 (UPDATE)
  2. B 계좌에 10만원 입금 (UPDATE)

  1번 성공 + 2번 실패 → 1번을 롤백해야 함 (돈이 사라지면 안 됨!)
  트랜잭션이 없으면 이런 상황에서 데이터 정합성이 깨진다.
```

### context-transaction.xml 분석

```xml
<!-- txManager: DataSourceTransactionManager = JDBC 기반 트랜잭션 관리자
     dataSource를 통해 트랜잭션의 begin/commit/rollback을 제어 -->
<bean id="txManager"
    class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource"/>
</bean>

<!-- txAdvice: 어떤 조건에서 트랜잭션을 적용할지 정의
     name="*": 모든 메서드에 트랜잭션 적용
     rollback-for="Exception": Exception 계열 예외 발생 시 롤백 -->
<tx:advice id="txAdvice" transaction-manager="txManager">
    <tx:attributes>
        <tx:method name="*" rollback-for="Exception"/>
    </tx:attributes>
</tx:advice>

<!-- ⚠ 버그: pointcut 경로가 이 프로젝트와 맞지 않음! -->
<aop:config>
    <aop:pointcut id="requiredTx"
        expression="execution(* egovframework.example.sample..impl.*Impl.*(..))"/>
    <!--                              ^^^^^^^^^^^^^^^^^^^^^^
        이 프로젝트 패키지는 egovframework.asset 인데
        egovframework.example.sample 을 가리키고 있다!
        즉, 트랜잭션이 실제로 이 프로젝트에 적용되지 않고 있다. -->
    <aop:advisor advice-ref="txAdvice" pointcut-ref="requiredTx"/>
</aop:config>
```

**⚠ 현재 이 프로젝트의 트랜잭션 설정은 동작하지 않는다.**
나중에 아래와 같이 수정해야 한다:
```xml
<aop:pointcut id="requiredTx"
    expression="execution(* egovframework.asset..impl.*Impl.*(..))"/>
```

지금은 단순 INSERT/SELECT만 하고 있어서 문제가 드러나지 않지만,
"이메일 중복체크 후 INSERT"처럼 두 DB 작업을 하나로 묶어야 할 때 문제가 생길 수 있다.

---

## 9. Filter vs Interceptor — 요청을 가로채는 두 가지 방법

비슷해 보이지만 동작 위치와 목적이 다르다.

```
브라우저 요청
      │
      ▼
┌─────────────────────────┐
│     Filter (web.xml)    │  ← 서블릿 컨테이너(Tomcat) 레벨
│  CharacterEncodingFilter│    Spring을 모름. 순수 Java EE 표준.
│  HTMLTagFilter          │    모든 요청/응답을 처리 가능
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│   DispatcherServlet     │  ← Spring 진입점
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  Interceptor            │  ← Spring MVC 레벨
│  (dispatcher-servlet)   │    Spring Context를 알고 Bean 주입 가능
│  LocaleChangeInterceptor│    *.do 요청만 처리 가능
└────────────┬────────────┘
             │
             ▼
        Controller
```

| 구분 | Filter | Interceptor |
|------|--------|-------------|
| 위치 | 서블릿 컨테이너 | Spring MVC |
| 설정 위치 | `web.xml` | `dispatcher-servlet.xml` |
| Spring Bean 접근 | X (불가능) | O (가능) |
| 적용 범위 | 모든 요청 (정적 파일 포함) | DispatcherServlet을 통한 요청만 |
| 용도 | 인코딩, 보안 필터, 로깅 | 로그인 체크, 권한 검증 |

**이 프로젝트의 Filter:**
```
CharacterEncodingFilter → 한글 인코딩 UTF-8 강제
HTMLTagFilter           → XSS 방어 (HTML 태그 입력 차단)
```

**이 프로젝트의 Interceptor:**
```
LocaleChangeInterceptor → ?language=ko 파라미터로 언어 전환
```

---

## 10. Java 코드 계층별 완전 해설

### 10-1. UserVO.java — DB 한 행 = Java 객체

```java
@Data  // Lombok: getter/setter/toString/equals/hashCode 자동 생성
public class UserVO {
    private Long userId;           // DB: user_id  (PK, AUTO_INCREMENT)
    private String userName;       // DB: user_name
    private String email;          // DB: email    (UNIQUE, 로그인 아이디)
    private String password;       // DB: password
    private String employeeNumber; // DB: employee_number
    private String role;           // DB: role ("ADMIN" / "USER")
    private String useYn;          // DB: use_yn ("Y"=활성 / "N"=비활성)
    private LocalDateTime regDate;
    private LocalDateTime updateDate;

    // @Data가 없었다면 이걸 다 직접 써야 한다:
    // public Long getUserId() { return userId; }
    // public void setUserId(Long userId) { this.userId = userId; }
    // ... (모든 필드마다 반복)
}
```

**DB 컬럼명 ↔ Java 필드명 자동 변환:**
`sql-mapper-config.xml`의 `mapUnderscoreToCamelCase=true` 덕분에
`user_name(DB 스네이크케이스)` → `userName(Java 카멜케이스)` 자동 변환.
resultMap 없이도 매핑된다.

---

### 10-2. UserService.java — 인터페이스 (계약서)

```java
public interface UserService {
    int insertUser(UserVO userVO);  // 회원가입: 1=성공, 0=중복이메일
    UserVO login(UserVO userVO);    // 로그인: 성공 시 UserVO, 실패 시 null
}
```

**왜 인터페이스를 만드는가?**

컨트롤러는 `UserService` 인터페이스에만 의존한다.
구현체가 `UserServiceImpl`이든 다른 클래스든 컨트롤러는 신경 쓰지 않는다.

```
UserController → UserService (인터페이스)
                     ↑
             UserServiceImpl (구현체)  ← Spring이 알아서 연결

나중에 UserServiceV2로 교체해도 UserController 코드는 수정 불필요.
테스트 시 가짜 구현체(Mock)를 주입해 DB 없이 테스트 가능.
```

---

### 10-3. UserServiceImpl.java — 비즈니스 로직

```java
@Service("userService")  // Spring 빈 이름 = "userService"
// EgovAbstractServiceImpl 상속: eGov AOP 예외처리 메커니즘에 편입됨
// context-aspect.xml의 Pointcut(*Impl.*)이 이 클래스를 감지함
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService {

    @Resource(name = "userMapper")  // "userMapper" 이름의 빈 주입
    private UserMapper userMapper;

    @Override
    public int insertUser(UserVO userVO) {
        // 1. 이메일 중복 체크: 이미 있으면 0 반환
        if (userMapper.selectUserByEmail(userVO.getEmail()) != null) return 0;

        // 2. 기본값 설정: 회원가입은 무조건 USER, 활성 계정
        userVO.setRole("USER");
        userVO.setUseYn("Y");

        // 3. DB 저장: INSERT 성공 시 1 반환
        return userMapper.insertUser(userVO);
    }

    @Override
    public UserVO login(UserVO userVO) {
        UserVO findUser = userMapper.selectUserByEmail(userVO.getEmail());
        if (findUser == null) return null;                               // 이메일 없음
        if (!findUser.getPassword().equals(userVO.getPassword())) return null; // 비번 불일치
        return findUser;  // 성공: DB에서 조회한 전체 정보 반환
    }
}
```

---

### 10-4. UserMapper.java — SQL 실행 인터페이스

```java
// eGov @Mapper: "userMapper" 이름으로 Spring 빈 등록
// 이 인터페이스를 구현하는 클래스는 없다! MyBatis가 XML을 보고 자동으로 만들어준다.
@Mapper("userMapper")
public interface UserMapper {
    int insertUser(UserVO userVO);           // UserMapper.xml <insert id="insertUser">
    UserVO selectUserByEmail(String email);  // UserMapper.xml <select id="selectUserByEmail">
}
```

**중요 — eGov @Mapper vs MyBatis @Mapper (완전히 다른 것!):**
```java
import org.egovframe.rte.psl.dataaccess.mapper.Mapper;  // eGov (이 프로젝트)
import org.apache.ibatis.annotations.Mapper;             // 순수 MyBatis (다른 패키지)
```
둘 다 @Mapper라는 이름이지만 패키지가 다르다. 혼동 금지.

---

### 10-5. UserController.java — HTTP 요청/응답 처리

```java
@Controller                  // Spring MVC 컨트롤러 Bean
@RequestMapping("/user")     // 클래스 레벨: 이 컨트롤러의 모든 URL은 /user로 시작
public class UserController {

    @Resource(name = "userService")
    private UserService userService;

    // [GET /user/loginView.do] 로그인 화면 보여주기
    @GetMapping("/loginView.do")
    public String loginView(Model model) {
        // <form:form modelAttribute="userVO"> 태그가 이 객체를 참조함
        // 빈 UserVO를 model에 넣어야 JSP에서 오류 안 남
        model.addAttribute("userVO", new UserVO());
        return "user/login";  // ViewResolver → /WEB-INF/jsp/.../user/login.jsp
    }

    // [POST /user/login.do] 로그인 처리
    @PostMapping("/login.do")
    public String login(@ModelAttribute("userVO") UserVO userVO,
                        HttpSession session, Model model) {
        // @ModelAttribute: 폼 파라미터(email, password)를 UserVO에 자동 바인딩
        // email 파라미터 → userVO.setEmail() 자동 호출
        UserVO loginUser = userService.login(userVO);

        if (loginUser != null) {
            session.setAttribute("loginUser", loginUser);  // 세션에 사용자 정보 저장
            return "redirect:/user/main.do";               // PRG 패턴 (새로고침 중복 방지)
        }
        model.addAttribute("errorMsg", "이메일 또는 비밀번호가 올바르지 않습니다.");
        return "user/login";  // 실패: 로그인 화면 다시 렌더링
    }

    // [GET /user/registerView.do] 회원가입 화면
    @GetMapping("/registerView.do")
    public String registerView(@ModelAttribute("userVO") UserVO userVO) {
        // @ModelAttribute가 파라미터에 붙으면:
        // 1. 빈 UserVO 생성
        // 2. model.addAttribute("userVO", userVO) 자동 실행
        // → model.addAttribute 직접 안 해도 됨 (loginView와 같은 결과)
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

    // [GET /user/main.do] 메인 화면
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

### @ModelAttribute 동작 상세

```
POST /user/login.do 요청 시 body:
  email=hong%40test.com&password=1234

@ModelAttribute("userVO") UserVO userVO 처리 과정:
  1. new UserVO() 생성
  2. "email" 파라미터 → userVO.setEmail("hong@test.com") 자동 호출
  3. "password" 파라미터 → userVO.setPassword("1234") 자동 호출
  4. model.addAttribute("userVO", userVO) 자동 실행 (JSP에서 ${userVO.email} 가능)

결과: userVO = { email="hong@test.com", password="1234" }
```

### return "redirect:..." vs return "뷰이름" 차이

```
return "user/login"
  → Forward (내부 이동)
  → 현재 요청에서 바로 login.jsp 렌더링
  → 브라우저 URL: POST /user/login.do 그대로 (바뀌지 않음)
  → 새로고침하면 같은 POST 요청 재전송! → 폼 재전송 경고창

return "redirect:/user/main.do"
  → HTTP 302 응답 (브라우저에게 "이 URL로 다시 GET 요청해라")
  → 브라우저가 GET /user/main.do 를 새로 요청
  → 브라우저 URL: /user/main.do (바뀜)
  → 새로고침해도 GET 요청만 → 안전 (PRG 패턴)
```

---

## 11. MyBatis 완전 해설

### 11-1. sql-mapper-config.xml — MyBatis 전역 설정

```xml
<configuration>
    <settings>
        <!-- user_name(DB) → userName(Java) 자동 변환
             이게 없으면 DB 컬럼명과 Java 필드명이 정확히 같아야 하거나
             resultMap으로 일일이 매핑해야 한다 -->
        <setting name="mapUnderscoreToCamelCase" value="true" />
    </settings>
    <typeAliases>
        <!-- "egovframework.asset.user.service.UserVO" 대신 "userVO" 로 쓸 수 있게
             SQL XML에서 parameterType="userVO", resultType="userVO" 사용 가능 -->
        <typeAlias alias="userVO" type="egovframework.asset.user.service.UserVO"/>
    </typeAliases>
</configuration>
```

---

### 11-2. UserMapper.xml — SQL 쿼리

```xml
<!-- namespace: UserMapper.java 인터페이스의 완전한 경로와 반드시 일치해야 한다
     MyBatis가 이 namespace로 인터페이스와 XML을 연결한다 -->
<mapper namespace="egovframework.asset.user.service.UserMapper">

    <!-- id: UserMapper.java의 메서드명과 반드시 일치 (insertUser)
         parameterType: 전달받는 파라미터 타입 (typeAlias로 "userVO" 사용)
         #{userName}: userVO.getUserName() 호출 결과가 들어감 -->
    <insert id="insertUser" parameterType="userVO">
        INSERT INTO users (user_name, email, password, employee_number, role, use_yn)
        VALUES (#{userName}, #{email}, #{password}, #{employeeNumber}, #{role}, #{useYn})
    </insert>

    <!-- resultType="userVO": 조회 결과를 UserVO 객체로 자동 변환
         컬럼명(user_name) → 카멜케이스(userName) → setUserName() 자동 호출 -->
    <select id="selectUserByEmail" parameterType="String" resultType="userVO">
        SELECT user_id, user_name, email, password, employee_number,
               role, use_yn, reg_date, update_date
        FROM users
        WHERE email = #{email}
          AND use_yn = 'Y'
    </select>

</mapper>
```

**`#{}` vs `${}` 차이 — 이건 반드시 알아야 한다:**

```sql
-- #{} 사용: PreparedStatement 방식 (안전)
WHERE email = #{email}
-- 실제 실행: WHERE email = ? (파라미터를 바인딩)
-- SQL Injection 공격 방어됨

-- ${} 사용: 문자열 직접 치환 (위험!)
WHERE email = '${email}'
-- email에 ' OR '1'='1 가 들어오면:
-- WHERE email = '' OR '1'='1'  → 전체 조회 가능! → SQL Injection 취약
-- 특별한 이유(컬럼명, 테이블명 동적 지정)가 없으면 절대 쓰지 말 것
```

**DB → Java 객체 변환 과정:**

```
DB 조회 결과:
  user_id=1, user_name="홍길동", email="hong@test.com", use_yn="Y"
        │
        │ mapUnderscoreToCamelCase=true 적용
        ▼
  userId=1, userName="홍길동", email="hong@test.com", useYn="Y"
        │
        │ UserVO setter 자동 호출
        ▼
  new UserVO() {
    userId = 1,
    userName = "홍길동",
    email = "hong@test.com",
    useYn = "Y"
  }
```

---

### 11-3. users 테이블 구조 (asset_schema.sql)

```sql
CREATE TABLE IF NOT EXISTS `users` (
    user_id         BIGINT       NOT NULL AUTO_INCREMENT,  -- PK, 자동증가
    user_name       VARCHAR(50)  NOT NULL,                 -- 이름
    email           VARCHAR(100) NOT NULL UNIQUE,          -- 이메일(로그인 ID), 중복 불가
    password        VARCHAR(255) NOT NULL,                 -- 비밀번호 (현재: 평문, 실무: BCrypt)
    employee_number VARCHAR(20)  NOT NULL,                 -- 사원번호 (필수)
    role            VARCHAR(20)  NOT NULL DEFAULT 'USER',  -- 권한 (ADMIN / USER)
    use_yn          CHAR(1)      NOT NULL DEFAULT 'Y',     -- Y=활성, N=비활성
    reg_date        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    update_date     DATETIME     ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);
```

> **테이블명을 `users`로 쓰는 이유:** `user`는 MySQL/MariaDB 시스템 예약어.
> `user`로 쓰면 쿼리 오류가 날 수 있어서 `users`로 명명.

---

## 12. JSP 완전 해설

### 12-1. 핵심 태그 라이브러리

```jsp
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
```

`prefix`는 태그 앞에 붙이는 별명이다. `c:if`, `form:input`, `spring:message` 처럼 사용.

---

### 12-2. EL 표현식 (Expression Language)

JSP에서 Java 코드 없이 값을 출력하는 문법이다.

```jsp
${userName}                          ← Model의 "userName" 키 값 출력
${loginUser.userName}                ← loginUser.getUserName() 호출 결과 출력
${sessionScope.loginUser.userName}   ← 세션에서 직접 꺼내서 출력
${not empty errorMsg}                ← errorMsg가 null이 아니고 빈 문자열도 아니면 true
${loginUser.role == 'ADMIN'}         ← role 값이 'ADMIN'이면 true
```

**EL이 값을 찾는 순서:**
```
${userName} 출력 시 자동 탐색 순서:
1. pageScope   (현재 JSP 페이지)
2. requestScope (현재 HTTP 요청, model.addAttribute() 값이 여기 있음)
3. sessionScope (세션)
4. applicationScope (앱 전체)
```

`model.addAttribute("userName", "홍길동")`를 컨트롤러에서 했다면
`${userName}`으로 바로 출력 가능. `requestScope` 단계에서 발견된다.

---

### 12-3. JSTL 제어 태그

```jsp
<%-- c:if: 조건문 (else 없음) --%>
<c:if test="${not empty errorMsg}">
    <div class="alert alert-danger">${errorMsg}</div>
</c:if>

<%-- c:choose: if-elseif-else 구조 --%>
<c:choose>
    <c:when test="${loginUser.role == 'ADMIN'}">
        관리자 대시보드
    </c:when>
    <c:when test="${loginUser.role == 'MANAGER'}">
        매니저 화면
    </c:when>
    <c:otherwise>
        일반 사용자 화면
    </c:otherwise>
</c:choose>

<%-- c:forEach: 반복문 --%>
<c:forEach var="item" items="${itemList}" varStatus="status">
    ${status.index + 1}번: ${item.name}   ← status.index는 0부터 시작
    ${status.count}번:    ${item.name}   ← status.count는 1부터 시작
</c:forEach>

<%-- c:url: 컨텍스트 경로 자동 처리 URL 생성 --%>
<a href="<c:url value='/user/loginView.do'/>">로그인</a>
<%-- 앱이 /myapp 컨텍스트 경로로 배포되면 → /myapp/user/loginView.do 자동 생성 --%>
```

---

### 12-4. Spring form 태그

```jsp
<%--
  modelAttribute="userVO"
  → 컨트롤러에서 model.addAttribute("userVO", new UserVO())로 전달한 객체와 연결
  → 이 이름과 Model 키 이름이 반드시 일치해야 함

  action에 ${pageContext.request.contextPath}를 쓰는 이유:
  → 앱이 /asset 같은 컨텍스트 경로로 배포됐을 때 /asset/user/login.do 로 맞춰주기 위함
  → / 로만 쓰면 컨텍스트 경로가 빠져서 오류남 (root에 배포 시엔 상관없음)
--%>
<form:form action="${pageContext.request.contextPath}/user/login.do"
           method="post" modelAttribute="userVO">

    <%-- path="email": UserVO.email 필드와 연결. 값 불러오기/바인딩 자동 처리 --%>
    <form:input path="email" id="email" cssClass="form-control"/>

    <%-- type="password" 자동 적용 --%>
    <form:password path="password" id="password" cssClass="form-control"/>

    <%-- 유효성 오류 메시지 표시: 오류 없으면 태그 자체가 사라짐 --%>
    <form:errors path="email" cssClass="text-danger small"/>

</form:form>
```

**왜 `<form:form>`을 쓰는가:**
유효성 검증 실패로 폼을 다시 보여줄 때, 이전에 입력한 값이 자동으로 채워진다.
일반 `<form>` + `<input>`은 이 기능이 없어서 입력값이 사라진다.

---

## 13. 유효성 검증 이중 구조 — JS + Spring Validation

### 왜 이중 검증이 필요한가

```
[JS 검증만 있을 때의 위험성]

정상 사용자: 브라우저 → JS 검증 → 서버 전송 (정상)

악의적 사용자:
  방법 1: 브라우저 개발자 도구(F12) → JS 파일 수정 또는 disabled 처리
  방법 2: Postman 같은 도구로 서버에 직접 POST 요청 (JS 우회)
  방법 3: curl 명령으로 빈 값 전송

결론: JS 검증 = 사용자 경험(UX) 향상용, 실제 보안은 서버에서 해야 한다.
```

### 이중 검증 흐름

```
사용자 폼 입력 → 가입하기 클릭
        │
        ▼
[1단계] 클라이언트: jQuery 유효성 검사
  - 이름 빈값 체크 (.trim().length === 0)
  - 이메일 형식 정규식 검사
  - 비밀번호 8자 미만 체크
  - 비밀번호 확인 일치 여부
  - 사원번호 빈값 체크
  ↓ 실패: alert() + e.preventDefault() → 폼 제출 중단 (서버 안 감)
  ↓ 성공: POST /user/register.do 서버 전송
        │
        ▼
[2단계] 서버: Spring Bean Validation (@Valid + @NotBlank 등)
  - UserVO 필드의 어노테이션 자동 검사
  - 결과가 BindingResult에 저장
  ↓ 실패: return "user/register" → JSP의 <form:errors>가 오류 출력
  ↓ 성공: 서비스 호출 → DB 저장
```

### Spring Validation 구성 요소

**① pom.xml — 의존성**
```xml
<dependency>
    <groupId>javax.validation</groupId>
    <artifactId>validation-api</artifactId>
    <version>2.0.1.Final</version>
</dependency>
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.2.5.Final</version>
</dependency>
```

**② UserVO.java — 검증 어노테이션**
```java
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

**어노테이션 비교:**

| 어노테이션 | null | `""` | `"   "` | 용도 |
|-----------|:----:|:----:|:-------:|------|
| `@NotNull` | 실패 | 통과 | 통과 | 객체 null 체크 |
| `@NotEmpty` | 실패 | 실패 | 통과 | 빈 컬렉션/문자열 체크 |
| `@NotBlank` | 실패 | 실패 | 실패 | **문자열 필수 입력 (권장)** |
| `@Email` | 통과 | 통과 | - | 이메일 형식 (NotBlank와 함께 쓸 것) |
| `@Size(min=8)` | 통과 | 실패 | 실패 | 길이 범위 |

**③ UserController.java — @Valid + BindingResult**
```java
@PostMapping("/register.do")
public String register(
        @Valid @ModelAttribute("userVO") UserVO userVO,  // @Valid: 검증 실행
        BindingResult bindingResult,                      // 반드시 @Valid 파라미터 바로 다음!
        Model model) {

    if (bindingResult.hasErrors()) {
        return "user/register";  // 검증 실패 → 폼으로 되돌아감, 입력값 자동 복원
    }
    // 검증 성공
    int result = userService.insertUser(userVO);
    ...
}
```

**BindingResult 위치가 중요한 이유:**
```java
// ✅ 올바른 순서
public String register(@Valid UserVO userVO, BindingResult bindingResult, Model model)

// ❌ 잘못된 순서: @Valid 와 BindingResult 사이에 다른 파라미터 끼면
public String register(@Valid UserVO userVO, Model model, BindingResult bindingResult)
// 검증 실패 시 Spring이 BindingResult 못 찾고 예외를 직접 던져버림
```

### 로그인에 @Valid를 안 쓰는 이유

```java
// 로그인 폼은 email + password만 전송
// UserVO에 @NotBlank(userName), @NotBlank(employeeNumber)도 붙어있음
// → @Valid 쓰면 userName, employeeNumber가 null이라 항상 검증 실패!

// 해결책 (현재 이 프로젝트): @Valid 안 쓰고 수동 체크
if (userVO.getEmail() == null || userVO.getEmail().trim().isEmpty()) {
    model.addAttribute("errorMsg", "이메일을 입력해주세요.");
    return "user/login";
}
```

---

## 14. 세션과 역할(Role) 기반 분기

### 세션이란

```
세션 = 서버 메모리에 사용자별로 할당된 저장 공간

브라우저가 처음 접속 시 → 서버가 세션 ID 발급 → 쿠키(JSESSIONID)에 저장
이후 모든 요청에 쿠키 포함 → 서버가 세션 ID로 해당 사용자 공간 찾음

로그인 성공 → session.setAttribute("loginUser", loginUser)
다른 페이지 → session.getAttribute("loginUser")로 꺼내서 사용
로그아웃   → session.invalidate() → 세션 삭제 (쿠키는 남지만 서버에 데이터 없음)
```

### 세션 저장/조회/삭제

```java
// 컨트롤러: 세션 저장 (로그인 성공 시)
session.setAttribute("loginUser", loginUser);

// 컨트롤러: 세션 조회 (미로그인 차단)
UserVO loginUser = (UserVO) session.getAttribute("loginUser");
if (loginUser == null) return "redirect:/user/loginView.do";

// 컨트롤러: 세션 삭제 (로그아웃)
session.invalidate();
```

```jsp
<%-- JSP: model을 통해 꺼내기 (컨트롤러가 model.addAttribute 한 경우) --%>
${loginUser.userName}

<%-- JSP: 세션에서 직접 꺼내기 --%>
${sessionScope.loginUser.userName}
```

### 역할(Role) 기반 화면 분기 — main.jsp

```jsp
<c:choose>
    <c:when test="${loginUser.role == 'ADMIN'}">
        <div>관리자 대시보드 — 비품 관리, 사용자 관리 등</div>
    </c:when>
    <c:otherwise>
        <div>일반사용자 화면</div>
    </c:otherwise>
</c:choose>
```

**역할 값이 어디서 오는가:**
```
회원가입 → UserServiceImpl에서 userVO.setRole("USER") 고정
로그인   → DB의 role 컬럼값 그대로 조회 → loginUser.role
세션 저장 → session.setAttribute("loginUser", loginUser)
JSP 출력 → ${loginUser.role} → c:choose로 화면 분기
```

**관리자 계정 만드는 방법:**
```sql
-- 직접 INSERT 시 role='ADMIN' 지정
INSERT INTO users (user_name, email, password, employee_number, role, use_yn)
VALUES ('관리자', 'admin@company.com', 'admin1234', 'ADM001', 'ADMIN', 'Y');

-- 기존 계정 role 변경
UPDATE users SET role = 'ADMIN' WHERE email = 'hong@test.com';
```

---

## 15. 로그인 흐름 전체 추적 (Step-by-Step)

```
[사용자] 브라우저에 http://localhost:8080/ 입력

Step 1  index.jsp: <jsp:forward page="/user/loginView.do"/>
        → /user/loginView.do 로 포워드

Step 2  web.xml: *.do → DispatcherServlet
        필터 동작: CharacterEncodingFilter(UTF-8), HTMLTagFilter(XSS 방어)

Step 3  dispatcher-servlet.xml: HandlerMapping
        "/user/loginView.do" → @RequestMapping("/user") + @GetMapping("/loginView.do")
        → UserController.loginView() 선택

Step 4  (인터셉터: LocaleChangeInterceptor.preHandle 실행)

Step 5  UserController.loginView():
          model.addAttribute("userVO", new UserVO())
          return "user/login"

Step 6  ViewResolver:
          "/WEB-INF/jsp/egovframework/asset/" + "user/login" + ".jsp"
          → login.jsp 렌더링 → HTML 브라우저 전송

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[사용자] 이메일/비밀번호 입력 → 로그인 버튼 클릭

Step 7  jQuery 유효성 검사:
          - 빈값 체크, 이메일 형식 체크
          - 통과하면 POST /user/login.do 전송

Step 8  web.xml: 필터 → DispatcherServlet

Step 9  UserController.login():
          @ModelAttribute → UserVO { email="hong@test.com", password="1234" }

Step 10 userService.login(userVO) 호출
        (AOP Proxy가 가로챔 → 실제 UserServiceImpl.login() 호출)

Step 11 UserServiceImpl.login():
          userMapper.selectUserByEmail("hong@test.com") 호출

Step 12 MyBatis: UserMapper.xml의 selectUserByEmail SQL 실행
          SELECT ... FROM users WHERE email='hong@test.com' AND use_yn='Y'

Step 13 결과 처리 분기:
          DB에 없음 → null 반환 → 컨트롤러로 null 반환
          비번 불일치 → null 반환
          일치 → UserVO 객체 반환

Step 14 UserController.login() 분기:
          null(실패) → model.addAttribute("errorMsg", "...") + return "user/login"
                    → login.jsp 렌더링 (오류 메시지 표시)

          UserVO(성공) → session.setAttribute("loginUser", loginUser)
                      → return "redirect:/user/main.do" (HTTP 302)

Step 15 (성공 시) 브라우저: GET /user/main.do 자동 재요청

Step 16 UserController.main():
          session.getAttribute("loginUser") → loginUser 있으면 통과
          model.addAttribute("loginUser", loginUser)
          return "user/main"

Step 17 main.jsp:
          ${loginUser.role} → c:choose 분기
          'ADMIN' → 관리자 대시보드
          'USER'  → 일반사용자 화면
```

---

## 16. 회원가입 흐름 전체 추적 (Step-by-Step)

```
Step 1  GET /user/registerView.do → UserController.registerView()
          @ModelAttribute("userVO") → 빈 UserVO + model 자동 등록
          return "user/register" → register.jsp 렌더링

Step 2  사용자 입력: 이름, 이메일, 비밀번호, 비번확인, 사원번호

Step 3  jQuery 유효성 검사:
          .trim() 으로 공백 제거 후 빈값 체크
          이메일 형식 정규식: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
          비밀번호 8자 미만 체크
          비밀번호 확인 불일치 체크
          사원번호 빈값 체크
          → 통과하면 POST /user/register.do 전송

Step 4  UserController.register():
          @ModelAttribute → UserVO { userName, email, password, employeeNumber } 자동 바인딩

Step 5  (Spring Validation 설정 시) @Valid 검증:
          @NotBlank, @Email, @Size 어노테이션 자동 검사
          → 실패: BindingResult.hasErrors() → return "user/register"
                  register.jsp의 <form:errors>가 오류 메시지 출력

Step 6  userService.insertUser(userVO) 호출

Step 7  UserServiceImpl.insertUser():
          1. selectUserByEmail(email) → 이미 있으면 return 0
          2. setRole("USER"), setUseYn("Y") 기본값 설정
          3. userMapper.insertUser(userVO) 호출

Step 8  MyBatis: UserMapper.xml의 insertUser SQL 실행
          INSERT INTO users (user_name, email, password, employee_number, role, use_yn)
          VALUES ('홍길동', 'hong@test.com', '1234', 'E001', 'USER', 'Y')

Step 9  UserController.register() 분기:
          0(중복 이메일) → model.addAttribute("errorMsg", "...") + return "user/register"
          1(성공) → model.addAttribute("userName", "홍길동") + return "user/joinResult"

Step 10 joinResult.jsp: "${userName}님, 가입이 완료되었습니다!" 출력
```

---

## 17. eGov 특유 개념 정리

### 순수 Spring vs eGovFramework 비교

| 항목 | 순수 Spring | eGovFramework |
|------|------------|---------------|
| Mapper 어노테이션 | `@Mapper` (ibatis 패키지) | `@Mapper` (eGov rte 패키지) |
| Mapper 등록 방식 | `@MapperScan` | `MapperConfigurer` bean |
| Service 부모 클래스 | 없음 | `EgovAbstractServiceImpl` 상속 |
| 예외 처리 | 직접 try-catch 또는 `@ControllerAdvice` | AOP `context-aspect.xml` 자동 처리 |
| 예외 핸들러 인터페이스 | 없음 | `ExceptionHandler` (eGov 전용) |
| 추적 로그 | 없음 | `LeaveaTrace`, `DefaultTraceHandler` |

### EgovAbstractServiceImpl을 상속하는 이유

```java
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService {
    ...
}
```

`EgovAbstractServiceImpl`을 상속하면:
1. context-aspect.xml의 Pointcut(`*Impl.*`)에 자동으로 매칭됨
2. eGov 예외 처리 파이프라인(ExceptionTransfer)에 연결됨
3. `leaveaTrace`를 통한 추적 로그 자동 기록

단순히 상속만 해도 이 모든 것이 자동으로 적용된다.

### 컴포넌트 스캔 범위 이해

```
context-common.xml     → "egovframework" 전체 스캔 (@Controller 제외)
                           @Service(UserServiceImpl), @Mapper(UserMapper) 등록
                           → Root ApplicationContext에 등록

dispatcher-servlet.xml → "egovframework.asset" 스캔 (@Controller만)
                           @Controller(UserController) 등록
                           → Servlet ApplicationContext에 등록

결합 결과:
  UserController(@Controller)   → Servlet Context
  UserServiceImpl(@Service)     → Root Context
  UserMapper(@Mapper)           → Root Context
  dataSource, txManager 등      → Root Context
```

---

## 18. 파일별 역할과 연결 관계

```
src/main/
├── java/egovframework/asset/
│   ├── cmmn/
│   │   ├── AssetExcepHndlr.java          ← AOP 예외 핸들러 (로그 출력)
│   │   └── AssetOthersExcepHndlr.java    ← AOP 예외 핸들러 (로그 출력)
│   └── user/
│       ├── service/
│       │   ├── UserVO.java               ← DB 1행 = Java 객체 (@Data Lombok)
│       │   ├── UserService.java          ← 비즈니스 인터페이스 (설계도)
│       │   ├── UserMapper.java           ← SQL 실행 인터페이스 (eGov @Mapper)
│       │   └── impl/
│       │       └── UserServiceImpl.java  ← 비즈니스 로직 구현 (AOP 대상)
│       └── web/
│           └── UserController.java       ← HTTP 요청 처리 + 뷰 반환
│
├── resources/
│   ├── db/
│   │   ├── db.properties               ← DB 접속 정보 (git에 올리면 안 됨)
│   │   └── asset_schema.sql            ← 테이블 생성 SQL
│   └── egovframework/
│       ├── mapper/asset/
│       │   └── UserMapper.xml          ← SQL 쿼리 (namespace = UserMapper 경로)
│       ├── sqlmap/asset/mappers/
│       │   └── sql-mapper-config.xml   ← MyBatis 전역 설정 (typeAlias, camelCase)
│       └── spring/
│           ├── context-aspect.xml      ← AOP 예외 처리 설정
│           ├── context-common.xml      ← 컴포넌트 스캔(@Controller 제외), messageSource
│           ├── context-datasource.xml  ← DB 연결 (BasicDataSource 커넥션 풀)
│           ├── context-mapper.xml      ← MyBatis SqlSessionFactory, @Mapper 스캔
│           └── context-transaction.xml ← 트랜잭션 설정 (현재 pointcut 버그 있음)
│
└── webapp/
    ├── index.jsp                       ← /user/loginView.do 로 포워드
    ├── css/egovframework/bootstrap/    ← Bootstrap CSS/JS
    └── WEB-INF/
        ├── web.xml                     ← DispatcherServlet 등록, 필터 설정
        ├── config/egovframework/springmvc/
        │   └── dispatcher-servlet.xml  ← @Controller 스캔, ViewResolver, 인터셉터
        └── jsp/egovframework/asset/
            ├── cmmn/
            │   ├── egovError.jsp       ← Spring 예외 기본 화면
            │   ├── dataAccessFailure.jsp ← DB 접근 오류 화면
            │   └── transactionFailure.jsp ← 트랜잭션 오류 화면
            └── user/
                ├── login.jsp           ← 로그인 화면
                ├── register.jsp        ← 회원가입 화면
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
                                               UserMapper.java
                                               @Mapper("userMapper")
                                                      │ namespace 매핑
                                               UserMapper.xml
                                                      │ SQL 실행
                                                  users 테이블 (DB)

context-aspect.xml
    Pointcut: *..impl.*Impl.*  ───────────────→ UserServiceImpl 의 모든 메서드
    AfterThrowing              ───────────────→ ExceptionTransfer.transfer()
                                                      │
                                               AssetExcepHndlr.occur()  (로그)
                                               AssetOthersExcepHndlr.occur() (로그)

dispatcher-servlet.xml
    SimpleMappingExceptionResolver ──────────→ cmmn/egovError.jsp (Spring 예외)
    ViewResolver prefix/suffix     ──────────→ /WEB-INF/jsp/.../user/login.jsp
```

---

## 19. 자주 만나는 오류와 해결책

### 오류 1: "No qualifying bean of type 'UserService'"
```
원인: @Service 없거나 component-scan 범위 밖
확인:
  - UserServiceImpl에 @Service("userService") 있는가?
  - context-common.xml의 base-package가 "egovframework"로 되어있는가?
  - context-common.xml이 web.xml의 contextConfigLocation 경로에 포함되는가?
```

### 오류 2: "Invalid bound statement: UserMapper.insertUser"
```
원인: Mapper 인터페이스 ↔ XML 연결 안 됨
확인:
  - UserMapper.xml namespace = "egovframework.asset.user.service.UserMapper" 맞는가?
  - UserMapper.java 메서드명 = UserMapper.xml의 <insert id="..."> 일치하는가?
  - context-mapper.xml의 mapperLocations 경로에 UserMapper.xml이 포함되는가?
    (classpath:/egovframework/mapper/**/*.xml)
```

### 오류 3: "Neither BindingResult nor plain target object for bean name 'userVO'"
```
원인: <form:form modelAttribute="userVO">에서 "userVO"를 Model에서 못 찾음
해결: GET 핸들러에서 model.addAttribute("userVO", new UserVO()) 반드시 추가
     또는 @GetMapping 파라미터에 @ModelAttribute("userVO") UserVO userVO 추가
```

### 오류 4: "Table 'users' doesn't exist"
```
해결: src/main/resources/db/asset_schema.sql을 DB에서 직접 실행
     테이블명 주의: 'users' (user 아님 — MySQL 예약어 충돌)
```

### 오류 5: 새로고침 시 폼 재전송 경고
```
원인: 로그인 성공 후 return "user/main" 사용 (Forward)
해결: 반드시 return "redirect:/user/main.do" (PRG 패턴)
```

### 오류 6: 역할(role) 분기가 안 됨
```
원인: role 값 대소문자 불일치
확인:
  - DB: role = 'ADMIN' (대문자인가?)
  - JSP: ${loginUser.role == 'ADMIN'} (대소문자 일치하는가?)
  - 컨트롤러: model에 "loginUser" 키로 addAttribute 했는가?
```

### 오류 7: 한글 깨짐
```
원인: CharacterEncodingFilter가 제대로 동작하지 않음
확인:
  - web.xml 필터 설정에서 encoding=utf-8 되어있는가?
  - JSP 최상단에 <%@ page pageEncoding="utf-8"%> 있는가?
  - DB 연결 URL에 characterEncoding=UTF-8 있는가?
    jdbc:mysql://localhost:3306/asset_db?useSSL=false&characterEncoding=UTF-8
```

### 오류 8: AOP가 동작하지 않음 (예외 로그 안 찍힘)
```
확인:
  - context-aspect.xml이 contextConfigLocation 패턴(context-*.xml)에 포함되는가?
  - Pointcut 표현식이 해당 클래스 경로와 일치하는가?
    execution(* egovframework.asset..impl.*Impl.*(..))
  - UserServiceImpl이 EgovAbstractServiceImpl을 상속하는가?
  - aop 네임스페이스가 XML에 선언되어있는가?
```

---

## 요약: 핵심 연결 고리 암기 카드

```
┌────────────────────────────────────────────────────────────────┐
│ 요청 흐름                                                       │
│ 브라우저 → Filter → DispatcherServlet → Interceptor            │
│        → HandlerMapping → Controller → Service → Mapper → DB  │
│        ← ViewResolver ← return "뷰이름"                        │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ 두 컨텍스트                                                     │
│ Root Context:    context-*.xml    → @Service, @Mapper, dataSource│
│ Servlet Context: dispatcher-servlet.xml → @Controller, ViewResolver│
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ AOP 예외 처리 흐름                                              │
│ *Impl 메서드 예외 발생 → ExceptionTransfer → AssetExcepHndlr   │
│ → 로그 출력 → 예외 재전파 → SimpleMappingExceptionResolver      │
│ → cmmn/egovError.jsp 렌더링                                    │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ 설정 파일 한 줄 요약                                            │
│ web.xml              → Filter, DispatcherServlet, 두 컨텍스트 시작│
│ dispatcher-servlet   → @Controller 스캔, ViewResolver, Interceptor│
│ context-common       → @Service/@Mapper 스캔, MessageSource     │
│ context-datasource   → BasicDataSource (커넥션 풀)              │
│ context-mapper       → SqlSessionFactory, @Mapper 스캔          │
│ context-aspect       → AOP 예외 처리 (After-Throwing)           │
│ context-transaction  → 트랜잭션 (현재 pointcut 버그 있음)        │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ 세션 3단계                                                      │
│ 저장: session.setAttribute("loginUser", loginUser)             │
│ 조회: (UserVO) session.getAttribute("loginUser")               │
│ 삭제: session.invalidate()                                     │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ MyBatis 연결 체인                                               │
│ UserMapper.java (@Mapper)                                      │
│   ↕ namespace 일치                                             │
│ UserMapper.xml (<select id="메서드명">)                         │
│   ↕ mapUnderscoreToCamelCase=true                              │
│ UserVO (카멜케이스 필드명)                                      │
│   ↕ resultType="userVO" (typeAlias)                            │
│ users 테이블 (스네이크케이스 컬럼명)                            │
└────────────────────────────────────────────────────────────────┘

⚠ context-transaction.xml의 pointcut을 수정해야 트랜잭션이 동작한다:
  현재 (버그): egovframework.example.sample..impl.*Impl.*(..)
  수정 필요:   egovframework.asset..impl.*Impl.*(..)
```
