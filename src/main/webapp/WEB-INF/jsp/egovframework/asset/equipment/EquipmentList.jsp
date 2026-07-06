<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${category}목록</title>
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

.btn-mypage {
	background: #eef3ff;
	color: #2d5be3;
}

form.inline {
	display: inline;
}

.btn-register {
	background: #2d5be3;
	color: #fff;
	margin-left: auto;
}

.btn-edit {
	background: #e8f0fe;
	color: #2d5be3;
}

.btn-delete {
	background: #ffeaea;
	color: #c0392b;
}

.btn-group {
	display: flex;
	gap: 6px;
}

.error-banner {
	background: #ffeaea;
	color: #c0392b;
	border-radius: 8px;
	padding: 12px 16px;
	font-size: 13px;
	font-weight: bold;
	margin-bottom: 16px;
}

.container {
	max-width: 960px;
	margin: 32px auto;
	padding: 0 24px;
}

.page-header {
	display: flex;
	align-items: center;
	gap: 12px;
	margin-bottom: 24px;
}

.back-btn {
	font-size: 13px;
	color: #2d5be3;
	text-decoration: none;
}

.back-btn:hover {
	text-decoration: underline;
}

.page-title {
	font-size: 20px;
	font-weight: bold;
}

.total-count {
	font-size: 13px;
	color: #888;
	margin-left: auto;
}

.equipment-table {
	width: 100%;
	border-collapse: collapse;
	background: #fff;
	border-radius: 10px;
	overflow: hidden;
	border: 1px solid #e8e8e8;
	margin-bottom: 24px;
}

.equipment-table th {
	background: #f8f9fb;
	font-size: 13px;
	color: #666;
	font-weight: normal;
	padding: 12px 16px;
	text-align: left;
	border-bottom: 1px solid #e8e8e8;
}

.equipment-table td {
	padding: 13px 16px;
	font-size: 14px;
	border-bottom: 1px solid #f0f0f0;
	vertical-align: middle;
}

.equipment-table tr:last-child td {
	border-bottom: none;
}

.equipment-table tr:hover td {
	background: #f8f9fb;
}

.badge {
	display: inline-block;
	font-size: 11px;
	padding: 3px 10px;
	border-radius: 20px;
	font-weight: bold;
}

.badge-available {
	background: #eafaf1;
	color: #1a7a45;
}

.badge-rented {
	background: #fff4e0;
	color: #b97a00;
}

.badge-broken {
	background: #ffeaea;
	color: #c0392b;
}

.pagination {
	display: flex;
	justify-content: center;
	align-items: center;
	gap: 6px;
	margin-top: 24px;
}

.pagination a {
	display: inline-block;
	padding: 7px 13px;
	border-radius: 7px;
	border: 1px solid #e0e0e0;
	background: #fff;
	color: #444;
	text-decoration: none;
	font-size: 14px;
}

.pagination a:hover {
	background: #f0f4ff;
	border-color: #b0c4ff;
}

.pagination a.active {
	background: #2d5be3;
	color: #fff;
	border-color: #2d5be3;
}

.pagination a.disabled {
	color: #ccc;
	pointer-events: none;
}
</style>
</head>
<body>

	<div class="header">
		<a href="main.do" class="logo">&#128230; 사내 비품 관리 시스템</a>
		<div class="user-info">
			<c:if test="${sessionScope.loginUser.role == 'USER'}">
				<div class="avatar">사원</div>
			</c:if>
			<span>${sessionScope.loginUser.userName}</span>
			<a href="<%=request.getContextPath()%>/user/myInfo.do" class="btn btn-mypage">내 정보</a>
			<a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-logout">로그아웃</a>
		</div>
	</div>

	<div class="container">
		<div class="page-header">
			<a href="main.do" class="back-btn">← 메인으로</a>
			<p class="page-title">${category}목록</p>
			<span class="total-count">총 ${pageMaker.paging != null ? '' : ''}
				건</span>
			<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
				<a href="categoryList.do" class="btn btn-register">🏷 카테고리 관리</a>
				<a href="equipmentForm.do" class="btn btn-register">➕ 비품 등록</a>
			</c:if>
		</div>

		<c:if test="${param.error == 'hasHistory'}">
			<div class="error-banner">대여 이력이 있는 비품은 삭제할 수 없습니다.</div>
		</c:if>

		<table class="equipment-table">
			<thead>
				<tr>
					<th>번호</th>
					<th>비품명</th>
					<th>카테고리</th>
					<th>상태</th>
					<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
						<th>관리</th>
					</c:if>
				</tr>
			</thead>
			<tbody>
				<c:choose>
					<c:when test="${empty equipmentList}">
						<tr>
							<td colspan="5"
								style="text-align: center; color: #aaa; padding: 30px;">해당
								카테고리의 비품이 없습니다.</td>
						</tr>
					</c:when>
					<c:otherwise>
						<c:forEach var="item" items="${equipmentList}" varStatus="status">
							<tr>
								<td>${(pageMaker.paging.page - 1) * pageMaker.paging.perPageNum + status.index + 1}</td>
								<td>${item.equipmentName}</td>
								<td>${item.category}</td>
								<td><c:choose>
										<c:when test="${item.status == 'AVAILABLE'}">
											<span class="badge badge-available">대여 가능</span>
										</c:when>
										<c:when test="${item.status == 'RENTED'}">
											<span class="badge badge-rented">대여 중</span>
										</c:when>
										<c:when test="${item.status == 'BROKEN'}">
											<span class="badge badge-broken">신고 접수</span>
										</c:when>
									</c:choose></td>
								<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
									<td>
										<div class="btn-group">
											<a href="equipmentForm.do?equipmentId=${item.equipmentId}" class="btn btn-edit">수정</a>
											<form class="inline" method="post" action="equipmentDelete.do"
												onsubmit="return confirm('${item.equipmentName}을(를) 삭제하시겠습니까?');">
												<input type="hidden" name="equipmentId" value="${item.equipmentId}">
												<input type="hidden" name="category" value="${category}">
												<button type="submit" class="btn btn-delete">삭제</button>
											</form>
										</div>
									</td>
								</c:if>
							</tr>
						</c:forEach>
					</c:otherwise>
				</c:choose>
			</tbody>
		</table>

		<!-- 페이징 -->
		<div class="pagination">
			<c:if test="${pageMaker.prev}">
				<a
					href="equipmentList.do?category=${category}&page=${pageMaker.startPage - 1}">&#171;
					이전</a>
			</c:if>

			<c:forEach var="idx" begin="${pageMaker.startPage}"
				end="${pageMaker.endPage}">
				<a href="equipmentList.do?category=${category}&page=${idx}"
					class="${pageMaker.paging.page == idx ? 'active' : ''}">${idx}</a>
			</c:forEach>

			<c:if test="${pageMaker.next}">
				<a
					href="equipmentList.do?category=${category}&page=${pageMaker.endPage + 1}">다음
					&#187;</a>
			</c:if>
		</div>

	</div>
</body>
</html>
