<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>가입 승인 - 사내 비품 관리 시스템</title>
<link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">
<link rel="stylesheet" href="<c:url value='/css/egovframework/asset-common.css'/>">
</head>
<body>

<nav class="navbar navbar-expand bg-white border-bottom">
  <div class="container-fluid px-4 py-2">
    <span class="navbar-brand mb-0">사내 비품 관리 시스템</span>
    <div class="d-flex align-items-center gap-2">
      <span class="small text-secondary me-1">${sessionScope.loginUser.userName} 님</span>
      <a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-sm btn-outline-secondary">로그아웃</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="d-flex align-items-center gap-3 mb-3">
    <a href="<%=request.getContextPath()%>/main.do" class="text-decoration-none small">← 메인으로</a>
    <h1 class="h5 fw-bold mb-0">가입 승인</h1>
  </div>

  <div class="page-card overflow-hidden">
    <table class="table table-asset mb-0">
      <thead>
        <tr>
          <th>이름</th>
          <th>이메일</th>
          <th>사원번호</th>
          <th>신청일</th>
          <th>처리</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="u" items="${pendingUsers}">
        <tr>
          <td>${u.userName}</td>
          <td>${u.email}</td>
          <td>${u.employeeNumber}</td>
          <td>${u.regDate}</td>
          <td>
            <div class="d-flex gap-1">
              <form method="post" action="<%=request.getContextPath()%>/user/approve.do"
                    onsubmit="return confirm('${u.userName}님의 가입을 승인하시겠습니까?');">
                <input type="hidden" name="userId" value="${u.userId}">
                <button type="submit" class="btn btn-sm btn-success">승인</button>
              </form>
              <form method="post" action="<%=request.getContextPath()%>/user/reject.do"
                    onsubmit="return confirm('${u.userName}님의 가입을 반려하시겠습니까?');">
                <input type="hidden" name="userId" value="${u.userId}">
                <button type="submit" class="btn btn-sm badge-soft-danger">반려</button>
              </form>
            </div>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty pendingUsers}">
        <tr>
          <td colspan="5" class="text-center text-secondary py-4">승인 대기 중인 가입 신청이 없습니다.</td>
        </tr>
        </c:if>
      </tbody>
    </table>
  </div>

</div>
</body>
</html>
