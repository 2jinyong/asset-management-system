<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>연장 요청</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Malgun Gothic', sans-serif; background: #f5f6fa; color: #222; }
  .header { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 14px 32px; display: flex; align-items: center; justify-content: space-between; }
  .header .logo { font-size: 17px; font-weight: bold; color: #2d5be3; text-decoration: none; }
  .header .user-info { font-size: 13px; color: #666; display: flex; align-items: center; gap: 8px; }
  .avatar { width: 32px; height: 32px; border-radius: 50%; background: #dce8ff; color: #2d5be3; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: bold; }
  .btn { font-size: 12px; padding: 5px 12px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; text-decoration: none; display: inline-block; }
  .btn-logout { background: #f0f0f0; color: #555; }
  .btn-mypage { background: #eef3ff; color: #2d5be3; }
  .container { max-width: 960px; margin: 32px auto; padding: 0 24px; }
  .page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; }
  .back-btn { font-size: 13px; color: #2d5be3; text-decoration: none; }
  .back-btn:hover { text-decoration: underline; }
  .page-title { font-size: 20px; font-weight: bold; }
  .card { background: #fff; border-radius: 10px; border: 1px solid #e8e8e8; padding: 28px; }
  .form-group { margin-bottom: 20px; }
  .form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 6px; font-weight: bold; }
  .form-group select, .form-group input, .form-group textarea {
    width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; font-family: 'Malgun Gothic', sans-serif; outline: none;
  }
  .form-group select:focus, .form-group input:focus, .form-group textarea:focus { border-color: #e89b00; }
  .form-group textarea { resize: vertical; height: 90px; }
  .current-info { background: #fff9ee; border: 1px solid #ffe0a0; border-radius: 7px; padding: 14px 16px; font-size: 13px; margin-top: 8px; display: none; }
  .current-info table { width: 100%; border-collapse: collapse; }
  .current-info td { padding: 4px 8px; }
  .current-info td:first-child { color: #888; width: 110px; }
  .btn-submit { width: 100%; padding: 13px; background: #e89b00; color: #fff; border: none; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 8px; }
  .btn-submit:hover { background: #c47f00; }
</style>
</head>
<body>
<div class="header">
  <a href="main.do" class="logo">&#128230; 사내 비품 관리 시스템</a>
  <div class="user-info">
    <c:if test="${sessionScope.loginUser.role == 'USER'}">
      <div class="avatar">사원</div>
    </c:if>
    <span>${sessionScope.loginUser.userName}</span>
    <a href="<%=request.getContextPath()%>/user/myInfo.do" class="btn btn-mypage">내 정보</a>
    <a href="<%=request.getContextPath()%>/user/logout.do" class="btn btn-logout">로그아웃</a>
  </div>
</div>
<div class="container">
  <div class="page-header">
    <a href="main.do" class="back-btn">← 메인으로</a>
    <p class="page-title">📅 연장 요청</p>
  </div>
  <div class="card">
    <div class="form-group">
      <label>대여 중인 비품 선택</label>
      <select id="rentalSelect" onchange="showCurrent()">
        <option value="">-- 선택 --</option>
      </select>
      <div class="current-info" id="currentInfo">
        <table>
          <tr><td>모델명</td><td id="curModel">-</td></tr>
          <tr><td>현재 반납일</td><td id="curDue">-</td></tr>
        </table>
      </div>
    </div>
    <div class="form-group">
      <label>연장 반납 예정일</label>
      <input type="date" id="newDate">
    </div>
    <div class="form-group">
      <label>연장 사유</label>
      <textarea id="reasonInput" placeholder="연장이 필요한 사유를 입력하세요"></textarea>
    </div>
    <button class="btn-submit" onclick="submitExtend()">연장 요청 제출</button>
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
    info.style.display = 'block';
  } else {
    info.style.display = 'none';
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