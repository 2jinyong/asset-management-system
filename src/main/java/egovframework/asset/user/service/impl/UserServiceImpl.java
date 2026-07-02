package egovframework.asset.user.service.impl;

/*
 * ============================================================
 * [ServiceImpl 클래스란?]
 * ============================================================
 * UserService 인터페이스의 실제 구현체입니다.
 * "인터페이스에서 정의한 기능을 실제로 어떻게 처리하는가"를 담당합니다.
 *
 * [EgovAbstractServiceImpl 상속]
 * eGovFramework의 서비스 기본 클래스를 상속합니다.
 * - eGov의 공통 예외 처리, 트레이스 처리 기능을 자동으로 사용할 수 있게 됩니다.
 * - context-aspect.xml 의 AOP가 이 클래스의 메서드 예외를 자동으로 가로챕니다.
 *
 * [@Service("userService")]
 * - Spring 빈으로 등록되며 이름이 "userService" 가 됩니다.
 * - UserController 에서 @Resource(name="userService") 로 주입받습니다.
 *
 * [@Resource(name = "userMapper")]
 * - "userMapper" 이름의 빈(UserMapper 인터페이스 구현체)을 주입받습니다.
 * - 실제 DB 접근(SQL 실행)은 이 mapper를 통해 이루어집니다.
 * ============================================================
 */
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.asset.user.service.UserMapper;
import egovframework.asset.user.service.UserService;
import egovframework.asset.user.service.UserVO;

@Service("userService") // "userService" 라는 이름으로 Spring 빈 등록
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService {

    // @Resource: 이름(name)으로 Spring 빈을 찾아 주입
    // @Autowired 는 타입으로 찾고, @Resource 는 이름으로 찾는 차이가 있음
    @Resource(name = "userMapper")
    private UserMapper userMapper;

    /**
     * [회원가입 처리]
     * 1. 이미 가입 신청했거나(승인대기 'P') 이미 활성('Y')인 이메일인지 먼저 확인
     * 2. 없으면 기본값(권한, 사용여부) 설정 후 DB에 저장 - 승인대기('P') 상태로 저장
     *    관리자가 승인해야 use_yn='Y' 로 바뀌어 로그인이 가능해짐
     */
    @Override
    public int insertUser(UserVO userVO) {

        // Step 1: 이메일 중복 체크
        // selectUserByEmail(use_yn='Y'만 조회) 대신 selectUserByEmailAny(P/Y 모두 조회)를 써야
        // "승인 대기 중"인 이메일로 중복 가입 신청하는 것도 막을 수 있다.
        UserVO existingUser = userMapper.selectUserByEmailAny(userVO.getEmail());
        if (existingUser != null) {
            return 0; // 이미 가입 신청했거나 활성 상태인 이메일 → 0 반환 (컨트롤러에서 에러 처리)
        }

        // Step 2: 기본값 설정
        // 회원가입 시 권한은 일반 사용자("USER"), 사용 여부는 승인대기("P") 로 고정
        userVO.setRole("USER");
        userVO.setUseYn("P");

        // Step 3: DB에 INSERT 실행
        // userMapper.insertUser() 호출 → UserMapper.xml 의 <insert id="insertUser"> 실행
        return userMapper.insertUser(userVO);
    }

    /**
     * [로그인 처리]
     * 1. 이메일로 DB에서 사용자 조회
     * 2. 비밀번호 일치 여부 확인
     * 3. 일치하면 사용자 정보 반환, 불일치하면 null 반환
     *
     * ⚠ 실무 주의사항:
     *   비밀번호는 반드시 암호화(BCrypt 등)해서 저장/비교해야 합니다.
     *   현재는 학습 목적으로 평문 비교를 사용하지만,
     *   실제 서비스에서는 Spring Security의 BCryptPasswordEncoder를 사용하세요.
     */
    @Override
    public UserVO login(UserVO userVO) {

        // Step 1: 이메일로 사용자 조회 (use_yn='Y' 인 활성 계정만)
        UserVO findUser = userMapper.selectUserByEmail(userVO.getEmail());

        // Step 2: 조회된 사용자가 없거나 비밀번호가 다르면 null 반환
        if (findUser == null) {
            return null; // 해당 이메일 없음
        }
        if (!findUser.getPassword().equals(userVO.getPassword())) {
            return null; // 비밀번호 불일치
        }

        // Step 3: 이메일과 비밀번호가 모두 일치 → 사용자 정보 반환
        return findUser;
    }

    @Override
    public UserVO findByEmailIncludingPending(String email) {
        return userMapper.selectUserByEmailAny(email);
    }

    @Override
    public UserVO findByEmailAnyStatus(String email) {
        return userMapper.selectUserByEmailAllStatus(email);
    }

    @Override
    public List<UserVO> getPendingUserList() {
        return userMapper.selectPendingUserList();
    }

    @Override
    public int approveUser(Long userId) {
        return userMapper.updateUserApprove(userId);
    }

    @Override
    public int rejectUser(Long userId) {
        return userMapper.updateUserReject(userId);
    }

    @Override
    public int withdrawUser(Long userId) {
        return userMapper.updateUserWithdraw(userId);
    }
}
