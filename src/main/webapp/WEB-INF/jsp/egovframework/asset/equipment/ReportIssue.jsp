<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>문제 신고</title>
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
    <h1 class="h5 fw-bold mb-0">문제 신고</h1>
  </div>
  <div class="page-card p-4">
    <div class="mb-3">
      <label class="form-label fw-semibold small">대여 중인 비품 선택</label>
      <select class="form-select" id="itemSelect" onchange="showItemInfo()">
        <option value="">-- 선택 --</option>
      </select>
      <div class="rounded-3 p-3 small mt-2 d-none" id="itemInfo" style="background:#fff5f5; border:1px solid #ffd0d0;">
        <table class="table table-borderless table-sm mb-0">
          <tr><td class="text-secondary" style="width:100px;">모델명</td><td id="infoModel">-</td></tr>
          <tr><td class="text-secondary">모델번호</td><td id="infoSerial">-</td></tr>
        </table>
      </div>
    </div>
    <div class="mb-3">
      <label class="form-label fw-semibold small">문제 유형</label>
      <div class="row row-cols-3 g-2">
        <div class="col"><div class="type-option" data-type="BROKEN" onclick="selectType(this)">파손</div></div>
        <div class="col"><div class="type-option" data-type="MALFUNCTION" onclick="selectType(this)">작동 불량</div></div>
        <div class="col"><div class="type-option" data-type="BATTERY" onclick="selectType(this)">배터리 문제</div></div>
        <div class="col"><div class="type-option" data-type="SCREEN" onclick="selectType(this)">화면 이상</div></div>
        <div class="col"><div class="type-option" data-type="CONNECTION" onclick="selectType(this)">연결 문제</div></div>
        <div class="col"><div class="type-option" data-type="ETC" onclick="selectType(this)">기타</div></div>
      </div>
    </div>
    <div class="mb-3">
      <label class="form-label fw-semibold small">상세 내용</label>
      <textarea class="form-control" id="contentInput" rows="4" placeholder="문제 상황을 자세히 설명해 주세요"></textarea>
    </div>
    <div class="mb-3">
      <label class="form-label fw-semibold small">사진 첨부</label>
      <div class="dropzone p-4" onclick="document.getElementById('fileInput').click()">
        <input type="file" class="d-none" id="fileInput" accept="image/*" onchange="previewImage(event)">
        <p class="mb-1">클릭하여 사진 첨부</p>
        <p class="small mb-0">JPG, PNG 최대 5MB</p>
      </div>
      <div class="d-flex flex-wrap gap-2 mt-2" id="previewWrap"></div>
    </div>
    <button class="btn btn-danger w-100 py-2 fw-bold" onclick="submitReport()">신고 제출</button>
  </div>
</div>
<script>
let rentals = [];
let selectedType = '';

function loadMyRentals() {
  fetch('myRentalList.do')
    .then(res => res.json())
    .then(data => {
      rentals = data;
      const sel = document.getElementById('itemSelect');
      sel.innerHTML = '<option value="">-- 선택 --</option>';
      if (data.length === 0) {
        sel.innerHTML = '<option value="">대여 중인 비품이 없습니다.</option>';
        return;
      }
      data.forEach((r, idx) => {
        const opt = document.createElement('option');
        opt.value = idx;
        opt.textContent = r.equipmentName + ' (' + r.equipmentId + ')';
        sel.appendChild(opt);
      });

      const params = new URLSearchParams(window.location.search);
      const equipmentId = params.get('equipmentId');
      if (equipmentId) {
        const matchIdx = data.findIndex(r => String(r.equipmentId) === equipmentId);
        if (matchIdx !== -1) {
          sel.value = matchIdx;
          showItemInfo();
        }
      }
    })
    .catch(err => console.error('대여 목록 로드 실패:', err));
}

function showItemInfo() {
  const idx = document.getElementById('itemSelect').value;
  const box = document.getElementById('itemInfo');
  if (idx !== '') {
    const r = rentals[idx];
    document.getElementById('infoModel').textContent = r.equipmentName;
    document.getElementById('infoSerial').textContent = r.equipmentId;
    box.classList.remove('d-none');
  } else {
    box.classList.add('d-none');
  }
}

function selectType(el) {
  document.querySelectorAll('.type-option').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  selectedType = el.getAttribute('data-type');
}

function previewImage(e) {
  const wrap = document.getElementById('previewWrap');
  wrap.innerHTML = '';
  const file = e.target.files[0];
  if (file) {
    const img = document.createElement('img');
    img.className = 'preview-thumb';
    img.src = URL.createObjectURL(file);
    wrap.appendChild(img);
  }
}

function submitReport() {
  const idx = document.getElementById('itemSelect').value;
  const content = document.getElementById('contentInput').value.trim();
  const fileInput = document.getElementById('fileInput');
  const file = fileInput.files[0];

  if (idx === '') { alert('비품을 선택하세요.'); return; }
  if (!selectedType) { alert('문제 유형을 선택하세요.'); return; }
  if (!content) { alert('상세 내용을 입력하세요.'); return; }
  if (!file) { alert('사진을 첨부하세요.'); return; }

  const r = rentals[idx];

  const formData = new FormData();
  formData.append('rentalId', r.rentalId);
  formData.append('equipmentId', r.equipmentId);
  formData.append('issueType', selectedType);
  formData.append('content', content);
  formData.append('image', file);

  fetch('reportIssue.do', {
    method: 'POST',
    body: formData
  })
    .then(res => res.text())
    .then(() => {
      alert('문제 신고가 접수되었습니다. 관리자가 확인 후 연락드립니다.');
      location.href = 'main.do';
    })
    .catch(err => {
      console.error('신고 제출 실패:', err);
      alert('신고 제출 중 오류가 발생했습니다.');
    });
}

loadMyRentals();
</script>
</body>
</html>
