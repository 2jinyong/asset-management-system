<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>QR 라벨 인쇄</title>
<link rel="stylesheet" href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">
<link rel="stylesheet" href="<c:url value='/css/egovframework/asset-common.css'/>">
<style>
	@media print {
		.no-print {
			display: none !important;
		}
		body {
			padding: 0;
		}
	}
	.qr-label {
		border: 1px solid #ccc;
		border-radius: 8px;
		padding: 12px;
		text-align: center;
		break-inside: avoid;
	}
	.qr-label img {
		width: 160px;
		height: 160px;
	}
</style>
</head>
<body>
	<div class="container py-4 no-print">
		<div class="d-flex align-items-center gap-3 mb-3">
			<a href="javascript:history.back()" class="text-decoration-none small">← 목록으로</a>
			<h1 class="h5 fw-bold mb-0">QR 라벨 인쇄 (총 ${fn:length(equipmentList)}건)</h1>
			<button class="btn btn-sm btn-brand ms-auto" onclick="window.print()">인쇄</button>
		</div>
	</div>

	<div class="container">
		<div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-3">
			<c:forEach var="item" items="${equipmentList}">
				<div class="col">
					<div class="qr-label">
						<img src="qrImage.do?equipmentId=${item.equipmentId}" alt="QR">
						<div class="fw-semibold small mt-2">${item.equipmentName}</div>
						<div class="text-secondary small">ID: ${item.equipmentId}</div>
					</div>
				</div>
			</c:forEach>
		</div>
	</div>
</body>
</html>
