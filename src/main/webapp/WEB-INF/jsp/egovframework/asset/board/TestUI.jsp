<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>사내 비품 관리 시스템</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Malgun Gothic', sans-serif; background: #f5f6fa; color: #222; }
  .header { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 14px 32px; display: flex; align-items: center; justify-content: space-between; }
  .header .logo { font-size: 17px; font-weight: bold; color: #2d5be3; }
  .header .user-info { font-size: 13px; color: #666; display: flex; align-items: center; gap: 8px; }
  .avatar { width: 32px; height: 32px; border-radius: 50%; background: #dce8ff; color: #2d5be3; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: bold; }
  .container { max-width: 960px; margin: 32px auto; padding: 0 24px; }
  .page-title { font-size: 20px; font-weight: bold; margin-bottom: 20px; }
  .summary-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 28px; }
  .summary-card { background: #fff; border-radius: 10px; border: 1px solid #e8e8e8; padding: 18px 20px; }
  .summary-card .label { font-size: 12px; color: #888; margin-bottom: 8px; }
  .summary-card .value { font-size: 26px; font-weight: bold; }
  .summary-card.total .value { color: #222; }
  .summary-card.avail .value { color: #22a95b; }
  .summary-card.using .value { color: #e89b00; }
  .summary-card.report .value { color: #e34444; }
  .menu-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 28px; }
  .menu-card { background: #fff; border-radius: 10px; border: 1px solid #e8e8e8; padding: 20px 16px; text-decoration: none; color: #222; display: flex; flex-direction: column; gap: 8px; transition: box-shadow 0.15s, border-color 0.15s; cursor: pointer; }
  .menu-card:hover { box-shadow: 0 2px 12px rgba(0,0,0,0.08); border-color: #b0c4ff; }
  .menu-card .icon { font-size: 28px; }
  .menu-card .menu-title { font-size: 15px; font-weight: bold; }
  .menu-card .menu-desc { font-size: 12px; color: #888; }
  .section-title { font-size: 15px; font-weight: bold; margin-bottom: 12px; color: #333; }
  .rental-table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 10px; overflow: hidden; border: 1px solid #e8e8e8; }
  .rental-table th { background: #f8f9fb; font-size: 13px; color: #666; font-weight: normal; padding: 11px 16px; text-align: left; border-bottom: 1px solid #e8e8e8; }
  .rental-table td { padding: 12px 16px; font-size: 14px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
  .rental-table tr:last-child td { border-bottom: none; }
  .badge { display: inline-block; font-size: 11px; padding: 3px 10px; border-radius: 20px; font-weight: bold; }
  .badge.using { background: #fff4e0; color: #b97a00; }
  .badge.due { background: #ffeaea; color: #c0392b; }
  .badge.done { background: #eafaf1; color: #1a7a45; }
  .btn-group { display: flex; gap: 6px; }
  .btn { font-size: 12px; padding: 5px 12px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; text-decoration: none; display: inline-block; }
  .btn-return { background: #e8f0fe; color: #2d5be3; }
  .btn-extend { background: #fff4e0; color: #b97a00; }
  .btn-report { background: #ffeaea; color: #c0392b; }
  .btn:hover { opacity: 0.8; }
  .category-link { text-decoration: none; color: #222; }
  .category-link:hover { text-decoration: underline; color: #2d5be3; }
</style>
</head>
<body>

<div class="header">
  <span class="logo">&#128230; 사내 비품 관리 시스템</span>
  <div class="user-info">
    <div class="avatar">김</div>
    <span>김재민 님</span>
  </div>
</div>

<div class="container">

  <p class="page-title">비품 현황</p>

 

  <!-- 메뉴 -->
  <div class="menu-grid">
    <a href="rentalRequest.do" class="menu-card">
      <span class="icon">📋</span>
      <span class="menu-title">대여 요청</span>
      <span class="menu-desc">비품 선택 후 신청</span>
    </a>
    <a href="returnQr.do" class="menu-card">
      <span class="icon">📷</span>
      <span class="menu-title">반납 처리</span>
      <span class="menu-desc">QR 스캔으로 반납</span>
    </a>
    <a href="extendRequest.do" class="menu-card">
      <span class="icon">📅</span>
      <span class="menu-title">연장 요청</span>
      <span class="menu-desc">대여 기간 연장 신청</span>
    </a>
    <a href="reportIssue.do" class="menu-card">
      <span class="icon">🚨</span>
      <span class="menu-title">문제 신고</span>
      <span class="menu-desc">이상 상태 신고 및 사진 첨부</span>
    </a>
  </div>

  <!-- 비품 카테고리별 현황 -->
  <p class="section-title">비품 카테고리별 현황</p>
  <table class="rental-table" style="margin-bottom: 28px;">
    <thead>
      <tr>
        <th>비품 종류</th>
        <th style="text-align:center;">전체</th>
        <th style="text-align:center;">대여 가능</th>
        <th style="text-align:center;">대여 중</th>
        <th style="text-align:center;">신고</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="item" items="${categorySummary}">
      <tr>
        <td>
          <a href="equipmentList.do?category=${item.category}" class="category-link">
            ${item.category}
          </a>
        </td>
        <td style="text-align:center;">${item.total}</td>
        <td style="text-align:center; color:#22a95b; font-weight:bold;">${item.available}</td>
        <td style="text-align:center; color:#e89b00; font-weight:bold;">${item.rented}</td>
        <td style="text-align:center; color:#e34444; font-weight:bold;">${item.broken}</td>
      </tr>
      </c:forEach>
    </tbody>
  </table>

  <!-- 내 대여 현황 -->
  <p class="section-title">내 대여 현황</p>
  <table class="rental-table">
    <thead>
      <tr>
        <th>비품명</th>
        <th>대여일</th>
        <th>반납 예정일</th>
        <th>상태</th>
        <th>액션</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>노트북 LG그램 15</td>
        <td>2026.06.20</td>
        <td>2026.07.01</td>
        <td><span class="badge using">대여 중</span></td>
        <td>
          <div class="btn-group">
            <a href="returnQr.do?id=1" class="btn btn-return">반납</a>
            <a href="extendRequest.do?id=1" class="btn btn-extend">연장</a>
            <a href="reportIssue.do?id=1" class="btn btn-report">신고</a>
          </div>
        </td>
      </tr>
      <tr>
        <td>캐논 EOS 카메라</td>
        <td>2026.06.18</td>
        <td>2026.06.28</td>
        <td><span class="badge due">반납 임박</span></td>
        <td>
          <div class="btn-group">
            <a href="returnQr.do?id=2" class="btn btn-return">반납</a>
            <a href="extendRequest.do?id=2" class="btn btn-extend">연장</a>
            <a href="reportIssue.do?id=2" class="btn btn-report">신고</a>
          </div>
        </td>
      </tr>
    </tbody>
  </table>

</div>
</body>
</html>
