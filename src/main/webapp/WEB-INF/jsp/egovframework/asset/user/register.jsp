<%--
    ============================================================
    [회원가입 화면]
    URL: GET /user/registerView.do
    처리: POST /user/register.do
    ============================================================
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>회원가입 | 사내 비품관리시스템</title>
<link rel="stylesheet"
	href="<c:url value='/css/egovframework/bootstrap/css/bootstrap.min.css'/>">

<style>
body {
	background-color: #f0f2f5;
}

.register-wrapper {
	min-height: 100vh;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 2rem 0;
}

.register-card {
	width: 100%;
	max-width: 500px;
	border: none;
	border-radius: 12px;
	box-shadow: 0 4px 24px rgba(0, 0, 0, 0.10);
}

.register-card .card-header {
	background: #0e9f6e;
	border-radius: 12px 12px 0 0;
	padding: 1.8rem;
	text-align: center;
}

.register-card .card-header h1 {
	color: #fff;
	font-size: 1.3rem;
	font-weight: 700;
	margin: 0;
}

.register-card .card-header p {
	color: rgba(255, 255, 255, 0.8);
	font-size: 0.85rem;
	margin: 0.3rem 0 0;
}

.form-label {
	font-weight: 600;
	font-size: 0.9rem;
}

.required-mark {
	color: #e02424;
	margin-left: 2px;
}

.btn-register {
	background: #0e9f6e;
	border: none;
	font-weight: 600;
}

.btn-register:hover {
	background: #0b8a5e;
}

.password-hint {
	font-size: 0.78rem;
	color: #6b7280;
	margin-top: 4px;
}
</style>
</head>
<body>

	<div class="register-wrapper">
		<div class="register-card card">

			<div class="card-header">
				<h1>회원가입</h1>
				<p>사내 비품관리시스템 계정을 만들어보세요</p>
			</div>

			<div class="card-body p-4">

				<%-- 에러 메시지 (중복 이메일 등) --%>
				<c:if test="${not empty errorMsg}">
					<div class="alert alert-danger py-2 px-3" role="alert">
						<small>${errorMsg}</small>
					</div>
				</c:if>

				<%--
                [회원가입 폼]
                modelAttribute="userVO" → 컨트롤러 registerView() 에서
                @ModelAttribute("userVO") UserVO userVO 로 전달한 빈 UserVO 객체와 연결

                각 <form:input path="필드명"> 은 UserVO 의 해당 필드와 연결됩니다.
                폼 제출(POST) 시 Spring이 자동으로 UserVO 객체를 만들어
                컨트롤러 register() 메서드의 파라미터에 넣어줍니다.
            --%>
				<form:form
					action="${pageContext.request.contextPath}/user/register.do"
					method="post" modelAttribute="userVO" id="registerForm">

					<%--
                    ============================================================
                    [form:errors 태그 설명]
                    백엔드 @Valid 검증 실패 시 오류 메시지를 출력합니다.
                    path="필드명" → 해당 필드의 오류만 표시
                    cssClass     → 출력되는 <span> 태그에 적용할 CSS 클래스
                    ============================================================
                    --%>

					<%-- 이름 --%>
					<div class="mb-3">
						<label for="userName" class="form-label"> 이름 <span class="required-mark">*</span>
						</label>
						<form:input path="userName" id="userName" cssClass="form-control"
							placeholder="실명을 입력하세요" />
						<%-- @NotBlank 검증 실패 시 "이름을 입력해주세요." 출력 --%>
						<form:errors path="userName" cssClass="text-danger small d-block mt-1" />
					</div>

					<%-- 이메일 --%>
					<div class="mb-3">
						<label for="email" class="form-label"> 이메일 <span class="required-mark">*</span>
						</label>
						<form:input path="email" id="email" cssClass="form-control"
							placeholder="이메일 주소 (로그인 아이디로 사용)" />
						<%-- @NotBlank 또는 @Email 검증 실패 시 메시지 출력 --%>
						<form:errors path="email" cssClass="text-danger small d-block mt-1" />
					</div>

					<%-- 비밀번호 --%>
					<div class="mb-3">
						<label for="password" class="form-label"> 비밀번호 <span class="required-mark">*</span>
						</label>
						<form:password path="password" id="password"
							cssClass="form-control" placeholder="비밀번호 입력 (8자 이상)" />
						<%-- @NotBlank / @Size(min=8) 검증 실패 시 메시지 출력 --%>
						<form:errors path="password" cssClass="text-danger small d-block mt-1" />
					</div>

					<%-- 비밀번호 확인 (JS로만 검증 - 서버에는 전송되지 않음) --%>
					<div class="mb-3">
						<label for="passwordConfirm" class="form-label"> 비밀번호 확인 <span class="required-mark">*</span>
						</label>
						<input type="password" id="passwordConfirm" class="form-control"
							placeholder="비밀번호를 한 번 더 입력하세요">
						<small id="pwMatchMsg" class="mt-1 d-block"></small>
					</div>

					<%-- 사원번호 (필수) --%>
					<div class="mb-4">
						<label for="employeeNumber" class="form-label">
							사원번호 <span class="required-mark">*</span>
						</label>
						<form:input path="employeeNumber" id="employeeNumber"
							cssClass="form-control" placeholder="사원번호 입력" />
						<%-- @NotBlank 검증 실패 시 "사원번호를 입력해주세요." 출력 --%>
						<form:errors path="employeeNumber" cssClass="text-danger small d-block mt-1" />
					</div>

					<%-- 제출 버튼 --%>
					<div class="d-grid mb-3">
						<button type="submit" class="btn btn-register btn-success btn-lg">
							가입하기</button>
					</div>

					<%-- 로그인 페이지 이동 링크 --%>
					<div class="text-center">
						<small class="text-muted">이미 계정이 있으신가요?</small> <a
							href="<c:url value='/user/loginView.do'/>"
							class="text-decoration-none ms-1"> <small><strong>로그인</strong></small>
						</a>
					</div>

				</form:form>
			</div>
		</div>
	</div>

	<script
		src="<c:url value='/css/egovframework/bootstrap/js/bootstrap.bundle.min.js'/>"></script>

<script>
	document.addEventListener('DOMContentLoaded', function () {
	    var employeeNumberInput = document.getElementById('employeeNumber');
	    var emailInput = document.getElementById('email');
	    var passwordInput = document.getElementById('password');
	    var passwordConfirmInput = document.getElementById('passwordConfirm');
	    var pwMatchMsg = document.getElementById('pwMatchMsg');

	    // [서버 검증 실패로 되돌아온 경우, 원인 필드를 강조해서 알려줌]
	    // (이메일/사원번호 중복은 서버에서만 판별 가능하므로 폼 재제출 후 errorMsg로 표시됨)
	    var errorMsg = "<c:out value='${errorMsg}' />";
	    if (errorMsg.indexOf('사원번호') !== -1) {
	        employeeNumberInput.classList.add('is-invalid');
	        employeeNumberInput.focus();
	    } else if (errorMsg.indexOf('이메일') !== -1) {
	        emailInput.classList.add('is-invalid');
	        emailInput.focus();
	    }
	    [employeeNumberInput, emailInput].forEach(function (input) {
	        input.addEventListener('input', function () {
	            input.classList.remove('is-invalid');
	        });
	    });

	    // [비밀번호 확인 일치 여부 실시간 검증]
	    passwordConfirmInput.addEventListener('input', function () {
	        const pw  = passwordInput.value;
	        const pwc = passwordConfirmInput.value;

	        pwMatchMsg.classList.remove('text-success', 'text-danger');
	        if (pwc === '') {
	            pwMatchMsg.textContent = '';
	        } else if (pw === pwc) {
	            pwMatchMsg.textContent = '비밀번호가 일치합니다';
	            pwMatchMsg.classList.add('text-success');
	        } else {
	            pwMatchMsg.textContent = '비밀번호가 일치하지 않습니다';
	            pwMatchMsg.classList.add('text-danger');
	        }
	    });

	    // [폼 제출 전 유효성 검사]
	    document.getElementById('registerForm').addEventListener('submit', function (e) {
	        const userName  = document.getElementById('userName').value.trim();
	        const email     = emailInput.value.trim();
	        const password  = passwordInput.value;
	        const pwConfirm = passwordConfirmInput.value;
	        const employee  = employeeNumberInput.value.trim();

	        if (userName.length === 0) {
	            alert('이름을 입력해주세요.');
	            document.getElementById('userName').focus();
	            e.preventDefault();
	            return;
	        }

	        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	        if (!emailRegex.test(email)) {
	            alert('올바른 이메일 형식을 입력해주세요.');
	            emailInput.focus();
	            e.preventDefault();
	            return;
	        }

	        if (password.length === 0) {
	            alert('비밀번호를 입력해주세요.');
	            passwordInput.focus();
	            e.preventDefault();
	            return;
	        }

	        if (password !== pwConfirm) {
	            alert('비밀번호가 일치하지 않습니다.');
	            passwordConfirmInput.focus();
	            e.preventDefault();
	            return;
	        }

	        if (employee.length === 0) {
	            alert('사원번호를 입력해주세요.');
	            employeeNumberInput.focus();
	            e.preventDefault();
	            return;
	        }
	    });
	});
</script>

</body>
</html>
