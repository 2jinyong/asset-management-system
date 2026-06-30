package egovframework.asset.user.service;

/*
 * ============================================================
 * [VO (Value Object) + Bean Validation 어노테이션]
 * ============================================================
 * VO 클래스에 javax.validation.constraints 어노테이션을 붙이면
 * 컨트롤러에서 @Valid 사용 시 Spring이 자동으로 유효성을 검사합니다.
 *
 * [유효성 검사 흐름]
 *   폼 제출 → @Valid UserVO 자동 검증 → 실패 시 BindingResult 에 오류 저장
 *   → bindingResult.hasErrors() == true → JSP로 되돌아감
 *   → <form:errors path="필드명"> 이 오류 메시지 출력
 *
 * [주요 어노테이션 종류]
 *   @NotBlank  : null, "", "   " (공백만) 모두 거부 → 가장 엄격한 문자열 필수 검사
 *   @NotEmpty  : null, "" 거부 → 공백 문자열은 통과 (@NotBlank 보다 약함)
 *   @NotNull   : null 만 거부 → 빈 문자열은 통과 (문자열에는 잘 안 씀)
 *   @Email     : 이메일 형식 검사 (@ 포함 여부 등)
 *   @Size      : 문자열 길이 / 컬렉션 크기 범위 검사
 *   @Min/@Max  : 숫자 최솟값/최댓값
 *   @Pattern   : 정규식 패턴 검사
 * ============================================================
 */
import java.time.LocalDateTime;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

import lombok.Data;

@Data
public class UserVO {

    /** PK (DB 자동증가, 회원가입 시 불필요) */
    private Long userId;

    /**
     * 사용자 이름 (필수)
     * @NotBlank: null, 빈 문자열, 공백만 있는 문자열 모두 거부
     */
    @NotBlank(message = "이름을 입력해주세요.")
    private String userName;

    /**
     * 이메일 - 로그인 아이디 (필수 + 형식 검사)
     * @Email: "abc@test.com" 형식인지 검사 (null 은 통과 → @NotBlank 와 함께 사용)
     */
    @NotBlank(message = "이메일을 입력해주세요.")
    @Email(message = "올바른 이메일 형식이 아닙니다.")
    private String email;

    /**
     * 비밀번호 (필수 + 최소 8자)
     * @NotBlank 가 먼저 null/빈값을 차단하고,
     * @Size 가 8자 미만을 차단합니다.
     */
    @NotBlank(message = "비밀번호를 입력해주세요.")
    @Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
    private String password;

    /**
     * 사원번호 (필수)
     */
    @NotBlank(message = "사원번호를 입력해주세요.")
    private String employeeNumber;

    /** 권한: "ADMIN" / "USER" (서비스에서 기본값 "USER" 설정) */
    private String role;

    /** 사용 여부: "Y"=활성, "N"=비활성 (서비스에서 기본값 "Y" 설정) */
    private String useYn;

    /** 가입일시 (DB DEFAULT CURRENT_TIMESTAMP) */
    private LocalDateTime regDate;

    /** 수정일시 */
    private LocalDateTime updateDate;
}
