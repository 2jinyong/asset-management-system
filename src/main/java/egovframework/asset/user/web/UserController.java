package egovframework.asset.user.web;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import egovframework.asset.user.service.UserService;
import egovframework.asset.user.service.UserVO;

@Controller
@RequestMapping("/user") // 공통 경로
public class UserController {

    // 1. 서비스 인터페이스를 선언 (Impl을 직접 호출하지 마세요!)
    @Resource(name = "userService")
    private UserService userService;

    @RequestMapping(value = "/register.do")
    public String register(@ModelAttribute("userVO") UserVO userVO) throws Exception {
        
        // 2. 서비스 호출
        userService.insertUser(userVO);
        
        return "user/joinResult"; // 이동할 화면 경로
    }
}