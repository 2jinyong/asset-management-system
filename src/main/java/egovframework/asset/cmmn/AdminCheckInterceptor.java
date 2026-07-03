package egovframework.asset.cmmn;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;

import egovframework.asset.user.service.UserVO;

/**
 * [관리자 권한 체크 인터셉터]
 * 가입승인/반려, 대여·연장·신고 승인 목록 등 ADMIN 전용 화면에만 적용된다.
 * dispatcher-servlet.xml 에서 LoginCheckInterceptor 뒤에 등록되므로,
 * 이 시점에는 로그인 여부는 이미 보장된 상태이고 role만 확인하면 된다.
 */
public class AdminCheckInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        HttpSession session = request.getSession();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");

        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/main.do");
            return false;
        }
        return true;
    }
}
