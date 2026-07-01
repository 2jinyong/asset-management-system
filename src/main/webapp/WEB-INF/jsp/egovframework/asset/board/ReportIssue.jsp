<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문제 신고</title>
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
  .form-group select:focus, .form-group input:focus, .form-group textarea:focus { border-color: #e34444; }
  .form-group textarea { resize: vertical; height: 110px; }
  .item-info { background: #fff5f5; border: 1px solid #ffd0d0; border-radius: 7px; padding: 14px 16px; font-size: 13px; margin-top: 8px; display: none; }
  .item-info table { width: 100%; border-collapse: collapse; }
  .item-info td { padding: 4px 8px; }
  .item-info td:first-child { color: #888; width: 100px; }
  .upload-box { border: 2px dashed #ddd; border-radius: 8px; padding: 28px; text-align: center; color: #aaa; cursor: pointer; transition: border-color 0.15s; }
  .upload-box:hover { border-color: #e34444; }
  .upload-box input { display: none; }
  .upload-icon { font-size: 36px; margin-bottom: 8px; }
  .upload-box p { font-size: 13px; }
  .preview-wrap { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
  .preview-img { width: 80px; height: 80px; object-fit: cover; border-radius: 6px; border: 1px solid #eee; }
  .type-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
  .type-btn { padding: 10px; border: 1px solid #ddd; border-radius: 7px; background: #fff; cursor: pointer; font-size: 13px; text-align: center; transition: all 0.15s; }
  .type-btn.active { border-color: #e34444; background: #fff5f5; color: #e34444; font-weight: bold; }
  .btn-submit { width: 100%; padding: 13px; background: #e34444; color: #fff; border: none; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 8px; }
  .btn-submit:hover { background: #c0392b; }
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
    <p class="page-title">🚨 문제 신고</p>
  </div>
  <div class="card">
    <div class="form-group">
      <label>대여 중인 비품 선택</label>
      <select id="itemSelect" onchange="showItemInfo()">
        <option value="">-- 선택 --</option>
        <option value="0">노트북 LG그램 15 (NTB-003)</option>
        <option value="1">캐논 EOS 카메라 (CAM-001)</option>
      </select>
      <div class="item-info" id="itemInfo">
        <table>
          <tr><td>모델명</td><td id="infoModel">-</td></tr>
          <tr><td>모델번호</td><td id="infoSerial">-</td></tr>
        </table>
      </div>
    </div>
    <div class="form-group">
      <label>문제 유형</label>
      <div class="type-grid">
        <div class="type-btn" onclick="selectType(this)">🔧 파손</div>
        <div class="type-btn" onclick="selectType(this)">⚡ 작동 불량</div>
        <div class="type-btn" onclick="selectType(this)">🔋 배터리 문제</div>
        <div class="type-btn" onclick="selectType(this)">🖥 화면 이상</div>
        <div class="type-btn" onclick="selectType(this)">🔌 연결 문제</div>
        <div class="type-btn" onclick="selectType(this)">📝 기타</div>
      </div>
    </div>
    <div class="form-group">
      <label>상세 내용</label>
      <textarea placeholder="문제 상황을 자세히 설명해 주세요"></textarea>
    </div>
    <div class="form-group">
      <label>사진 첨부 (S3 업로드)</label>
      <div class="upload-box" onclick="document.getElementById('fileInput').click()">
        <input type="file" id="fileInput" accept="image/*" multiple onchange="previewImages(event)">
        <div class="upload-icon">📎</div>
        <p>클릭하여 사진 첨부</p>
        <p style="font-size:11px; margin-top:4px;">JPG, PNG 최대 5MB</p>
      </div>
      <div class="preview-wrap" id="previewWrap"></div>
    </div>
    <button class="btn-submit" onclick="alert('문제 신고가 접수되었습니다. 관리자가 확인 후 연락드립니다.')">신고 제출</button>
  </div>
</div>
<script>
const items = [
  { model: 'LG그램 15', serial: 'NTB-003' },
  { model: '캐논 EOS R50', serial: 'CAM-001' }
];
function showItemInfo() {
  const idx = document.getElementById('itemSelect').value;
  const box = document.getElementById('itemInfo');
  if (idx !== '') {
    document.getElementById('infoModel').textContent = items[idx].model;
    document.getElementById('infoSerial').textContent = items[idx].serial;
    box.style.display = 'block';
  } else {
    box.style.display = 'none';
  }
}
function selectType(el) {
  document.querySelectorAll('.type-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
}
function previewImages(e) {
  const wrap = document.getElementById('previewWrap');
  wrap.innerHTML = '';
  Array.from(e.target.files).forEach(file => {
    const img = document.createElement('img');
    img.className = 'preview-img';
    img.src = URL.createObjectURL(file);
    wrap.appendChild(img);
  });
}
</script>
</body>
</html>
