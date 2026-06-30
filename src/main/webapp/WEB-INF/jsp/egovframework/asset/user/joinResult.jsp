<%--
    ============================================================
    [회원가입 완료 화면]
    컨트롤러에서 model.addAttribute("userName", ...) 로 이름 전달
    ============================================================
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 완료 | 사내 비품관리시스템</title>
    <link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">
    <style>
        body { background-color: #f0f2f5; }
        .result-wrapper {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .result-card {
            width: 100%;
            max-width: 420px;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.10);
            text-align: center;
        }
        .check-icon { font-size: 4rem; line-height: 1; }
    </style>
</head>
<body>

<div class="result-wrapper">
    <div class="result-card card p-5">
        <div class="check-icon mb-3">&#9989;</div>
        <h2 class="fw-bold mb-2">가입 완료!</h2>

        <%--
            [EL 표현식: ${userName}]
            컨트롤러에서 model.addAttribute("userName", userVO.getUserName()) 로
            전달한 값을 출력합니다.
            c:if 로 값이 있을 때만 이름 포함 문구를 표시합니다.
        --%>
        <c:if test="${not empty userName}">
            <p class="text-muted mb-4">
                <strong>${userName}</strong>님, 환영합니다!<br>
                이제 로그인하여 비품관리시스템을 이용해보세요.
            </p>
        </c:if>
        <c:if test="${empty userName}">
            <p class="text-muted mb-4">
                회원가입이 완료되었습니다.<br>
                로그인하여 비품관리시스템을 이용해보세요.
            </p>
        </c:if>

        <a href="<c:url value='/user/loginView.do'/>" class="btn btn-primary btn-lg w-100">
            로그인 하러 가기
        </a>
    </div>
</div>

<script src="<c:url value='/js/jquery.min.js'/>"></script>
<script src="<c:url value='/css/egovframework/bootstrap/js/bootstrap.bundle.min.js'/>"></script>
</body>
</html>
