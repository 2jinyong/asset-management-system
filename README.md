## Git 브랜치 운영 규칙

### 브랜치 구조

* main : 최종 제출 및 배포용 브랜치
* develop : 개발 통합 브랜치
* feature/* : 개인 작업 브랜치

### 작업 순서

1. develop 최신 내용 받기

```bash
git switch develop
git pull origin develop
```

2. 개인 작업 브랜치 생성

```bash
git switch -c feature/본인이름
```

예시

```bash
git switch -c feature/jinyong
git switch -c feature/teammate
```

3. 기능 개발 후 커밋 및 푸시

```bash
git add .
git commit -m "기능 설명"
git push origin feature/본인이름
```

4. GitHub에서 Pull Request 생성

```text
feature/본인이름 → develop
```

5. develop 브랜치에서 기능 통합 및 테스트

6. 최종 테스트 완료 후

```text
develop → main
```

Pull Request를 통해 병합

### 주의사항

* main 브랜치에 직접 작업하지 않는다.
* develop 브랜치에 직접 작업하지 않는다.
* 모든 작업은 feature 브랜치에서 진행한다.
* 기능 완료 후 Pull Request를 통해 develop에 병합한다.
