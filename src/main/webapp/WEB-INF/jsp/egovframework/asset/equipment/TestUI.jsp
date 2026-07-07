<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>사내 비품 관리 시스템</title>
<link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">
<link rel="stylesheet" href="<c:url value='/css/egovframework/asset-common.css'/>">
</head>
<body>

	<nav class="navbar navbar-expand bg-white border-bottom">
		<div class="container-fluid px-4 py-2">
			<span class="navbar-brand mb-0">사내 비품 관리 시스템</span>
			<div class="d-flex align-items-center gap-2">
				<c:if test="${sessionScope.loginUser.role == 'USER'}">
					<div class="avatar-circle">사원</div>
				</c:if>
				<span class="small text-secondary me-1">${sessionScope.loginUser.userName}</span>
				<a href="<%=request.getContextPath()%>/user/myInfo.do" class="btn btn-sm btn-outline-primary">내 정보</a>
				<a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-sm btn-outline-secondary">로그아웃</a>
			</div>
		</div>
	</nav>

	<div class="container py-4">

		<h1 class="h4 fw-bold mb-3">비품 현황</h1>

		<!-- 메뉴 -->
		<div class="row row-cols-2 row-cols-md-4 g-3 mb-4">
			<c:choose>
				<c:when test="${sessionScope.loginUser.role == 'ADMIN'}">
					<div class="col">
						<a href="approveList.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">승인 관리</div>
							<div class="small text-secondary">대여/연장 요청 승인</div>
						</a>
					</div>
					<div class="col">
						<a href="issueList.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">신고 관리</div>
							<div class="small text-secondary">고장 신고 확인 및 수리 처리</div>
						</a>
					</div>
					<div class="col">
						<a href="user/pendingList.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">가입 승인</div>
							<div class="small text-secondary">신규 가입 신청 승인/반려</div>
						</a>
					</div>
					<div class="col">
						<a href="equipmentList.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">비품 관리</div>
							<div class="small text-secondary">비품 등록/수정/삭제</div>
						</a>
					</div>
				</c:when>
				<c:otherwise>
					<div class="col">
						<a href="rentalRequest.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">대여 요청</div>
							<div class="small text-secondary">비품 선택 후 신청</div>
						</a>
					</div>
					<div class="col">
						<a href="returnQr.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">반납 처리</div>
							<div class="small text-secondary">QR 스캔으로 반납</div>
						</a>
					</div>
					<div class="col">
						<a href="extendRequest.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">연장 요청</div>
							<div class="small text-secondary">대여 기간 연장 신청</div>
						</a>
					</div>
					<div class="col">
						<a href="reportIssue.do" class="menu-card card d-block p-3 h-100">
							<div class="fw-semibold mb-1">문제 신고</div>
							<div class="small text-secondary">이상 상태 신고 및 사진 첨부</div>
						</a>
					</div>
				</c:otherwise>
			</c:choose>
		</div>

		<!-- 비품 카테고리별 현황 -->
		<h2 class="h6 fw-bold mb-2">비품 카테고리별 현황</h2>
		<div class="page-card overflow-hidden mb-4">
			<table class="table table-asset table-hover mb-0">
				<thead>
					<tr>
						<th>비품 종류</th>
						<th class="text-center">전체</th>
						<th class="text-center">대여 가능</th>
						<th class="text-center">대여 중</th>
						<th class="text-center">신고</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="item" items="${categorySummary}">
						<tr>
							<td><a href="equipmentList.do?category=${item.category}"
								class="text-decoration-none text-body"> ${item.category} </a></td>
							<td class="text-center">${item.total}</td>
							<td class="text-center text-success fw-bold">${item.available}</td>
							<td class="text-center text-warning fw-bold">${item.rented}</td>
							<td class="text-center text-danger fw-bold">${item.broken}</td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>

		<!-- 내 대여 현황 (관리자는 대여를 하지 않으므로 USER에게만 노출) -->
		<c:if test="${sessionScope.loginUser.role == 'USER'}">
			<h2 class="h6 fw-bold mb-2">내 대여 현황</h2>
			<div class="page-card overflow-hidden">
				<table class="table table-asset mb-0">
					<thead>
						<tr>
							<th>비품명</th>
							<th>대여일</th>
							<th>반납 예정일</th>
							<th>상태</th>
							<th>액션</th>
						</tr>
					</thead>
					<tbody>
						<c:choose>
							<c:when test="${empty myRentalList}">
								<tr>
									<td colspan="5" class="text-center text-secondary py-4">대여 중인 비품이 없습니다.</td>
								</tr>
							</c:when>
							<c:otherwise>
								<c:forEach var="rental" items="${myRentalList}">
									<tr>
										<td>${rental.equipmentName}</td>
										<td>${fn:substring(rental.rentalDate, 0, 10)}</td>
										<td>${fn:substring(rental.returnDate, 0, 10)}</td>
										<td><c:choose>
												<c:when test="${rental.requestStatus == 'REQUESTED'}">
													<span class="badge rounded-pill badge-soft-warning">승인 요청</span>
												</c:when>
												<c:when test="${rental.requestStatus == 'APPROVED'}">
													<span class="badge rounded-pill badge-soft-success">대여 중</span>
												</c:when>
												<c:when test="${rental.requestStatus == 'REJECTED'}">
													<span class="badge rounded-pill badge-soft-danger">반려</span>
												</c:when>
											</c:choose></td>
										<td>
											<div class="d-flex gap-1">
												<a href="returnQr.do?equipmentId=${rental.equipmentId}"
													class="btn btn-sm badge-soft-primary">반납</a>
												<a href="extendRequest.do?equipmentId=${rental.equipmentId}"
													class="btn btn-sm badge-soft-warning">연장</a>
												<a href="reportIssue.do?equipmentId=${rental.equipmentId}"
													class="btn btn-sm badge-soft-danger">신고</a>
											</div>
										</td>
									</tr>
								</c:forEach>
							</c:otherwise>
						</c:choose>
					</tbody>
				</table>
			</div>
		</c:if>

	</div>
</body>
</html>