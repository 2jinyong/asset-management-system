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
<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: 'Malgun Gothic', sans-serif;
	background: #f5f6fa;
	color: #222;
}

.header {
	background: #fff;
	border-bottom: 1px solid #e0e0e0;
	padding: 14px 32px;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.header .logo {
	font-size: 17px;
	font-weight: bold;
	color: #2d5be3;
	text-decoration: none;
}

.header .user-info {
	font-size: 13px;
	color: #666;
	display: flex;
	align-items: center;
	gap: 8px;
}

.avatar {
	width: 32px;
	height: 32px;
	border-radius: 50%;
	background: #dce8ff;
	color: #2d5be3;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 13px;
	font-weight: bold;
}

.btn {
	font-size: 12px;
	padding: 5px 12px;
	border-radius: 6px;
	border: none;
	cursor: pointer;
	font-weight: bold;
	text-decoration: none;
	display: inline-block;
}

.btn-logout {
	background: #f0f0f0;
	color: #555;
}

.btn-withdraw {
	background: #fff0f0;
	color: #c0392b;
}

.container {
	max-width: 480px;
	margin: 40px auto;
	padding: 0 24px;
}

.back-btn {
	font-size: 13px;
	color: #666;
	text-decoration: none;
	display: inline-block;
	margin-bottom: 16px;
}

.page-title {
	font-size: 20px;
	font-weight: bold;
	margin-bottom: 20px;
}

.info-card {
	background: #fff;
	border-radius: 10px;
	border: 1px solid #e8e8e8;
	padding: 24px;
}

.info-table {
	width: 100%;
	border-collapse: collapse;
}

.info-table th {
	width: 100px;
	text-align: left;
	padding: 12px 0;
	font-size: 13px;
	color: #888;
	font-weight: normal;
	border-bottom: 1px solid #f0f0f0;
}

.info-table td {
	padding: 12px 0;
	font-size: 14px;
	border-bottom: 1px solid #f0f0f0;
}

.info-table tr:last-child th, .info-table tr:last-child td {
	border-bottom: none;
}

.withdraw-area {
	margin-top: 24px;
	padding-top: 20px;
	border-top: 1px solid #f0f0f0;
	text-align: right;
}
</style>
</head>
<body>

	<div class="header">
		<a href="<%=request.getContextPath()%>/main.do" class="logo">&#128230; 사내 비품 관리 시스템</a>
		<div class="user-info">
			<c:if test="${sessionScope.loginUser.role == 'USER'}">
				<div class="avatar">사원</div>
			</c:if>
			<span>${sessionScope.loginUser.userName}</span>
			<a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-logout">로그아웃</a>
		</div>
	</div>

	<div class="container">
		<a href="<%=request.getContextPath()%>/main.do" class="back-btn">← 메인으로</a>
		<p class="page-title">내 정보</p>

		<div class="info-card">
			<table class="info-table">
				<tr>
					<th>이름</th>
					<td>${loginUser.userName}</td>
				</tr>
				<tr>
					<th>이메일</th>
					<td>${loginUser.email}</td>
				</tr>
				<tr>
					<th>사원번호</th>
					<td>${loginUser.employeeNumber}</td>
				</tr>
				<tr>
					<th>가입일</th>
					<td>${loginUser.regDate}</td>
				</tr>
			</table>

			<c:if test="${loginUser.role == 'USER'}">
				<div class="withdraw-area">
					<form method="post"
						action="<%=request.getContextPath()%>/user/withdraw.do"
						onsubmit="return confirm('정말 탈퇴하시겠습니까? 탈퇴 후에는 로그인할 수 없습니다.');">
						<button type="submit" class="btn btn-withdraw">회원 탈퇴</button>
					</form>
				</div>
			</c:if>
		</div>
	</div>
</body>
</html>
