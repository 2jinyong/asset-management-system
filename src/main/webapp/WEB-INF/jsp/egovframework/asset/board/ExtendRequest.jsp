<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
  <a href="test.do" class="logo">&#128230; 사내 비품 관리 시스템</a>
  <div class="user-info"><div class="avatar">김</div><span>김재민 님</span></div>
</div>
<div class="container">
  <div class="page-header">
    <a href="test.do" class="back-btn">← 메인으로</a>
    <p class="page-title">📅 연장 요청</p>
  </div>
  <div class="card">
    <div class="form-group">
      <label>대여 중인 비품 선택</label>
      <select id="rentalSelect" onchange="showCurrent()">
        <option value="">-- 선택 --</option>
        <option value="0">노트북 LG그램 15 (NTB-003)</option>
        <option value="1">캐논 EOS 카메라 (CAM-001)</option>
      </select>
      <div class="current-info" id="currentInfo">
        <table>
          <tr><td>모델명</td><td id="curModel">-</td></tr>
          <tr><td>모델번호</td><td id="curSerial">-</td></tr>
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
      <textarea placeholder="연장이 필요한 사유를 입력하세요"></textarea>
    </div>
    <button class="btn-submit" onclick="alert('연장 요청이 제출되었습니다. 관리자 승인 후 처리됩니다.')">연장 요청 제출</button>
  </div>
</div>
<script>
const rentals = [
  { model: 'LG그램 15', serial: 'NTB-003', due: '2026.07.01' },
  { model: '캐논 EOS R50', serial: 'CAM-001', due: '2026.06.28' }
];
function showCurrent() {
  const idx = document.getElementById('rentalSelect').value;
  const info = document.getElementById('currentInfo');
  if (idx !== '') {
    const r = rentals[idx];
    document.getElementById('curModel').textContent = r.model;
    document.getElementById('curSerial').textContent = r.serial;
    document.getElementById('curDue').textContent = r.due;
    info.style.display = 'block';
  } else {
    info.style.display = 'none';
  }
}
</script>
</body>
</html>
