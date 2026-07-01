<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>대여 요청</title>
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
  width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 7px;
  font-size: 14px; font-family: 'Malgun Gothic', sans-serif; outline: none; transition: border-color 0.15s;
}
.form-group select:focus, .form-group input:focus, .form-group textarea:focus { border-color: #2d5be3; }
.form-group textarea { resize: vertical; height: 90px; }
.item-info { background: #f8f9fb; border-radius: 7px; padding: 14px 16px; font-size: 13px; color: #555; margin-top: 8px; display: none; }
.item-info table { width: 100%; border-collapse: collapse; }
.item-info td { padding: 4px 8px; }
.item-info td:first-child { color: #888; width: 100px; }
.avail-badge { display: inline-block; margin-left: 8px; font-size: 12px; padding: 2px 8px; border-radius: 20px; background: #eafaf1; color: #1a7a45; font-weight: bold; }
.avail-badge.none { background: #ffeaea; color: #c0392b; }
.btn-submit { width: 100%; padding: 13px; background: #2d5be3; color: #fff; border: none; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin-top: 8px; }
.btn-submit:hover { background: #1e46c7; }
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
    <p class="page-title">📋 대여 요청</p>
  </div>
  <div class="card">
    <div class="form-group">
      <label>비품 종류</label>
      <select id="category" onchange="updateItems()">
        <option value="">-- 선택 --</option>
        <option>모니터</option>
        <option>태블릿 PC</option>
        <option>의자</option>
        <option>카메라</option>
        <option>보조배터리</option>
        <option>빔프로젝터</option>
      </select>
    </div>
    <div class="form-group">
      <label>비품 선택</label>
      <select id="item" onchange="showItemInfo()">
        <option value="">-- 비품 종류를 먼저 선택하세요 --</option>
      </select>
      <div class="item-info" id="itemInfo">
        <table>
          <tr><td>모델명</td><td id="infoModel">-</td></tr>
          <tr><td>모델번호</td><td id="infoSerial">-</td></tr>
          <tr><td>상태</td><td id="infoStatus">-</td></tr>
          <tr><td>대여 가능 수량</td><td id="infoAvail">-</td></tr>
        </table>
      </div>
    </div>
    <div class="form-group">
      <label>수량 <span id="availBadge"></span></label>
      <select id="quantity" disabled>
        <option value="">-- 비품을 먼저 선택하세요 --</option>
      </select>
    </div>
    <div class="form-group">
      <label>대여 시작일</label>
      <input type="date" id="startDate">
    </div>
    <div class="form-group">
      <label>반납 예정일</label>
      <input type="date" id="endDate" onchange="validateDate()">
    </div>
    <div class="form-group">
      <label>사용 목적</label>
      <textarea placeholder="사용 목적을 입력하세요"></textarea>
    </div>
    <button class="btn-submit" onclick="submitRequest()">대여 요청 제출</button>
  </div>
</div>
<script>
// 더미 데이터: total=전체, using=대여중, report=신고접수 → available = total - using - report
const items = {
  '모니터': [
    { name: 'LG 27인치 4K',      serial: 'MON-001', total: 5, using: 2, report: 0 },
    { name: 'Samsung 24인치 FHD', serial: 'MON-002', total: 5, using: 1, report: 1 }
  ],
  '태블릿 PC': [
    { name: 'iPad Air 5세대', serial: 'TAB-001', total: 4, using: 2, report: 1 },
    { name: 'Galaxy Tab S8',  serial: 'TAB-002', total: 4, using: 1, report: 0 }
  ],
  '카메라': [
    { name: '캐논 EOS R50', serial: 'CAM-001', total: 3, using: 2, report: 1 },
    { name: '소니 ZV-E10',  serial: 'CAM-002', total: 3, using: 1, report: 0 }
  ],
  '보조배터리': [
    { name: 'Anker 20000mAh', serial: 'BAT-001', total: 8, using: 3, report: 1 }
  ],
  '빔프로젝터': [
    { name: 'Epson EB-X49', serial: 'PRJ-001', total: 2, using: 1, report: 0 }
  ],
  '의자': [
    { name: '허먼밀러 에어론', serial: 'CHR-001', total: 6, using: 2, report: 0 }
  ]
};

function updateItems() {
  const cat = document.getElementById('category').value;
  const sel = document.getElementById('item');
  sel.innerHTML = '<option value="">-- 선택 --</option>';
  document.getElementById('itemInfo').style.display = 'none';
  document.getElementById('quantity').innerHTML = '<option value="">-- 비품을 먼저 선택하세요 --</option>';
  document.getElementById('quantity').disabled = true;
  document.getElementById('availBadge').innerHTML = '';
  if (items[cat]) {
    items[cat].forEach((it) => {
      const avail = it.total - it.using - it.report;
      const opt = document.createElement('option');
      opt.value = it.serial;
      opt.textContent = it.name + ' (' + it.serial + ')' + (avail <= 0 ? ' - 대여 불가' : '');
      opt.disabled = avail <= 0;
      opt.dataset.name = it.name;
      opt.dataset.serial = it.serial;
      opt.dataset.total = it.total;
      opt.dataset.using = it.using;
      opt.dataset.report = it.report;
      sel.appendChild(opt);
    });
  }
}

function showItemInfo() {
  const sel = document.getElementById('item');
  const opt = sel.options[sel.selectedIndex];
  const info = document.getElementById('itemInfo');
  const qtyEl = document.getElementById('quantity');
  const badge = document.getElementById('availBadge');

  if (opt && opt.value) {
    const avail = opt.dataset.total - opt.dataset.using - opt.dataset.report;
    document.getElementById('infoModel').textContent = opt.dataset.name;
    document.getElementById('infoSerial').textContent = opt.dataset.serial;
    document.getElementById('infoStatus').textContent = avail > 0 ? '대여 가능' : '대여 불가';
    document.getElementById('infoAvail').textContent = avail + '개 (전체 ' + opt.dataset.total + ' - 대여중 ' + opt.dataset.using + ' - 신고접수 ' + opt.dataset.report + ')';
    info.style.display = 'block';

    // 수량 드롭다운 세팅
    qtyEl.innerHTML = '';
    if (avail > 0) {
      for (let i = 1; i <= avail; i++) {
        const o = document.createElement('option');
        o.value = i;
        o.textContent = i + '개';
        qtyEl.appendChild(o);
      }
      qtyEl.disabled = false;
      badge.innerHTML = '<span class="avail-badge">대여 가능 ' + avail + '개</span>';
    } else {
      qtyEl.innerHTML = '<option>대여 가능한 수량 없음</option>';
      qtyEl.disabled = true;
      badge.innerHTML = '<span class="avail-badge none">대여 불가</span>';
    }
  } else {
    info.style.display = 'none';
    qtyEl.innerHTML = '<option value="">-- 비품을 먼저 선택하세요 --</option>';
    qtyEl.disabled = true;
    badge.innerHTML = '';
  }
}

function validateDate() {
  const start = document.getElementById('startDate').value;
  const end = document.getElementById('endDate').value;
  if (start && end && end < start) {
    alert('반납 예정일은 대여 시작일보다 빠를 수 없습니다.');
    document.getElementById('endDate').value = '';
  }
}

function submitRequest() {
  const item = document.getElementById('item').value;
  const qty = document.getElementById('quantity').value;
  const start = document.getElementById('startDate').value;
  const end = document.getElementById('endDate').value;

  if (!item) { alert('비품을 선택하세요.'); return; }
  if (!qty)  { alert('수량을 선택하세요.'); return; }
  if (!start){ alert('대여 시작일을 선택하세요.'); return; }
  if (!end)  { alert('반납 예정일을 선택하세요.'); return; }

  alert('대여 요청이 접수되었습니다.\n관리자 승인 후 처리됩니다.');
}
</script>
</body>
</html>
