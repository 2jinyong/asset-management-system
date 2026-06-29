package egovframework.asset.user.service;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class UserVO {

	// 고유아이디
	private Long userId;

	// 이름
	private String userName;

	// 이메일(아이디로사용)
	private String email;

	// 비밀번호
	private String password;

	// 사원번호
	private String employeeNumber;

	// 권한(admin, user)
	private String role;

	// 사용 여부 (Y/N)
	private String useYn;

	// 회원가입일
	private LocalDateTime regDate;

	// 정보수정일
	private LocalDateTime updateDate;
}
