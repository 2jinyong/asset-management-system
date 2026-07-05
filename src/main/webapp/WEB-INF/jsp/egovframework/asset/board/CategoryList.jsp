<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>카테고리 관리 - 사내 비품 관리 시스템</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Malgun Gothic', sans-serif; background: #f5f6fa; color: #222; }
  .header { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 14px 32px; display: flex; align-items: center; justify-content: space-between; }
  .header .logo { font-size: 17px; font-weight: bold; color: #2d5be3; }
  .header .user-info { font-size: 13px; color: #666; display: flex; align-items: center; gap: 8px; }
  .btn-logout { background: #f0f0f0; color: #555; }
  .container { max-width: 760px; margin: 24px auto; padding: 0 24px; }
  .page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
  .back-btn { font-size: 13px; color: #2d5be3; text-decoration: none; }
  .back-btn:hover { text-decoration: underline; }
  .page-title { font-size: 20px; font-weight: bold; }
  .error-banner { background: #ffeaea; color: #c0392b; border-radius: 8px; padding: 12px 16px; font-size: 13px; font-weight: bold; margin-bottom: 16px; }
  .category-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; border: 1px solid #e8e8e8; margin-bottom: 14px; }
  .category-table th { background: #f8f9fb; font-size: 13px; color: #666; font-weight: normal; padding: 9px 16px; text-align: left; border-bottom: 1px solid #e8e8e8; }
  .category-table td { padding: 7px 16px; font-size: 14px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
  .category-table tr:last-child td { border-bottom: none; }
  .category-name-form { display: flex; gap: 8px; }
  .category-name-form input { flex: 1; padding: 8px 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; font-family: 'Malgun Gothic', sans-serif; outline: none; }
  .category-name-form input:focus { border-color: #2d5be3; }
  .btn { font-size: 12px; padding: 6px 14px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; white-space: nowrap; }
  .btn-save { background: #e8f0fe; color: #2d5be3; }
  .btn-save:hover { background: #d6e3fd; }
  .btn-delete { background: #ffeaea; color: #c0392b; }
  .btn-delete:hover { background: #ffd6d6; }
  .add-card { background: #fff; border-radius: 10px; border: 1px solid #e8e8e8; padding: 16px 20px; margin-bottom: 20px; }
  .add-card p { font-size: 14px; font-weight: bold; margin-bottom: 10px; color: #555; }
  .add-form { display: flex; gap: 8px; }
  .add-form input { flex: 1; padding: 10px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; font-family: 'Malgun Gothic', sans-serif; outline: none; }
  .add-form input:focus { border-color: #2d5be3; }
  .btn-add { background: #2d5be3; color: #fff; padding: 10px 18px; }
  .btn-add:hover { background: #1e46c7; }
  .empty-row td { text-align: center; color: #999; padding: 20px; }
  .pagination { display: flex; justify-content: center; align-items: center; gap: 6px; }
  .pagination a { display: inline-block; padding: 7px 13px; border-radius: 7px; border: 1px solid #e0e0e0; background: #fff; color: #444; text-decoration: none; font-size: 14px; }
  .pagination a:hover { background: #f0f4ff; border-color: #b0c4ff; }
  .pagination a.active { background: #2d5be3; color: #fff; border-color: #2d5be3; }
</style>
</head>
<body>

<div class="header">
  <span class="logo">&#128230; 사내 비품 관리 시스템</span>
  <div class="user-info">
    <span>${sessionScope.loginUser.userName} 님</span>
    <a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-logout">로그아웃</a>
  </div>
</div>

<div class="container">
  <div class="page-header">
    <a href="equipmentList.do" class="back-btn">← 비품 목록으로</a>
    <p class="page-title">🏷 카테고리 관리</p>
  </div>

  <c:if test="${error == 'categoryInUse'}">
    <div class="error-banner">이 카테고리를 사용 중인 비품이 있어 삭제할 수 없습니다.</div>
  </c:if>

  <div class="add-card">
    <p>새 카테고리 추가</p>
    <form class="add-form" method="post" action="categoryRegister.do">
      <input type="text" name="categoryName" placeholder="예: 무선마우스" required>
      <button type="submit" class="btn btn-add">추가</button>
    </form>
  </div>

  <table class="category-table">
    <thead>
      <tr>
        <th>카테고리명</th>
        <th style="width: 180px;">관리</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="cat" items="${categories}">
        <tr>
          <td>
            <form class="category-name-form" method="post" action="categoryUpdate.do" id="editForm${cat.categoryId}">
              <input type="hidden" name="categoryId" value="${cat.categoryId}">
              <input type="text" name="categoryName" value="${cat.categoryName}" form="editForm${cat.categoryId}" required>
            </form>
          </td>
          <td>
            <button type="submit" form="editForm${cat.categoryId}" class="btn btn-save">저장</button>
            <form class="category-name-form" method="post" action="categoryDelete.do" style="display:inline;"
                  onsubmit="return confirm('${cat.categoryName} 카테고리를 삭제하시겠습니까?');">
              <input type="hidden" name="categoryId" value="${cat.categoryId}">
              <button type="submit" class="btn btn-delete">삭제</button>
            </form>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty categories}">
        <tr class="empty-row"><td colspan="2">등록된 카테고리가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>

  <div class="pagination">
    <c:if test="${pageMaker.prev}">
      <a href="categoryList.do?page=${pageMaker.startPage - 1}">&#171; 이전</a>
    </c:if>
    <c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
      <a href="categoryList.do?page=${idx}"
         class="${pageMaker.paging.page == idx ? 'active' : ''}">${idx}</a>
    </c:forEach>
    <c:if test="${pageMaker.next}">
      <a href="categoryList.do?page=${pageMaker.endPage + 1}">다음 &#187;</a>
    </c:if>
  </div>
</div>
</body>
</html>
