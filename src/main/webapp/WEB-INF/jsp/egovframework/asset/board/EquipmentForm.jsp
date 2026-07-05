<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${empty equipmentVO.equipmentId ? '비품 등록' : '비품 수정'} - 사내 비품 관리 시스템</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Malgun Gothic', sans-serif; background: #f5f6fa; color: #222; }
  .header { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 14px 32px; display: flex; align-items: center; justify-content: space-between; }
  .header .logo { font-size: 17px; font-weight: bold; color: #2d5be3; text-decoration: none; }
  .header .user-info { font-size: 13px; color: #666; display: flex; align-items: center; gap: 8px; }
  .btn { font-size: 12px; padding: 5px 12px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; text-decoration: none; display: inline-block; }
  .btn-logout { background: #f0f0f0; color: #555; }
  .container { max-width: 640px; margin: 32px auto; padding: 0 24px; }
  .page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
  .back-btn { font-size: 13px; color: #2d5be3; text-decoration: none; }
  .back-btn:hover { text-decoration: underline; }
  .page-title { font-size: 20px; font-weight: bold; }
  .card { background: #fff; border-radius: 10px; border: 1px solid #e8e8e8; padding: 28px; }
  .form-group { margin-bottom: 20px; }
  .form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 6px; font-weight: bold; }
  .form-group select, .form-group input {
    width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 7px;
    font-size: 14px; font-family: 'Malgun Gothic', sans-serif; outline: none;
  }
  .form-group select:focus, .form-group input:focus { border-color: #2d5be3; }
  .category-manage-link { display: block; text-align: right; font-size: 12px; margin-top: 6px; color: #2d5be3; text-decoration: none; }
  .category-manage-link:hover { text-decoration: underline; }
  .btn-submit { width: 100%; padding: 13px; background: #2d5be3; color: #fff; border: none; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 8px; }
  .btn-submit:hover { background: #1e46c7; }
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
    <p class="page-title">${empty equipmentVO.equipmentId ? '➕ 비품 등록' : '✏ 비품 수정'}</p>
  </div>

  <div class="card">
    <form method="post" action="${empty equipmentVO.equipmentId ? 'equipmentRegister.do' : 'equipmentUpdate.do'}">
      <c:if test="${not empty equipmentVO.equipmentId}">
        <input type="hidden" name="equipmentId" value="${equipmentVO.equipmentId}">
      </c:if>

      <div class="form-group">
        <label>비품명</label>
        <input type="text" name="equipmentName" value="${equipmentVO.equipmentName}" placeholder="예: 노트북 LG그램 15" required>
      </div>

      <div class="form-group">
        <label>카테고리</label>
        <select name="category" required>
          <option value="">-- 선택 --</option>
          <c:forEach var="cat" items="${categoryList}">
            <option value="${cat}" ${equipmentVO.category == cat ? 'selected' : ''}>${cat}</option>
          </c:forEach>
        </select>
        <a href="categoryList.do" class="category-manage-link">카테고리 관리 →</a>
      </div>

      <c:if test="${not empty equipmentVO.equipmentId}">
        <div class="form-group">
          <label>상태</label>
          <select name="status">
            <option value="AVAILABLE" ${equipmentVO.status == 'AVAILABLE' ? 'selected' : ''}>대여 가능</option>
            <option value="RENTED" ${equipmentVO.status == 'RENTED' ? 'selected' : ''}>대여 중</option>
            <option value="BROKEN" ${equipmentVO.status == 'BROKEN' ? 'selected' : ''}>고장</option>
          </select>
        </div>
      </c:if>

      <button type="submit" class="btn-submit">${empty equipmentVO.equipmentId ? '등록' : '수정 완료'}</button>
    </form>
  </div>
</div>
</body>
</html>
