<%--
    ============================================================
    [로그인 화면]
    URL: GET /user/loginView.do
    처리: POST /user/login.do
    ============================================================
    [JSP 핵심 태그 설명]
    ① <%@ page %> : JSP 페이지 전체 설정 (인코딩, 언어 등)
    ② <%@ taglib %> : 외부 태그 라이브러리 등록
       - c:url  : 컨텍스트 경로를 자동으로 앞에 붙여줌 (/asset-management-system/...)
       - form:* : Spring MVC 폼 태그 (Java 객체와 HTML 폼을 자동 연결)
    ============================================================
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 | 사내 비품관리시스템</title>

    <%-- Bootstrap CSS: c:url 로 컨텍스트 경로 자동 설정 --%>
    <link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">

    <style>
        body {
            background-color: #f0f2f5;
        }
        .login-wrapper {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            width: 100%;
            max-width: 420px;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.10);
        }
        .login-card .card-header {
            background: #1a56db;
            border-radius: 12px 12px 0 0;
            padding: 2rem;
            text-align: center;
        }
        .login-card .card-header h1 {
            color: #fff;
            font-size: 1.3rem;
            font-weight: 700;
            margin: 0;
        }
        .login-card .card-header p {
            color: rgba(255,255,255,0.75);
            font-size: 0.85rem;
            margin: 0.3rem 0 0;
        }
        .form-label { font-weight: 600; font-size: 0.9rem; }
        .btn-login {
            background: #1a56db;
            border: none;
            font-weight: 600;
            letter-spacing: 0.03em;
        }
        .btn-login:hover { background: #1648c0; }
        .divider { color: #aaa; font-size: 0.85rem; }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div class="login-card card">

        <%-- 카드 헤더 --%>
        <div class="card-header">
            <h1>&#128179; 사내 비품관리시스템</h1>
            <p>이메일과 비밀번호를 입력해 로그인하세요</p>
        </div>

        <%-- 카드 본문 --%>
        <div class="card-body p-4">

            <%--
                [에러 메시지 출력]
                컨트롤러에서 model.addAttribute("errorMsg", "...") 로 전달한 값을
                ${errorMsg} EL 표현식으로 출력합니다.
                c:if 로 값이 있을 때만 표시합니다.
            --%>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger py-2 px-3" role="alert">
                    <small>&#9888; ${errorMsg}</small>
                </div>
            </c:if>

            <%--
                [Spring form 태그 설명]
                <form:form>
                  - action    : 폼 제출 URL (컨텍스트 경로는 자동 처리)
                  - method    : HTTP 메서드
                  - modelAttribute : Model에 담긴 "userVO" 객체와 이 폼을 연결
                                     컨트롤러의 loginView() 에서 model.addAttribute("userVO", new UserVO()) 한 것

                <form:input path="email">
                  - UserVO 의 email 필드와 연결
                  - 폼 제출 시 이 값이 UserVO.email 에 자동으로 들어감
            --%>
            <form:form action="${pageContext.request.contextPath}/user/login.do" method="post" modelAttribute="userVO">

                <div class="mb-3">
                    <label for="email" class="form-label">이메일</label>
                    <form:input path="email" id="email" cssClass="form-control"
                                placeholder="이메일 주소 입력" />
                </div>

                <div class="mb-4">
                    <label for="password" class="form-label">비밀번호</label>
                    <form:password path="password" id="password" cssClass="form-control"
                                   placeholder="비밀번호 입력" />
                </div>

                <div class="d-grid">
                    <button type="submit" class="btn btn-login btn-primary btn-lg">
                        로그인
                    </button>
                </div>

            </form:form>

            <%-- 구분선 --%>
            <div class="text-center my-3 divider">또는</div>

            <%-- 회원가입 링크 --%>
            <div class="d-grid">
                <a href="<c:url value='/user/registerView.do'/>"
                   class="btn btn-outline-secondary">
                    회원가입
                </a>
            </div>

        </div><%-- .card-body --%>
    </div><%-- .login-card --%>
</div><%-- .login-wrapper --%>

<%-- jQuery --%>
<script src="<c:url value='/js/jquery.min.js'/>"></script>
<%-- Bootstrap JS (Popper.js 포함) --%>
<script src="<c:url value='/css/egovframework/bootstrap/js/bootstrap.bundle.min.js'/>"></script>

<script>
    // 페이지 로드 시 이메일 입력창에 자동 포커스
    $(document).ready(function () {
        $('#email').focus();
    });
</script>

</body>
</html>
