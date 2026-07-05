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
    `employee_number` VARCHAR(20)     NULL                      COMMENT '사원번호 (앱단에서 중복 체크, 승인대기/활성 상태만 중복 취급)',
    `role`            VARCHAR(20)     NOT NULL DEFAULT 'USER'   COMMENT '권한: ADMIN(관리자) / USER(일반)',
    `use_yn`          CHAR(1)         NOT NULL DEFAULT 'Y'      COMMENT '사용여부: Y=활성, P=가입승인대기, R=가입반려, N=탈퇴',
    `reg_date`        DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시 (자동설정)',
    `update_date`     DATETIME        ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시 (자동갱신)',
    PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 계정 테이블';

-- 3. 관리자 계정 생성 방법
-- 비밀번호는 애플리케이션에서 BCrypt로 암호화되므로, 여기서 평문으로 미리 넣어두지 않는다.
-- 1) 일반 회원가입 화면에서 관리자로 쓸 계정을 정상적으로 가입한다. (role=USER, use_yn=P 로 저장됨)
-- 2) DB에서 아래 쿼리로 해당 계정을 관리자 승인 상태로 직접 승격한다.
--    UPDATE `users` SET `role` = 'ADMIN', `use_yn` = 'Y' WHERE `email` = '가입한이메일';


-- ====================================================================================

-- 1. 카테고리 테이블 생성
-- 비품 카테고리 이름의 마스터 목록. EQUIPMENT.category_id 가 이 테이블을 참조(FK)한다.
-- 관리자는 비품 등록 화면에서 새 카테고리를 추가할 수 있다 (CategoryRegister).

CREATE TABLE `CATEGORY` (
  `category_id` bigint NOT NULL AUTO_INCREMENT,
  `category_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_category_name` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='비품 카테고리 마스터 테이블';

-- 2. 비품 테이블 생성

CREATE TABLE `EQUIPMENT` (
  `equipment_id` bigint NOT NULL AUTO_INCREMENT,
  `equipment_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` bigint NOT NULL COMMENT 'CATEGORY.category_id 참조',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AVAILABLE' COMMENT '비품 상태: AVAILABLE(대여가능) / RENTED(대여중) / BROKEN(고장)',
  `qr_image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`equipment_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `EQUIPMENT_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `CATEGORY` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='비품 테이블';

-- ====================================================================================

-- 3. 대여 테이블 생성
-- 요청(REQUESTED)/연장 요청(extend_status=REQUESTED) 상태는 관리자 승인 전까지
-- EQUIPMENT.status 나 return_date 에 영향을 주지 않는다 (승인 게이트 방식).

CREATE TABLE `RENTAL` (
  `rental_id` bigint NOT NULL AUTO_INCREMENT,
  `equipment_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `quantity` int DEFAULT '1',
  `purpose` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REQUESTED' COMMENT '대여 요청 상태: REQUESTED(승인대기) / APPROVED(승인) / REJECTED(반려)',
  `rental_date` datetime DEFAULT NULL,
  `return_date` datetime DEFAULT NULL,
  `actual_return_date` datetime DEFAULT NULL,
  `extend_status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '연장 요청 상태: REQUESTED(승인대기) / APPROVED(승인) / REJECTED(반려)',
  `requested_return_date` datetime DEFAULT NULL COMMENT '연장 요청 시 희망 반납일 (승인 전까지 임시 저장, 승인되면 return_date 로 반영)',
  `extend_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '연장 요청 사유',
  PRIMARY KEY (`rental_id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `RENTAL_ibfk_1` FOREIGN KEY (`equipment_id`) REFERENCES `EQUIPMENT` (`equipment_id`),
  CONSTRAINT `RENTAL_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='대여 테이블';

-- ====================================================================================

-- 4. 신고 테이블 생성
-- 신고 접수(status=PENDING) 시점에는 EQUIPMENT.status 나 RENTAL 을 건드리지 않고,
-- 관리자가 승인해야 비품이 BROKEN 처리되고 관련 대여 건이 종료된다.

CREATE TABLE `REPORT` (
  `report_id` bigint NOT NULL AUTO_INCREMENT,
  `equipment_id` bigint NOT NULL,
  `issue_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` bigint NOT NULL,
  `content` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '신고 처리 상태: PENDING(승인대기) / APPROVED(승인) / REJECTED(반려)',
  `rental_id` bigint DEFAULT NULL COMMENT '신고 대상 대여 건 (승인 시 종료 처리용)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `REPORT_ibfk_2` (`user_id`),
  CONSTRAINT `REPORT_ibfk_1` FOREIGN KEY (`equipment_id`) REFERENCES `EQUIPMENT` (`equipment_id`),
  CONSTRAINT `REPORT_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `REPORT_ibfk_3` FOREIGN KEY (`rental_id`) REFERENCES `RENTAL` (`rental_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='비품 문제 신고 테이블';