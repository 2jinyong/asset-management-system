-- ============================================================
-- 사내 비품관리시스템 DB 스키마
-- ============================================================
-- 실행 전 확인사항:
--   1. db.properties 의 DB URL, 계정, 비밀번호가 올바른지 확인
--   2. 사용하는 DB에 맞게 문법 조정 필요 (MySQL/MariaDB 기준 작성)
-- ============================================================

-- [users 테이블: 로그인/회원가입 기능의 핵심 테이블]
CREATE TABLE IF NOT EXISTS `users` (
    user_id         BIGINT          NOT NULL AUTO_INCREMENT   COMMENT '사용자 고유 ID (PK, 자동증가)',
    user_name       VARCHAR(50)     NOT NULL                  COMMENT '사용자 실명',
    email           VARCHAR(100)    NOT NULL UNIQUE           COMMENT '이메일 (로그인 아이디, 중복 불가)',
    password        VARCHAR(255)    NOT NULL                  COMMENT '비밀번호 (실무: BCrypt 암호화 저장)',
    employee_number VARCHAR(20)     NULL                      COMMENT '사원번호 (선택)',
    role            VARCHAR(20)     NOT NULL DEFAULT 'USER'   COMMENT '권한: ADMIN(관리자) / USER(일반)',
    use_yn          CHAR(1)         NOT NULL DEFAULT 'Y'      COMMENT '사용여부: Y=활성, N=비활성(탈퇴)',
    reg_date        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시 (자동설정)',
    update_date     DATETIME        ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시 (자동갱신)',
    PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 계정 테이블';

-- [테스트용 관리자 계정 초기 데이터]
-- 실제 서비스 전 반드시 비밀번호 변경 필요
INSERT INTO `user` (user_name, email, password, employee_number, role, use_yn)
VALUES ('시스템관리자', 'admin@company.com', 'admin1234', 'ADM001', 'ADMIN', 'Y');
