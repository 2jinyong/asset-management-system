<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>승인 관리 - 사내 비품 관리 시스템</title>
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
  .type-select-wrap { margin-bottom: 18px; }
  .type-select-wrap label { font-size: 13px; color: #555; font-weight: bold; margin-right: 8px; }
  .type-select-wrap select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; font-family: 'Malgun Gothic', sans-serif; }
  .section-title { font-size: 15px; font-weight: bold; margin-bottom: 12px; color: #333; }
  .approve-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; border: 1px solid #e8e8e8; }
  .approve-table th { background: #f8f9fb; font-size: 13px; color: #666; font-weight: normal; padding: 11px 16px; text-align: left; border-bottom: 1px solid #e8e8e8; }
  .approve-table td { padding: 12px 16px; font-size: 14px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
  .approve-table tr:last-child td { border-bottom: none; }
  .empty-row td { text-align: center; color: #999; padding: 20px; }
  .badge { display: inline-block; font-size: 11px; padding: 3px 10px; border-radius: 20px; font-weight: bold; }
  .badge.pending { background: #fff4e0; color: #b97a00; }
  .thumb { width: 48px; height: 48px; object-fit: cover; border-radius: 6px; border: 1px solid #eee; background: #f0f0f0; }
  .btn-group { display: flex; gap: 6px; }
  .btn { font-size: 12px; padding: 6px 14px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; }
  .btn-approve { background: #22a95b; color: #fff; }
  .btn-approve:hover { background: #1a8a49; }
  .btn-reject { background: #ffeaea; color: #c0392b; }
  .btn-reject:hover { background: #ffd6d6; }
  .btn-confirm { background: #e8f0fe; color: #2d5be3; }
  .btn-confirm:hover { background: #d6e3fd; }
  .btn-resolve { background: #22a95b; color: #fff; }
  .btn-resolve:hover { background: #1a8a49; }
  .pagination { display: flex; justify-content: center; align-items: center; gap: 6px; margin-top: 20px; }
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
    <a href="main.do" class="back-btn">← 메인으로</a>
    <p class="page-title">✅ 승인 관리</p>
  </div>

  <%--
      유형을 바꾸면 서버로 새로 요청(페이지=1부터) - 유형별 목록/페이징을
      매번 Controller 에서 다시 계산해서 내려주기 때문에 클라이언트 JS로
      감췄다 보였다 하지 않고 실제로 다시 조회한다.
  --%>
  <div class="type-select-wrap">
    <label for="typeSelect">요청 유형</label>
    <select id="typeSelect" onchange="location.href='approveList.do?type=' + this.value">
      <option value="rental" ${type == 'rental' ? 'selected' : ''}>대여 요청</option>
      <option value="extend" ${type == 'extend' ? 'selected' : ''}>연장 요청</option>
      <option value="report" ${type == 'report' ? 'selected' : ''}>신고</option>
    </select>
  </div>

  <c:if test="${type == 'rental'}">
    <p class="section-title">대여 요청 목록</p>
    <table class="approve-table">
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
          <td><span class="badge pending">승인 대기</span></td>
          <td>
            <div class="btn-group">
              <button type="button" class="btn btn-approve" onclick="alert('승인 처리는 추후 연동 예정입니다.')">승인</button>
              <button type="button" class="btn btn-reject" onclick="alert('반려 처리는 추후 연동 예정입니다.')">반려</button>
            </div>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty list}">
        <tr class="empty-row"><td colspan="6">대기 중인 대여 요청이 없습니다.</td></tr>
        </c:if>
      </tbody>
    </table>
  </c:if>

  <c:if test="${type == 'extend'}">
    <p class="section-title">연장 요청 목록</p>
    <table class="approve-table">
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
            <div class="btn-group">
              <button type="button" class="btn btn-approve" onclick="alert('승인 처리는 추후 연동 예정입니다.')">승인</button>
              <button type="button" class="btn btn-reject" onclick="alert('반려 처리는 추후 연동 예정입니다.')">반려</button>
            </div>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty list}">
        <tr class="empty-row"><td colspan="6">대기 중인 연장 요청이 없습니다.</td></tr>
        </c:if>
      </tbody>
    </table>
  </c:if>

  <c:if test="${type == 'report'}">
    <p class="section-title">신고 목록</p>
    <table class="approve-table">
      <thead>
        <tr>
          <th>신청자</th><th>비품명</th><th>문제 유형</th><th>상세 내용</th><th>사진</th><th>처리</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="item" items="${list}">
        <tr>
          <td>${item.applicant}</td>
          <td>${item.itemName}</td>
          <td>${item.issueType}</td>
          <td>${item.content}</td>
          <td><div class="thumb"></div></td>
          <td>
            <div class="btn-group">
              <button type="button" class="btn btn-confirm" onclick="alert('확인 처리는 추후 연동 예정입니다.')">확인</button>
              <button type="button" class="btn btn-resolve" onclick="alert('수리 완료 처리는 추후 연동 예정입니다.')">수리 완료</button>
            </div>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty list}">
        <tr class="empty-row"><td colspan="6">대기 중인 신고가 없습니다.</td></tr>
        </c:if>
      </tbody>
    </table>
  </c:if>

  <!-- 페이징 - EquipmentList.jsp 와 동일한 공통 pageMaker 패턴 -->
  <div class="pagination">
    <c:if test="${pageMaker.prev}">
      <a href="approveList.do?type=${type}&page=${pageMaker.startPage - 1}">&#171; 이전</a>
    </c:if>
    <c:forEach var="idx" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
      <a href="approveList.do?type=${type}&page=${idx}"
         class="${pageMaker.paging.page == idx ? 'active' : ''}">${idx}</a>
    </c:forEach>
    <c:if test="${pageMaker.next}">
      <a href="approveList.do?type=${type}&page=${pageMaker.endPage + 1}">다음 &#187;</a>
    </c:if>
  </div>

</div>
</body>
</html>
