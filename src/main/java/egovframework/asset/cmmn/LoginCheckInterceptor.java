package egovframework.asset.cmmn;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;

import egovframework.asset.user.service.UserVO;

/**
 * [로그인 체크 인터셉터]
 * 컨트롤러가 호출되기 전에 세션의 loginUser 유무를 검사한다.
 * 예전에는 이 체크를 컨트롤러 메서드마다 직접 넣었지만(중복 코드),
 * 이 인터셉터로 옮기면 dispatcher-servlet.xml 에 등록하는 것만으로
 * 적용 대상 경로 전체에 자동으로 적용된다.
 *
 * preHandle()이 false를 반환하면 컨트롤러 메서드는 아예 호출되지 않는다.
 */
public class LoginCheckInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        HttpSession session = request.getSession();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/loginView.do");
            return false;
        }
        return true;
    }
}
