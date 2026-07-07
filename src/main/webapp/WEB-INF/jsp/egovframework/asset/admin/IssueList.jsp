<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>신고 관리 - 사내 비품 관리 시스템</title>
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
    <h1 class="h5 fw-bold mb-0">신고 관리</h1>
  </div>

  <%--
      신고 접수 즉시 비품은 BROKEN 처리되고, 여기서는 확인중(PENDING) / 고장접수(CONFIRMED) / 수리중(REPAIRING)
      상태인 건만 보여준다. 수리완료(RESOLVED)·반려(REJECTED) 처리된 건은 이 목록에서 자동으로 빠진다.
  --%>
  <div class="page-card overflow-hidden mb-3">
    <table class="table table-asset mb-0">
      <thead>
        <tr>
          <th>신청자</th><th>비품명</th><th>문제 유형</th><th>상세 내용</th><th>사진</th><th>상태</th><th>처리</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="item" items="${list}">
        <tr>
          <td>${item.applicant}</td>
          <td>${item.itemName}</td>
          <td>${item.issueType}</td>
          <td>${item.content}</td>
          <td>
            <c:choose>
              <c:when test="${not empty item.imagePath}">
                <img src="<c:url value='/reportImage.do'/>?reportId=${item.reportId}" class="preview-thumb preview-thumb-clickable"
                     alt="신고 사진" onclick="showImageModal(this.src)"
                     onerror="this.classList.add('d-none'); this.nextElementSibling.classList.remove('d-none');">
                <div class="preview-thumb bg-light d-none"></div>
              </c:when>
              <c:otherwise>
                <div class="preview-thumb bg-light"></div>
              </c:otherwise>
            </c:choose>
          </td>
          <td>
            <c:choose>
              <c:when test="${item.status == 'PENDING'}">
                <span class="badge rounded-pill badge-soft-warning">확인중</span>
              </c:when>
              <c:when test="${item.status == 'CONFIRMED'}">
                <span class="badge rounded-pill badge-soft-danger">고장접수</span>
              </c:when>
              <c:when test="${item.status == 'REPAIRING'}">
                <span class="badge rounded-pill badge-soft-primary">수리중</span>
              </c:when>
            </c:choose>
          </td>
          <td>
            <div class="d-flex gap-1">
              <c:if test="${item.status == 'PENDING'}">
                <form method="post" action="<%=request.getContextPath()%>/reportConfirm.do"
                      onsubmit="return confirm('고장접수 처리하시겠습니까? 관련 대여 건이 종료됩니다.');">
                  <input type="hidden" name="reportId" value="${item.reportId}">
                  <button type="submit" class="btn btn-sm btn-danger">고장접수</button>
                </form>
                <form method="post" action="<%=request.getContextPath()%>/reportReject.do"
                      onsubmit="return confirm('반려하시겠습니까? 비품은 다시 대여중 상태로 복구됩니다.');">
                  <input type="hidden" name="reportId" value="${item.reportId}">
                  <button type="submit" class="btn btn-sm badge-soft-secondary">오접수 반려</button>
                </form>
              </c:if>
              <c:if test="${item.status == 'CONFIRMED'}">
                <form method="post" action="<%=request.getContextPath()%>/reportStartRepair.do"
                      onsubmit="return confirm('수리를 시작하시겠습니까?');">
                  <input type="hidden" name="reportId" value="${item.reportId}">
                  <button type="submit" class="btn btn-sm badge-soft-primary">수리 시작</button>
                </form>
              </c:if>
              <c:if test="${item.status == 'REPAIRING'}">
                <form method="post" action="<%=request.getContextPath()%>/reportResolve.do"
                      onsubmit="return confirm('수리가 완료되어 비품을 다시 대여 가능 상태로 전환하시겠습니까?');">
                  <input type="hidden" name="reportId" value="${item.reportId}">
                  <button type="submit" class="btn btn-sm btn-success">수리 완료</button>
                </form>
              </c:if>
            </div>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty list}">
        <tr><td colspan="7" class="text-center text-secondary py-4">처리할 신고가 없습니다.</td></tr>
        </c:if>
      </tbody>
    </table>
  </div>

  <nav aria-label="페이지 이동">
    <ul class="pagination justify-content-center">
      <c:if test="${pageMaker.prev}">
        <li class="page-item"><a class="page-link" href="issueList.do?page=${pageMaker.startPage - 1}">이전</a></li>
      </c:if>
      <c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
        <li class="page-item ${pageMaker.paging.page == idx ? 'active' : ''}">
          <a class="page-link" href="issueList.do?page=${idx}">${idx}</a>
        </li>
      </c:forEach>
      <c:if test="${pageMaker.next}">
        <li class="page-item"><a class="page-link" href="issueList.do?page=${pageMaker.endPage + 1}">다음</a></li>
      </c:if>
    </ul>
  </nav>

</div>

<!-- 신고 사진 확대 모달 -->
<div class="modal fade" id="imgModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header py-2">
        <h6 class="modal-title">신고 사진</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
      </div>
      <div class="modal-body text-center p-2">
        <img id="imgModalImg" src="" class="img-fluid rounded" alt="신고 사진 확대">
      </div>
    </div>
  </div>
</div>

<script src="<c:url value='/css/egovframework/bootstrap/js/bootstrap.bundle.min.js'/>"></script>
<script>
  var imgModal = new bootstrap.Modal(document.getElementById('imgModal'));
  function showImageModal(src) {
    document.getElementById('imgModalImg').src = src;
    imgModal.show();
  }
</script>
</body>
</html>
