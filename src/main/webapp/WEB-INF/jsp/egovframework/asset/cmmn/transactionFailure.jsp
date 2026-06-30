<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <title>트랜잭션 오류</title>
</head>
<body>
    <h2>트랜잭션 처리 중 오류가 발생했습니다.</h2>
    <p>${exception.message}</p>
    <a href="/">홈으로</a>
</body>
</html>
