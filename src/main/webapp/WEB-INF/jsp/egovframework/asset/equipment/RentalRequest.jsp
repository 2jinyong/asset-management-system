<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>대여 요청</title>
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
    <h1 class="h5 fw-bold mb-0">대여 요청</h1>
  </div>

  <div class="page-card p-4">
    <form method="post" action="rentalRequest.do" onsubmit="return validateForm()">
      <!-- equipmentId 대신 equipmentName 전송, 서버에서 quantity만큼 실제 id 배정 -->
      <input type="hidden" id="equipmentName" name="equipmentName" value="">

      <div class="mb-3">
        <label class="form-label fw-semibold small">비품 종류</label>
        <select class="form-select" id="category" onchange="loadEquipmentList()">
          <option value="">-- 선택 --</option>
          <c:forEach var="cat" items="${categoryList}">
            <option>${cat}</option>
          </c:forEach>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold small">비품 선택</label>
        <select class="form-select" id="itemSelect" onchange="showItemInfo()">
          <option value="">-- 비품 종류를 먼저 선택하세요 --</option>
        </select>
        <div class="bg-light rounded-3 p-3 small mt-2 d-none" id="itemInfo">
          <table class="table table-borderless table-sm mb-0">
            <tr><td class="text-secondary" style="width:100px;">모델명</td><td id="infoModel">-</td></tr>
            <tr><td class="text-secondary">재고</td><td id="infoStatus">-</td></tr>
          </table>
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold small">수량</label>
        <select class="form-select" id="quantity" name="quantity" disabled>
          <option value="">-- 비품을 먼저 선택하세요 --</option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold small">대여 시작일</label>
        <input type="date" class="form-control" id="rentalDate" name="rentalDate">
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold small">반납 예정일</label>
        <input type="date" class="form-control" id="returnDate" name="returnDate" onchange="validateDate()">
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold small">사용 목적</label>
        <textarea class="form-control" name="purpose" rows="3" placeholder="사용 목적을 입력하세요"></textarea>
      </div>

      <button type="submit" class="btn btn-brand w-100 py-2 fw-bold">대여 요청 제출</button>
    </form>
  </div>
</div>
<script>
function loadEquipmentList() {
  const category = document.getElementById('category').value;
  const sel = document.getElementById('itemSelect');
  sel.innerHTML = '<option value="">-- 선택 --</option>';
  document.getElementById('itemInfo').classList.add('d-none');
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
    info.classList.remove('d-none');

    qtyEl.innerHTML = '';
    for (let i = 1; i <= count; i++) {
      const o = document.createElement('option');
      o.value = i;
      o.textContent = i + '개';
      qtyEl.appendChild(o);
    }
    qtyEl.disabled = count === 0;
  } else {
    info.classList.add('d-none');
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
