<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
    <p class="page-title">📋 대여 요청</p>
  </div>
  <div class="card">
    <form method="post" action="rentalRequest.do" onsubmit="return validateForm()">
      <!-- equipmentId 대신 equipmentName 전송, 서버에서 quantity만큼 실제 id 배정 -->
      <input type="hidden" id="equipmentName" name="equipmentName" value="">

      <div class="form-group">
        <label>비품 종류</label>
        <select id="category" onchange="loadEquipmentList()">
          <option value="">-- 선택 --</option>
          <c:forEach var="cat" items="${categoryList}">
            <option>${cat}</option>
          </c:forEach>
        </select>
      </div>

      <div class="form-group">
        <label>비품 선택</label>
        <select id="itemSelect" onchange="showItemInfo()">
          <option value="">-- 비품 종류를 먼저 선택하세요 --</option>
        </select>
        <div class="item-info" id="itemInfo">
          <table>
            <tr><td>모델명</td><td id="infoModel">-</td></tr>
            <tr><td>재고</td><td id="infoStatus">-</td></tr>
          </table>
        </div>
      </div>

      <div class="form-group">
        <label>수량</label>
        <select id="quantity" name="quantity" disabled>
          <option value="">-- 비품을 먼저 선택하세요 --</option>
        </select>
      </div>

      <div class="form-group">
        <label>대여 시작일</label>
        <input type="date" id="rentalDate" name="rentalDate">
      </div>

      <div class="form-group">
        <label>반납 예정일</label>
        <input type="date" id="returnDate" name="returnDate" onchange="validateDate()">
      </div>

      <div class="form-group">
        <label>사용 목적</label>
        <textarea name="purpose" placeholder="사용 목적을 입력하세요"></textarea>
      </div>

      <button type="submit" class="btn-submit">대여 요청 제출</button>
    </form>
  </div>
</div>
<script>
function loadEquipmentList() {
  const category = document.getElementById('category').value;
  const sel = document.getElementById('itemSelect');
  sel.innerHTML = '<option value="">-- 선택 --</option>';
  document.getElementById('itemInfo').style.display = 'none';
  document.getElementById('equipmentName').value = '';
  document.getElementById('quantity').innerHTML = '<option value="">-- 비품을 먼저 선택하세요 --</option>';
  document.getElementById('quantity').disabled = true;

  if (!category) return;

  fetch('equipmentByCategory.do?category=' + encodeURIComponent(category))
    .then(res => res.json())
    .then(data => {
      if (data.length === 0) {
        sel.innerHTML = '<option value="">대여 가능한 비품이 없습니다.</option>';
        return;
      }
      data.forEach(item => {
        const opt = document.createElement('option');
        opt.value = item.equipment_name;
        opt.textContent = item.equipment_name + ' (재고 ' + item.available_count + '개)';
        opt.dataset.name = item.equipment_name;
        opt.dataset.count = item.available_count;
        sel.appendChild(opt);
      });
    })
    .catch(err => console.error('비품 목록 로드 실패:', err));
}

function showItemInfo() {
  const sel = document.getElementById('itemSelect');
  const opt = sel.options[sel.selectedIndex];
  const info = document.getElementById('itemInfo');
  const qtyEl = document.getElementById('quantity');

  if (opt && opt.value) {
    const count = parseInt(opt.dataset.count, 10);

    document.getElementById('equipmentName').value = opt.value;
    document.getElementById('infoModel').textContent = opt.dataset.name;
    document.getElementById('infoStatus').textContent = count + '개 대여 가능';
    info.style.display = 'block';

    qtyEl.innerHTML = '';
    for (let i = 1; i <= count; i++) {
      const o = document.createElement('option');
      o.value = i;
      o.textContent = i + '개';
      qtyEl.appendChild(o);
    }
    qtyEl.disabled = count === 0;
  } else {
    info.style.display = 'none';
    qtyEl.innerHTML = '<option value="">-- 비품을 먼저 선택하세요 --</option>';
    qtyEl.disabled = true;
    document.getElementById('equipmentName').value = '';
  }
}

function validateDate() {
  const start = document.getElementById('rentalDate').value;
  const end = document.getElementById('returnDate').value;
  if (start && end && end < start) {
    alert('반납 예정일은 대여 시작일보다 빠를 수 없습니다.');
    document.getElementById('returnDate').value = '';
  }
}

function validateForm() {
  const equipmentName = document.getElementById('equipmentName').value;
  const quantity = document.getElementById('quantity').value;
  const rentalDate = document.getElementById('rentalDate').value;
  const returnDate = document.getElementById('returnDate').value;
  if (!equipmentName) { alert('비품을 선택하세요.'); return false; }
  if (!quantity) { alert('수량을 선택하세요.'); return false; }
  if (!rentalDate) { alert('대여 시작일을 선택하세요.'); return false; }
  if (!returnDate) { alert('반납 예정일을 선택하세요.'); return false; }
  return true;
}
</script>
</body>
</html>