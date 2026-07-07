<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>승인 관리 - 사내 비품 관리 시스템</title>
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
    <a href="main.do" class="text-decoration-none small">← 메인으로</a>
    <h1 class="h5 fw-bold mb-0">승인 관리</h1>
  </div>

  <%--
      유형을 바꾸면 서버로 새로 요청(페이지=1부터) - 유형별 목록/페이징을
      매번 Controller 에서 다시 계산해서 내려주기 때문에 클라이언트 JS로
      감췄다 보였다 하지 않고 실제로 다시 조회한다.
  --%>
  <div class="mb-3">
    <label for="typeSelect" class="form-label fw-semibold small me-2">요청 유형</label>
    <select id="typeSelect" class="form-select d-inline-block w-auto" onchange="location.href='approveList.do?type=' + this.value">
      <option value="rental" ${type == 'rental' ? 'selected' : ''}>대여 요청</option>
      <option value="extend" ${type == 'extend' ? 'selected' : ''}>연장 요청</option>
    </select>
  </div>

  <c:if test="${type == 'rental'}">
    <p class="fw-semibold mb-2">대여 요청 목록</p>
    <div class="page-card overflow-hidden mb-3">
      <table class="table table-asset mb-0">
        <thead>
          <tr>
            <th>신청자</th><th>비품명</th><th>대여 시작일</th><th>반납 예정일</th><th>상태</th><th>처리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="item" items="${list}">
          <tr>
            <td>${item.applicant}</td>
            <td>${item.itemName}</td>
            <td>${item.startDate}</td>
            <td>${item.dueDate}</td>
            <td><span class="badge rounded-pill badge-soft-warning">승인 대기</span></td>
            <td>
              <div class="d-flex gap-1">
                <form method="post" action="<%=request.getContextPath()%>/approveRental.do"
                      onsubmit="return confirm('대여 요청을 승인하시겠습니까?');">
                  <input type="hidden" name="rentalId" value="${item.rentalId}">
                  <button type="submit" class="btn btn-sm btn-success">승인</button>
                </form>
                <form method="post" action="<%=request.getContextPath()%>/rejectRental.do"
                      onsubmit="return confirm('대여 요청을 반려하시겠습니까?');">
                  <input type="hidden" name="rentalId" value="${item.rentalId}">
                  <button type="submit" class="btn btn-sm badge-soft-danger">반려</button>
                </form>
              </div>
            </td>
          </tr>
          </c:forEach>
          <c:if test="${empty list}">
          <tr><td colspan="6" class="text-center text-secondary py-4">대기 중인 대여 요청이 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </c:if>

  <c:if test="${type == 'extend'}">
    <p class="fw-semibold mb-2">연장 요청 목록</p>
    <div class="page-card overflow-hidden mb-3">
      <table class="table table-asset mb-0">
        <thead>
          <tr>
            <th>신청자</th><th>비품명</th><th>현재 반납 예정일</th><th>연장 요청일</th><th>사유</th><th>처리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="item" items="${list}">
          <tr>
            <td>${item.applicant}</td>
            <td>${item.itemName}</td>
            <td>${item.currentDue}</td>
            <td>${item.requestDue}</td>
            <td>${item.reason}</td>
            <td>
              <div class="d-flex gap-1">
                <form method="post" action="<%=request.getContextPath()%>/approveExtend.do"
                      onsubmit="return confirm('연장 요청을 승인하시겠습니까?');">
                  <input type="hidden" name="rentalId" value="${item.rentalId}">
                  <button type="submit" class="btn btn-sm btn-success">승인</button>
                </form>
                <form method="post" action="<%=request.getContextPath()%>/rejectExtend.do"
                      onsubmit="return confirm('연장 요청을 반려하시겠습니까?');">
                  <input type="hidden" name="rentalId" value="${item.rentalId}">
                  <button type="submit" class="btn btn-sm badge-soft-danger">반려</button>
                </form>
              </div>
            </td>
          </tr>
          </c:forEach>
          <c:if test="${empty list}">
          <tr><td colspan="6" class="text-center text-secondary py-4">대기 중인 연장 요청이 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </c:if>

  <!-- 페이징 - EquipmentList.jsp 와 동일한 공통 pageMaker 패턴 -->
  <nav aria-label="페이지 이동">
    <ul class="pagination justify-content-center">
      <c:if test="${pageMaker.prev}">
        <li class="page-item"><a class="page-link" href="approveList.do?type=${type}&page=${pageMaker.startPage - 1}">이전</a></li>
      </c:if>
      <c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
        <li class="page-item ${pageMaker.paging.page == idx ? 'active' : ''}">
          <a class="page-link" href="approveList.do?type=${type}&page=${idx}">${idx}</a>
        </li>
      </c:forEach>
      <c:if test="${pageMaker.next}">
        <li class="page-item"><a class="page-link" href="approveList.do?type=${type}&page=${pageMaker.endPage + 1}">다음</a></li>
      </c:if>
    </ul>
  </nav>

</div>
</body>
</html>
