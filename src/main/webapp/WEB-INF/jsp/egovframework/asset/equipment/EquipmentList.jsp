<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${category}목록</title>
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

	<div class="container py-4">
		<div class="d-flex align-items-center gap-3 mb-3">
			<a href="main.do" class="text-decoration-none small">← 메인으로</a>
			<h1 class="h5 fw-bold mb-0">${category}목록</h1>
			<span class="small text-secondary ms-auto">총 건</span>
			<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
				<a href="categoryList.do" class="btn btn-sm btn-outline-primary">카테고리 관리</a>
				<a href="equipmentForm.do" class="btn btn-sm btn-brand">비품 등록</a>
				<button type="submit" form="qrForm" class="btn btn-sm btn-outline-success">선택 QR 발급</button>
			</c:if>
		</div>

		<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
			<form id="qrForm" method="post" action="qrGenerate.do"></form>
		</c:if>

		<c:if test="${param.error == 'hasHistory'}">
			<div class="alert alert-danger py-2 px-3 small fw-bold">대여 이력이 있는 비품은 삭제할 수 없습니다.</div>
		</c:if>

		<div class="page-card overflow-hidden mb-3">
			<table class="table table-asset table-hover mb-0">
				<thead>
					<tr>
						<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
							<th><input type="checkbox" onclick="toggleAllQrCheckboxes(this)"></th>
						</c:if>
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
								<td colspan="6" class="text-center text-secondary py-5">해당 카테고리의 비품이 없습니다.</td>
							</tr>
						</c:when>
						<c:otherwise>
							<c:forEach var="item" items="${equipmentList}" varStatus="status">
								<tr>
									<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
										<td><input type="checkbox" name="equipmentIds" form="qrForm" value="${item.equipmentId}"></td>
									</c:if>
									<td>${(pageMaker.paging.page - 1) * pageMaker.paging.perPageNum + status.index + 1}</td>
									<td>${item.equipmentName}</td>
									<td>${item.category}</td>
									<td><c:choose>
											<c:when test="${item.status == 'AVAILABLE'}">
												<span class="badge rounded-pill badge-soft-success">대여 가능</span>
											</c:when>
											<c:when test="${item.status == 'RENTED'}">
												<span class="badge rounded-pill badge-soft-warning">대여 중</span>
											</c:when>
											<c:when test="${item.status == 'BROKEN'}">
												<span class="badge rounded-pill badge-soft-danger">신고 접수</span>
											</c:when>
										</c:choose></td>
									<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
										<td>
											<div class="d-flex gap-1">
												<a href="equipmentForm.do?equipmentId=${item.equipmentId}" class="btn btn-sm badge-soft-primary">수정</a>
												<form method="post" action="equipmentDelete.do"
													onsubmit="return confirm('${item.equipmentName}을(를) 삭제하시겠습니까?');">
													<input type="hidden" name="equipmentId" value="${item.equipmentId}">
													<input type="hidden" name="category" value="${category}">
													<button type="submit" class="btn btn-sm badge-soft-danger">삭제</button>
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
		</div>

		<nav aria-label="페이지 이동">
			<ul class="pagination justify-content-center">
				<c:if test="${pageMaker.prev}">
					<li class="page-item"><a class="page-link"
						href="equipmentList.do?category=${category}&page=${pageMaker.startPage - 1}">이전</a></li>
				</c:if>
				<c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
					<li class="page-item ${pageMaker.paging.page == idx ? 'active' : ''}">
						<a class="page-link" href="equipmentList.do?category=${category}&page=${idx}">${idx}</a>
					</li>
				</c:forEach>
				<c:if test="${pageMaker.next}">
					<li class="page-item"><a class="page-link"
						href="equipmentList.do?category=${category}&page=${pageMaker.endPage + 1}">다음</a></li>
				</c:if>
			</ul>
		</nav>

	</div>

	<c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
		<script>
			function toggleAllQrCheckboxes(checkbox) {
				document.querySelectorAll('input[name="equipmentIds"]').forEach(function(cb) {
					cb.checked = checkbox.checked;
				});
			}
			document.getElementById('qrForm').addEventListener('submit', function(e) {
				var checked = document.querySelectorAll('input[name="equipmentIds"]:checked');
				if (checked.length === 0) {
					e.preventDefault();
					alert('QR을 발급할 비품을 선택하세요.');
				}
			});
		</script>
	</c:if>
</body>
</html>
