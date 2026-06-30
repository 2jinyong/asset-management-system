package egovframework.asset.user.web;

/*
 * ============================================================
 * [UserController - 로그인/회원가입/메인/로그아웃 처리]
 * ============================================================
 * [유효성 검사 전략]
 *
 *   프론트엔드(JS) 검사  +  백엔드(Spring Validation) 검사  이중 구조
 *
 *   프론트엔드: register.jsp 의 jQuery 코드
 *     → 네트워크 요청 없이 즉시 피드백 (UX 향상)
 *     → 하지만 JS를 끄거나 직접 HTTP 요청을 보내면 우회 가능 → 신뢰 불가
 *
 *   백엔드(@Valid): UserVO 어노테이션 기반 서버측 검증
 *     → JS 우회 불가 → 실제 보안/데이터 무결성 담당
 *     → @Valid 어노테이션 + BindingResult 파라미터로 동작
 *
 *   [중요] 백엔드 검증은 회원가입(register)에만 @Valid 적용
 *          로그인(login)은 서비스에서 null 반환으로 실패 처리 → 별도 @Valid 불필요
 * ============================================================
 */
import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.asset.user.service.UserService;
import egovframework.asset.user.service.UserVO;

@Controller
@RequestMapping("/user")
public class UserController {

    @Resource(name = "userService")
    private UserService userService;

    /* ===========================================================
       로그인
       =========================================================== */

    /**
     * [로그인 화면]
     * GET /user/loginView.do → user/login.jsp
     */
    @GetMapping("/loginView.do")
    public String loginView(Model model) {
        model.addAttribute("userVO", new UserVO());
        return "user/login";
    }

    /**
     * [로그인 처리]
     * POST /user/login.do
     *
     * 로그인은 @Valid 를 사용하지 않습니다.
     * 이유: UserVO의 @NotBlank 어노테이션이 모든 필드에 붙어있는데,
     *       로그인은 email + password 만 전송하므로 userName, employeeNumber 등이
     *       항상 빈값으로 들어와 검증에 실패합니다.
     *       대신 수동으로 빈값 체크 후 서비스에서 인증 처리합니다.
     */
    @PostMapping("/login.do")
    public String login(@ModelAttribute("userVO") UserVO userVO,
                        HttpSession session,
                        Model model) {

        // 빈값 수동 체크 (서비스 호출 전 단순 차단)
        String email    = userVO.getEmail();
        String password = userVO.getPassword();
        if (email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            model.addAttribute("errorMsg", "이메일과 비밀번호를 모두 입력해주세요.");
            return "user/login";
        }

        // 서비스에서 이메일+비밀번호 일치 확인
        UserVO loginUser = userService.login(userVO);

        if (loginUser != null) {
            session.setAttribute("loginUser", loginUser);  // 세션에 로그인 정보 저장
            return "redirect:/user/main.do";                // PRG 패턴
        } else {
            model.addAttribute("errorMsg", "이메일 또는 비밀번호가 올바르지 않습니다.");
            return "user/login";
        }
    }

    /* ===========================================================
       회원가입
       =========================================================== */

    /**
     * [회원가입 화면]
     * GET /user/registerView.do → user/register.jsp
     *
     * @ModelAttribute("userVO"): 빈 UserVO 를 "userVO" 이름으로 model 에 자동 추가
     * → <form:form modelAttribute="userVO"> 와 연결됨
     */
    @GetMapping("/registerView.do")
    public String registerView(@ModelAttribute("userVO") UserVO userVO) {
        return "user/register";
    }

    /**
     * [회원가입 처리]
     * POST /user/register.do
     *
     * [@Valid UserVO userVO]
     *   - UserVO 의 @NotBlank, @Email, @Size 어노테이션을 검사합니다.
     *   - 검사 결과(성공/실패)가 바로 뒤에 오는 BindingResult 에 저장됩니다.
     *
     * [BindingResult bindingResult]
     *   - 반드시 @Valid 파라미터 바로 다음에 선언해야 합니다.
     *   - bindingResult.hasErrors(): 검증 실패가 하나라도 있으면 true
     *   - JSP의 <form:errors path="필드명"> 이 bindingResult 의 오류를 자동으로 출력
     *
     *   [주의] BindingResult 를 선언하지 않으면 검증 실패 시 Spring이 직접
     *          400 Bad Request 예외를 던져서 에러 페이지가 뜹니다.
     *          BindingResult 를 선언해야 직접 처리할 수 있습니다.
     */
    @PostMapping("/register.do")
    public String register(@Valid @ModelAttribute("userVO") UserVO userVO,
                           BindingResult bindingResult,
                           Model model) {

        // 백엔드 유효성 검증 실패 → 회원가입 폼으로 되돌아감
        // Spring form 태그가 이전 입력값을 자동으로 다시 채워줌
        if (bindingResult.hasErrors()) {
            return "user/register";
        }

        // 서비스 호출 (중복 이메일 체크 + DB 저장)
        int result = userService.insertUser(userVO);

        if (result == 1) {
            model.addAttribute("userName", userVO.getUserName());
            return "user/joinResult";
        } else {
            model.addAttribute("errorMsg", "이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.");
            return "user/register";
        }
    }

    /* ===========================================================
       메인 / 로그아웃
       =========================================================== */

    /**
     * [메인 화면]
     * GET /user/main.do
     * 세션에 로그인 정보 없으면 로그인 페이지로 강제 이동
     */
    @GetMapping("/main.do")
    public String main(HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/user/loginView.do";
        }
        model.addAttribute("loginUser", loginUser);
        return "user/main";
    }

    /**
     * [로그아웃]
     * GET /user/logout.do → 세션 삭제 후 로그인 페이지로 이동
     */
    @GetMapping("/logout.do")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/user/loginView.do";
    }
}
