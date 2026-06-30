## Git 브랜치 운영 규칙

### 브랜치 구조

* main : 최종 제출 및 배포용 브랜치
* develop : 개발 통합 브랜치
* feature/기능명-이름 : 기능 개발 브랜치

### 브랜치 예시

```text
main
develop

feature/login-jinyong
feature/qr-jinyong

feature/rental-teammate
feature/approval-teammate
```

### 작업 순서

1. develop 브랜치 최신화

```bash
git switch develop
git pull origin develop
```

2. 기능별 브랜치 생성

```bash
git switch -c feature/기능명-이름
```

예시

```bash
git switch -c feature/login-jinyong
git switch -c feature/qr-jinyong
```

3. 기능 개발 후 커밋 및 푸시

```bash
git add .
git commit -m "기능 설명"
git push origin feature/기능명-이름
```

예시

```bash
git commit -m "로그인 기능 구현"
git commit -m "QR 생성 기능 구현"
```

4. GitHub에서 Pull Request 생성

```text
feature/기능명-이름 → develop
```

5. develop 브랜치에서 기능 통합 및 테스트

6. 모든 기능 개발 및 테스트 완료 후

```text
develop → main
```

Pull Request를 통해 병합

### 주의사항

* main 브랜치에 직접 작업하지 않는다.
* develop 브랜치에 직접 작업하지 않는다.
* 모든 작업은 feature 브랜치에서 진행한다.
* 기능 개발 완료 후 Pull Request를 통해 develop에 병합한다.
* Pull Request 병합 후 사용한 feature 브랜치는 삭제한다.
* 새로운 기능 개발 시 develop 최신 내용을 반영한 후 새로운 feature 브랜치를 생성한다.
