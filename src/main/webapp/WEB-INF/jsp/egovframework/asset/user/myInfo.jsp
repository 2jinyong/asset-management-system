<%--
    ============================================================
    [내 정보 화면]
    URL: GET /user/myInfo.do
    회원 탈퇴 기능을 각 페이지 헤더에서 이 화면으로 옮겨왔다.
    ============================================================
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>내 정보 | 사내 비품 관리 시스템</title>
<link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">
<link rel="stylesheet" href="<c:url value='/css/egovframework/asset-common.css'/>">
</head>
<body>

	<nav class="navbar navbar-expand bg-white border-bottom">
		<div class="container-fluid px-4 py-2">
			<a href="<%=request.getContextPath()%>/main.do" class="navbar-brand mb-0">사내 비품 관리 시스템</a>
			<div class="d-flex align-items-center gap-2">
				<c:if test="${sessionScope.loginUser.role == 'USER'}">
					<div class="avatar-circle">사원</div>
				</c:if>
				<span class="small text-secondary me-1">${sessionScope.loginUser.userName}</span>
				<a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-sm btn-outline-secondary">로그아웃</a>
			</div>
		</div>
	</nav>

	<div class="container py-4" style="max-width: 480px;">
		<a href="<%=request.getContextPath()%>/main.do" class="d-inline-block small text-decoration-none mb-3">← 메인으로</a>
		<h1 class="h5 fw-bold mb-3">내 정보</h1>

		<div class="page-card p-4">
			<table class="table table-borderless mb-0">
				<tr>
					<th class="text-secondary fw-normal small" style="width:100px;">이름</th>
					<td>${loginUser.userName}</td>
				</tr>
				<tr>
					<th class="text-secondary fw-normal small">이메일</th>
					<td>${loginUser.email}</td>
				</tr>
				<tr>
					<th class="text-secondary fw-normal small">사원번호</th>
					<td>${loginUser.employeeNumber}</td>
				</tr>
				<tr>
					<th class="text-secondary fw-normal small">가입일</th>
					<td>${loginUser.regDate}</td>
				</tr>
			</table>

			<c:if test="${loginUser.role == 'USER'}">
				<div class="text-end pt-3 mt-3 border-top">
					<form method="post"
						action="<%=request.getContextPath()%>/user/withdraw.do"
						onsubmit="return confirm('정말 탈퇴하시겠습니까? 탈퇴 후에는 로그인할 수 없습니다.');">
						<button type="submit" class="btn btn-sm badge-soft-danger">회원 탈퇴</button>
					</form>
				</div>
			</c:if>
		</div>
	</div>
</body>
</html>
