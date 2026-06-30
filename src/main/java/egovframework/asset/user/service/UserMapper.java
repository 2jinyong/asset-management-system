package egovframework.asset.user.service;

/*
 * ============================================================
 * [Mapper 인터페이스란?]
 * ============================================================
 * MyBatis 에서 SQL을 실행하기 위한 Java 인터페이스입니다.
 * 인터페이스만 선언하면 MyBatis가 구현체를 자동으로 만들어줍니다.
 * 직접 구현 클래스를 만들 필요가 없습니다.
 *
 * [eGov의 @Mapper 어노테이션]
 * - 패키지: org.egovframe.rte.psl.dataaccess.mapper.Mapper
 * - Spring 빈으로 자동 등록되며 이름이 "userMapper" 가 됩니다.
 * - context-mapper.xml 의 MapperConfigurer 가 이 어노테이션을 스캔합니다.
 *   (basePackage: "egovframework.asset" 하위를 모두 스캔)
 *
 * [메서드명 규칙]
 * 이 인터페이스의 메서드명은 UserMapper.xml 의 id 속성과 반드시 일치해야 합니다.
 *   예: insertUser() ↔ <insert id="insertUser">
 *   예: selectUserByEmail() ↔ <select id="selectUserByEmail">
 * ============================================================
 */
import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper("userMapper") // Spring 빈 이름을 "userMapper" 로 등록
public interface UserMapper {

    /**
     * 신규 사용자를 DB에 저장합니다. (회원가입)
     * @param userVO 저장할 사용자 정보 (이름, 이메일, 비밀번호, 사원번호, 권한, 사용여부)
     * @return 처리된 행의 수 (성공=1, 실패=0)
     */
    int insertUser(UserVO userVO);

    /**
     * 이메일로 사용자를 조회합니다. (로그인 및 중복 이메일 체크용)
     * @param email 조회할 이메일 주소
     * @return 해당 이메일의 사용자 정보, 없으면 null
     */
    UserVO selectUserByEmail(String email);
}
