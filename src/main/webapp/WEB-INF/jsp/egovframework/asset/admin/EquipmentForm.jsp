<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${empty equipmentVO.equipmentId ? '비품 등록' : '비품 수정'} - 사내 비품 관리 시스템</title>
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

<div class="container py-4" style="max-width: 520px;">
  <div class="d-flex align-items-center gap-3 mb-3">
    <a href="equipmentList.do" class="text-decoration-none small">← 비품 목록으로</a>
    <h1 class="h5 fw-bold mb-0">${empty equipmentVO.equipmentId ? '비품 등록' : '비품 수정'}</h1>
  </div>

  <div class="page-card p-4">
    <form method="post" action="${empty equipmentVO.equipmentId ? 'equipmentRegister.do' : 'equipmentUpdate.do'}">
      <c:if test="${not empty equipmentVO.equipmentId}">
        <input type="hidden" name="equipmentId" value="${equipmentVO.equipmentId}">
      </c:if>

      <div class="mb-3">
        <label class="form-label fw-semibold small">비품명</label>
        <input type="text" class="form-control" name="equipmentName" value="${equipmentVO.equipmentName}" placeholder="예: 노트북 LG그램 15" required>
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold small">카테고리</label>
        <select class="form-select" name="category" required>
          <option value="">-- 선택 --</option>
          <c:forEach var="cat" items="${categoryList}">
            <option value="${cat}" ${equipmentVO.category == cat ? 'selected' : ''}>${cat}</option>
          </c:forEach>
        </select>
        <a href="categoryList.do" class="d-block text-end small mt-1 text-decoration-none">카테고리 관리 →</a>
      </div>

      <c:if test="${not empty equipmentVO.equipmentId}">
        <div class="mb-3">
          <label class="form-label fw-semibold small">상태</label>
          <select class="form-select" name="status">
            <option value="AVAILABLE" ${equipmentVO.status == 'AVAILABLE' ? 'selected' : ''}>대여 가능</option>
            <option value="RENTED" ${equipmentVO.status == 'RENTED' ? 'selected' : ''}>대여 중</option>
            <option value="BROKEN" ${equipmentVO.status == 'BROKEN' ? 'selected' : ''}>고장</option>
          </select>
        </div>
      </c:if>

      <button type="submit" class="btn btn-brand w-100 py-2 fw-bold">${empty equipmentVO.equipmentId ? '등록' : '수정 완료'}</button>
    </form>
  </div>
</div>
</body>
</html>
