-- ============================================================
-- 사내 비품관리시스템 DB 스키마 (MySQL/MariaDB)
-- ============================================================


-- 1. 데이터베이스 생성
CREATE SCHEMA IF NOT EXISTS `asset` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `asset`;

-- 2. 테이블 생성: users (사용자 관리)
CREATE TABLE IF NOT EXISTS `users` (
    `user_id`         BIGINT          NOT NULL AUTO_INCREMENT   COMMENT '사용자 고유 ID (PK, 자동증가)',
    `user_name`       VARCHAR(50)     NOT NULL                  COMMENT '사용자 실명',
    `email`           VARCHAR(100)    NOT NULL UNIQUE           COMMENT '이메일 (로그인 아이디, 중복 불가)',
    `password`        VARCHAR(255)    NOT NULL                  COMMENT '비밀번호 (실무: BCrypt 암호화 저장)',
    `employee_number` VARCHAR(20)     NULL                      COMMENT '사원번호 (선택)',
    `role`            VARCHAR(20)     NOT NULL DEFAULT 'USER'   COMMENT '권한: ADMIN(관리자) / USER(일반)',
    `use_yn`          CHAR(1)         NOT NULL DEFAULT 'Y'      COMMENT '사용여부: Y=활성, P=가입승인대기, R=가입반려, N=탈퇴',
    `reg_date`        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시 (자동설정)',
    `update_date`     DATETIME        ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시 (자동갱신)',
    PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 계정 테이블';

-- 3. 초기 데이터 삽입
-- 주의: 실제 운영 환경에서는 비밀번호를 반드시 암호화(BCrypt 등)하여 저장하세요.
INSERT INTO `users` (`user_name`, `email`, `password`, `employee_number`, `role`, `use_yn`)
VALUES ('시스템관리자', 'admin@company.com', 'admin1234', 'ADM001', 'ADMIN', 'Y');


-- ====================================================================================

-- 1. 비품 테이블 생성

CREATE TABLE `EQUIPMENT` (
  `equipment_id` bigint NOT NULL AUTO_INCREMENT,
  `equipment_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AVAILABLE',
  `qr_image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`equipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;