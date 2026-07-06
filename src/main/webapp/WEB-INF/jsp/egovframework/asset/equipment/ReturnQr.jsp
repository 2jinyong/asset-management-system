<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>반납 처리</title>
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
  .card { background: #fff; border-radius: 10px; border: 1px solid #e8e8e8; padding: 28px; margin-bottom: 20px; }
  .qr-box { border: 2px dashed #b0c4ff; border-radius: 10px; padding: 40px; text-align: center; color: #888; cursor: pointer; margin-bottom: 20px; }
  .qr-box:hover { background: #f0f4ff; }
  .qr-icon { font-size: 52px; margin-bottom: 10px; }
  .qr-box p { font-size: 14px; }
  .divider { text-align: center; color: #aaa; font-size: 13px; margin: 16px 0; position: relative; }
  .divider::before, .divider::after { content: ''; position: absolute; top: 50%; width: 44%; height: 1px; background: #e0e0e0; }
  .divider::before { left: 0; } .divider::after { right: 0; }
  .form-group { margin-bottom: 16px; }
  .form-group label { display: block; font-size: 13px; color: #555; margin-bottom: 6px; font-weight: bold; }
  .form-group input { width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 7px; font-size: 14px; outline: none; }
  .form-group input:focus { border-color: #2d5be3; }
  .item-confirm { background: #f0f4ff; border-radius: 8px; padding: 16px; font-size: 14px; margin-bottom: 16px; display: none; }
  .item-confirm table { width: 100%; border-collapse: collapse; }
  .item-confirm td { padding: 5px 8px; }
  .item-confirm td:first-child { color: #888; width: 100px; }
  .btn-submit { width: 100%; padding: 13px; background: #22a95b; color: #fff; border: none; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; }
  .btn-submit:hover { background: #1a8a49; }
  .btn-search { padding: 10px 18px; background: #2d5be3; color: #fff; border: none; border-radius: 7px; font-size: 14px; cursor: pointer; white-space: nowrap; }
  .input-row { display: flex; gap: 8px; }
  .input-row input { flex: 1; }
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
    <p class="page-title">📷 반납 처리</p>
  </div>
  <div class="card">
    <div class="qr-box" onclick="alert('QR 스캔 기능 (ZXing 연동 예정)')">
      <div class="qr-icon">📷</div>
      <p>QR 코드를 스캔하세요</p>
      <p style="font-size:12px; margin-top:4px;">클릭하여 카메라 실행</p>
    </div>
    <div class="divider">또는 직접 입력</div>
    <div class="form-group">
      <label>시리얼 넘버 직접 입력</label>
      <div class="input-row">
        <input type="text" id="serialInput" placeholder="예: 78">
        <button class="btn-search" onclick="searchItem()">조회</button>
      </div>
    </div>
    <div class="item-confirm" id="itemConfirm">
      <table>
        <tr><td>비품명</td><td id="retName">-</td></tr>
        <tr><td>모델번호</td><td id="retSerial">-</td></tr>
        <tr><td>대여자</td><td id="retUser">-</td></tr>
        <tr><td>반납 예정일</td><td id="retDue">-</td></tr>
      </table>
    </div>
    <button class="btn-submit" onclick="submitReturn()">반납 확인</button>
  </div>
</div>
<script>
let currentRental = null;

function searchItem() {
  const equipmentId = document.getElementById('serialInput').value.trim();
  const box = document.getElementById('itemConfirm');

  if (!equipmentId) {
    alert('시리얼 넘버(장비 ID)를 입력하세요.');
    return;
  }

  fetch('returnSearch.do?equipmentId=' + encodeURIComponent(equipmentId))
    .then(res => res.json())
    .then(data => {
      if (!data || !data.rentalId) {
        alert('해당 장비의 대여 내역이 없습니다.');
        box.style.display = 'none';
        currentRental = null;
        return;
      }
      currentRental = data;
      document.getElementById('retName').textContent = data.equipmentName;
      document.getElementById('retSerial').textContent = data.equipmentId;
      document.getElementById('retUser').textContent = data.userName;
      document.getElementById('retDue').textContent = data.returnDate;
      box.style.display = 'block';
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