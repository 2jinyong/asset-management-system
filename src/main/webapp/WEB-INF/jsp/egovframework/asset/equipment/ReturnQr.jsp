<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>반납 처리</title>
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
<div class="container py-4" style="max-width: 640px;">
  <div class="d-flex align-items-center gap-3 mb-3">
    <a href="main.do" class="text-decoration-none small">← 메인으로</a>
    <h1 class="h5 fw-bold mb-0">반납 처리</h1>
  </div>
  <div class="page-card p-4">
    <div class="bg-light rounded-3 p-3 mb-3" id="itemConfirm">
      <table class="table table-borderless table-sm mb-0">
        <tr><td class="text-secondary" style="width:100px;">비품명</td><td id="retName">-</td></tr>
        <tr><td class="text-secondary">모델번호</td><td id="retSerial">-</td></tr>
        <tr><td class="text-secondary">대여자</td><td id="retUser">-</td></tr>
        <tr><td class="text-secondary">반납 예정일</td><td id="retDue">-</td></tr>
      </table>
    </div>
    <div class="mb-3">
      <label class="form-label fw-semibold small">시리얼 넘버 직접 입력</label>
      <div class="input-group">
        <input type="text" class="form-control" id="serialInput" placeholder="예: 78">
        <button class="btn btn-brand" onclick="searchItem()">조회</button>
      </div>
    </div>
    <button class="btn btn-success w-100 py-2 fw-bold" onclick="submitReturn()">반납 확인</button>
  </div>
</div>
<script>
let currentRental = null;

function resetItemConfirm() {
  document.getElementById('retName').textContent = '-';
  document.getElementById('retSerial').textContent = '-';
  document.getElementById('retUser').textContent = '-';
  document.getElementById('retDue').textContent = '-';
  currentRental = null;
}

function searchItem() {
  const equipmentId = document.getElementById('serialInput').value.trim();

  if (!equipmentId) {
    alert('시리얼 넘버(장비 ID)를 입력하세요.');
    return;
  }

  fetch('returnSearch.do?equipmentId=' + encodeURIComponent(equipmentId))
    .then(res => res.json())
    .then(data => {
      if (!data || !data.rentalId) {
        alert('해당 장비의 대여 내역이 없습니다.');
        resetItemConfirm();
        return;
      }
      currentRental = data;
      document.getElementById('retName').textContent = data.equipmentName;
      document.getElementById('retSerial').textContent = data.equipmentId;
      document.getElementById('retUser').textContent = data.userName;
      document.getElementById('retDue').textContent = data.returnDate;
    })
    .catch(err => {
      console.error('조회 실패:', err);
      alert('조회 중 오류가 발생했습니다.');
    });
}

function submitReturn() {
  if (!currentRental) {
    alert('먼저 시리얼 넘버로 조회해주세요.');
    return;
  }

  fetch('returnProcess.do', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'rentalId=' + encodeURIComponent(currentRental.rentalId)
        + '&equipmentId=' + encodeURIComponent(currentRental.equipmentId)
  })
    .then(res => res.text())
    .then(() => {
      alert('반납 처리 완료');
      location.href = 'main.do';
    })
    .catch(err => {
      console.error('반납 처리 실패:', err);
      alert('반납 처리 중 오류가 발생했습니다.');
    });
}

window.addEventListener('DOMContentLoaded', function() {
	  const params = new URLSearchParams(window.location.search);
	  const equipmentId = params.get('equipmentId');
	  if (equipmentId) {
	    document.getElementById('serialInput').value = equipmentId;
	    searchItem();
	  }
	});
</script>
</body>
</html>
