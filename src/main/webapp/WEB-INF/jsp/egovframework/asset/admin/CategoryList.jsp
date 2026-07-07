<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>카테고리 관리 - 사내 비품 관리 시스템</title>
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

<div class="container py-4" style="max-width: 760px;">
  <div class="d-flex align-items-center gap-3 mb-3">
    <a href="equipmentList.do" class="text-decoration-none small">← 비품 목록으로</a>
    <h1 class="h5 fw-bold mb-0">카테고리 관리</h1>
  </div>

  <c:if test="${error == 'categoryInUse'}">
    <div class="alert alert-danger py-2 px-3 small fw-bold">이 카테고리를 사용 중인 비품이 있어 삭제할 수 없습니다.</div>
  </c:if>

  <div class="page-card p-3 mb-3">
    <p class="fw-semibold small text-secondary mb-2">새 카테고리 추가</p>
    <form class="d-flex gap-2" method="post" action="categoryRegister.do">
      <input type="text" class="form-control" name="categoryName" placeholder="예: 무선마우스" required>
      <button type="submit" class="btn btn-brand">추가</button>
    </form>
  </div>

  <div class="page-card overflow-hidden mb-3">
    <table class="table table-asset mb-0">
      <thead>
        <tr>
          <th>카테고리명</th>
          <th style="width: 200px;">관리</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="cat" items="${categories}">
          <tr>
            <td>
              <form method="post" action="categoryUpdate.do" id="editForm${cat.categoryId}">
                <input type="hidden" name="categoryId" value="${cat.categoryId}">
                <input type="text" class="form-control form-control-sm" name="categoryName" value="${cat.categoryName}" form="editForm${cat.categoryId}" required>
              </form>
            </td>
            <td>
              <div class="d-flex gap-1">
                <button type="submit" form="editForm${cat.categoryId}" class="btn btn-sm badge-soft-primary">저장</button>
                <form method="post" action="categoryDelete.do"
                      onsubmit="return confirm('${cat.categoryName} 카테고리를 삭제하시겠습니까?');">
                  <input type="hidden" name="categoryId" value="${cat.categoryId}">
                  <button type="submit" class="btn btn-sm badge-soft-danger">삭제</button>
                </form>
              </div>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty categories}">
          <tr><td colspan="2" class="text-center text-secondary py-4">등록된 카테고리가 없습니다.</td></tr>
        </c:if>
      </tbody>
    </table>
  </div>

  <nav aria-label="페이지 이동">
    <ul class="pagination justify-content-center">
      <c:if test="${pageMaker.prev}">
        <li class="page-item"><a class="page-link" href="categoryList.do?page=${pageMaker.startPage - 1}">이전</a></li>
      </c:if>
      <c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
        <li class="page-item ${pageMaker.paging.page == idx ? 'active' : ''}">
          <a class="page-link" href="categoryList.do?page=${idx}">${idx}</a>
        </li>
      </c:forEach>
      <c:if test="${pageMaker.next}">
        <li class="page-item"><a class="page-link" href="categoryList.do?page=${pageMaker.endPage + 1}">다음</a></li>
      </c:if>
    </ul>
  </nav>
</div>
</body>
</html>
