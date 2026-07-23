<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>비품 처리 선택</title>
<link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">
<link rel="stylesheet" href="<c:url value='/css/egovframework/asset-common.css'/>">
</head>
<body>
<nav class="navbar navbar-expand bg-white border-bottom">
  <div class="container-fluid px-4 py-2">
    <a href="main.do" class="navbar-brand mb-0">사내 비품 관리 시스템</a>
    <div class="d-flex align-items-center gap-2">
      <c:if test="${sessionScope.loginUser.role == 'USER'}">
        <div class="avatar-circle">사원</div>
      </c:if>
      <span class="small text-secondary me-1">${sessionScope.loginUser.userName} 님</span>
      <a href="<%=request.getContextPath()%>/user/myInfo.do" class="btn btn-sm btn-outline-primary">내 정보</a>
      <a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-sm btn-outline-secondary">로그아웃</a>
    </div>
  </div>
</nav>
<div class="container py-4" style="max-width: 480px;">
  <div class="d-flex align-items-center gap-3 mb-3">
    <a href="main.do" class="text-decoration-none small">← 메인으로</a>
    <h1 class="h5 fw-bold mb-0">어떤 작업을 하시겠어요?</h1>
  </div>
  <div class="page-card p-4">
    <p class="small text-secondary mb-3">QR로 스캔한 비품(ID: ${equipmentId})에 대해 진행할 작업을 선택하세요.</p>
    <div class="d-grid gap-2">
      <a class="btn btn-success py-2 fw-bold" href="returnView.do?equipmentId=${equipmentId}">반납</a>
      <a class="btn btn-warning text-white py-2 fw-bold" href="extendRequest.do?equipmentId=${equipmentId}">연장</a>
      <a class="btn btn-danger py-2 fw-bold" href="reportIssue.do?equipmentId=${equipmentId}">신고</a>
    </div>
  </div>
</div>
</body>
</html>
