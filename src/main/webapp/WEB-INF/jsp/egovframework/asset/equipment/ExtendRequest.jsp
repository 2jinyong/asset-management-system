<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>연장 요청</title>
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
      <span class="small text-secondary me-1">${sessionScope.loginUser.userName}</span>
      <a href="<%=request.getContextPath()%>/user/myInfo.do" class="btn btn-sm btn-outline-primary">내 정보</a>
      <a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-sm btn-outline-secondary">로그아웃</a>
    </div>
  </div>
</nav>
<div class="container py-4" style="max-width: 640px;">
  <div class="d-flex align-items-center gap-3 mb-3">
    <a href="main.do" class="text-decoration-none small">← 메인으로</a>
    <h1 class="h5 fw-bold mb-0">연장 요청</h1>
  </div>
  <div class="page-card p-4">
    <div class="mb-3">
      <label class="form-label fw-semibold small">대여 중인 비품 선택</label>
      <select class="form-select" id="rentalSelect" onchange="showCurrent()">
        <option value="">-- 선택 --</option>
      </select>
      <div class="rounded-3 p-3 small mt-2 d-none" id="currentInfo" style="background:#fff9ee; border:1px solid #ffe0a0;">
        <table class="table table-borderless table-sm mb-0">
          <tr><td class="text-secondary" style="width:110px;">모델명</td><td id="curModel">-</td></tr>
          <tr><td class="text-secondary">현재 반납일</td><td id="curDue">-</td></tr>
        </table>
      </div>
    </div>
    <div class="mb-3">
      <label class="form-label fw-semibold small">연장 반납 예정일</label>
      <input type="date" class="form-control" id="newDate">
    </div>
    <div class="mb-3">
      <label class="form-label fw-semibold small">연장 사유</label>
      <textarea class="form-control" id="reasonInput" rows="3" placeholder="연장이 필요한 사유를 입력하세요"></textarea>
    </div>
    <button class="btn btn-warning text-white w-100 py-2 fw-bold" onclick="submitExtend()">연장 요청 제출</button>
  </div>
</div>
<script>
let rentals = [];

function loadMyRentals() {
  fetch('myRentalList.do')
    .then(res => res.json())
    .then(data => {
      rentals = data;
      const sel = document.getElementById('rentalSelect');
      sel.innerHTML = '<option value="">-- 선택 --</option>';
      if (data.length === 0) {
        sel.innerHTML = '<option value="">대여 중인 비품이 없습니다.</option>';
        return;
      }
      data.forEach((r, idx) => {
        const opt = document.createElement('option');
        opt.value = idx;
        opt.textContent = r.equipmentName + ' (반납예정 ' + r.returnDate + ')';
        sel.appendChild(opt);
      });

      const params = new URLSearchParams(window.location.search);
      const equipmentId = params.get('equipmentId');
      if (equipmentId) {
        const matchIdx = data.findIndex(r => String(r.equipmentId) === equipmentId);
        if (matchIdx !== -1) {
          sel.value = matchIdx;
          showCurrent();
        }
      }
    })
    .catch(err => console.error('대여 목록 로드 실패:', err));
}

function showCurrent() {
  const idx = document.getElementById('rentalSelect').value;
  const info = document.getElementById('currentInfo');
  if (idx !== '') {
    const r = rentals[idx];
    document.getElementById('curModel').textContent = r.equipmentName;
    document.getElementById('curDue').textContent = r.returnDate;
    info.classList.remove('d-none');
  } else {
    info.classList.add('d-none');
  }
}

function submitExtend() {
  const idx = document.getElementById('rentalSelect').value;
  const newDate = document.getElementById('newDate').value;
  const reason = document.getElementById('reasonInput').value;

  if (idx === '') { alert('비품을 선택하세요.'); return; }
  if (!newDate) { alert('연장 반납 예정일을 선택하세요.'); return; }

  const r = rentals[idx];

  fetch('extendRequest.do', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'rentalId=' + encodeURIComponent(r.rentalId)
      + '&newReturnDate=' + encodeURIComponent(newDate)
      + '&reason=' + encodeURIComponent(reason)
  })
    .then(res => res.text())
    .then(() => {
      alert('연장 요청이 접수되었습니다. 관리자 승인 후 반납 예정일이 변경됩니다.');
      location.href = 'main.do';
    })
    .catch(err => {
      console.error('연장 요청 실패:', err);
      alert('연장 요청 중 오류가 발생했습니다.');
    });
}

loadMyRentals();
</script>
</body>
</html>
