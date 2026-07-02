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
			<div class="avatar">김</div>
			<span>김재민 님</span>
		</div>
	</div>

	<div class="container">
		<div class="page-header">
			<a href="main.do" class="back-btn">← 메인으로</a>
			<p class="page-title">${category}목록</p>
			<span class="total-count">총 ${pageMaker.paging != null ? '' : ''}
				건</span>
		</div>

		<table class="equipment-table">
			<thead>
				<tr>
					<th>번호</th>
					<th>비품명</th>
					<th>카테고리</th>
					<th>상태</th>
				</tr>
			</thead>
			<tbody>
				<c:choose>
					<c:when test="${empty equipmentList}">
						<tr>
							<td colspan="4"
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
