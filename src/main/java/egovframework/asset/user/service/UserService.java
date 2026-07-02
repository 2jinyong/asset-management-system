package egovframework.asset.user.service;

/*
 * ============================================================
 * [Service 인터페이스란?]
 * ============================================================
 * 비즈니스 로직의 "계약서" 역할을 합니다.
 * "어떤 기능을 제공한다"는 명세만 있고, 실제 구현은 ServiceImpl 클래스에서 합니다.
 *
 * [왜 인터페이스를 사용하는가?]
 * - 컨트롤러(UserController)는 UserService 인터페이스에만 의존합니다.
 * - 구현체(UserServiceImpl)가 바뀌어도 컨트롤러 코드를 수정할 필요가 없습니다.
 * - 이를 "의존성 역전 원칙(DIP)" 이라고 합니다.
 *
 * [Spring의 @Resource 어노테이션으로 주입]
 * UserController 에서 아래처럼 사용합니다:
 *   @Resource(name = "userService") // "userService" 이름의 빈을 주입
 *   private UserService userService; // 인터페이스 타입으로 선언
 * ============================================================
 */
import java.util.List;

public interface UserService {

    /**
     * 회원가입 - 새로운 사용자를 등록합니다. (승인 대기 상태로 저장)
     * @param userVO 회원가입할 사용자 정보
     * @return 1=성공, 0=이미 가입 신청했거나 가입된 이메일
     */
    int insertUser(UserVO userVO);

    /**
     * 로그인 - 이메일과 비밀번호를 확인합니다. (use_yn='Y' 인 승인된 계정만 성공)
     * @param userVO 로그인할 사용자 정보 (email, password 사용)
     * @return 로그인 성공 시 사용자 정보 객체, 실패 시 null
     */
    UserVO login(UserVO userVO);

    /**
     * 이메일로 사용자를 조회합니다. (use_yn 무관, 'N' 제외) - 회원가입 중복 체크용
     * @param email 조회할 이메일
     * @return 사용자 정보, 없으면 null
     */
    UserVO findByEmailIncludingPending(String email);

    /**
     * 이메일로 사용자를 조회합니다. (use_yn 상태 무관, 전부) - 로그인 실패 사유 구분용
     * @param email 조회할 이메일
     * @return 사용자 정보, 없으면 null
     */
    UserVO findByEmailAnyStatus(String email);

    /**
     * 가입 승인 대기 목록을 조회합니다.
     * @return 승인 대기 사용자 목록
     */
    List<UserVO> getPendingUserList();

    /**
     * 가입 승인 처리
     * @param userId 승인할 사용자 ID
     * @return 처리된 행의 수
     */
    int approveUser(Long userId);

    /**
     * 가입 반려 처리
     * @param userId 반려할 사용자 ID
     * @return 처리된 행의 수
     */
    int rejectUser(Long userId);

    /**
     * 회원 탈퇴 처리 (본인 계정)
     * @param userId 탈퇴할 사용자 ID
     * @return 처리된 행의 수
     */
    int withdrawUser(Long userId);
}
