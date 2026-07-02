<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>가입 승인 - 사내 비품 관리 시스템</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Malgun Gothic', sans-serif; background: #f5f6fa; color: #222; }
  .header { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 14px 32px; display: flex; align-items: center; justify-content: space-between; }
  .header .logo { font-size: 17px; font-weight: bold; color: #2d5be3; }
  .header .user-info { font-size: 13px; color: #666; display: flex; align-items: center; gap: 8px; }
  .btn-logout { background: #f0f0f0; color: #555; }
  .container { max-width: 960px; margin: 32px auto; padding: 0 24px; }
  .page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
  .back-btn { font-size: 13px; color: #2d5be3; text-decoration: none; }
  .back-btn:hover { text-decoration: underline; }
  .page-title { font-size: 20px; font-weight: bold; }
  .approve-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; border: 1px solid #e8e8e8; margin-bottom: 28px; }
  .approve-table th { background: #f8f9fb; font-size: 13px; color: #666; font-weight: normal; padding: 11px 16px; text-align: left; border-bottom: 1px solid #e8e8e8; }
  .approve-table td { padding: 12px 16px; font-size: 14px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
  .approve-table tr:last-child td { border-bottom: none; }
  .empty-row td { text-align: center; color: #999; padding: 20px; }
  .btn-group { display: flex; gap: 6px; }
  .btn { font-size: 12px; padding: 6px 14px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; }
  .btn-approve { background: #22a95b; color: #fff; }
  .btn-approve:hover { background: #1a8a49; }
  .btn-reject { background: #ffeaea; color: #c0392b; }
  .btn-reject:hover { background: #ffd6d6; }
  form.inline { display: inline; }
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
    <a href="<%=request.getContextPath()%>/main.do" class="back-btn">← 메인으로</a>
    <p class="page-title">🧑&#8205;💼 가입 승인</p>
  </div>

  <table class="approve-table">
    <thead>
      <tr>
        <th>이름</th>
        <th>이메일</th>
        <th>사원번호</th>
        <th>신청일</th>
        <th>처리</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="u" items="${pendingUsers}">
      <tr>
        <td>${u.userName}</td>
        <td>${u.email}</td>
        <td>${u.employeeNumber}</td>
        <td>${u.regDate}</td>
        <td>
          <div class="btn-group">
            <form class="inline" method="post" action="<%=request.getContextPath()%>/user/approve.do"
                  onsubmit="return confirm('${u.userName}님의 가입을 승인하시겠습니까?');">
              <input type="hidden" name="userId" value="${u.userId}">
              <button type="submit" class="btn btn-approve">승인</button>
            </form>
            <form class="inline" method="post" action="<%=request.getContextPath()%>/user/reject.do"
                  onsubmit="return confirm('${u.userName}님의 가입을 반려하시겠습니까?');">
              <input type="hidden" name="userId" value="${u.userId}">
              <button type="submit" class="btn btn-reject">반려</button>
            </form>
          </div>
        </td>
      </tr>
      </c:forEach>
      <c:if test="${empty pendingUsers}">
      <tr class="empty-row">
        <td colspan="5">승인 대기 중인 가입 신청이 없습니다.</td>
      </tr>
      </c:if>
    </tbody>
  </table>

</div>
</body>
</html>
