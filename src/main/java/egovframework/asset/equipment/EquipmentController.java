package egovframework.asset.equipment;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import egovframework.asset.cmmn.EquipmentPaging;
import egovframework.asset.cmmn.PageMaker;
import egovframework.asset.user.service.UserVO;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class EquipmentController {

    private final EquipmentService equipmentService;
    private final RentalService rentalService;

    public EquipmentController(EquipmentService equipmentService, RentalService rentalService) {
        this.equipmentService = equipmentService;
        this.rentalService = rentalService;
    }

    @RequestMapping("/main.do")
    public String mainPage(ModelMap model, HttpSession session) {
        List<Map<String, Object>> categorySummary = equipmentService.getCategorySummary();
        model.addAttribute("categorySummary", categorySummary);
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            List<Map<String, Object>> myRentalList = equipmentService.getMyRentalList(loginUser.getUserId());
            model.addAttribute("myRentalList", myRentalList);
        }
        return "/board/TestUI";
    }

    @RequestMapping("/equipmentList.do")
    public String equipmentList(
            @RequestParam(value = "category", defaultValue = "") String category,
            @RequestParam(value = "page", defaultValue = "1") int page,
            ModelMap model) {

        EquipmentPaging paging = new EquipmentPaging();
        paging.setPage(page);
        paging.setPerPageNum(15);

        Map<String, Object> params = new HashMap<>();
        params.put("category", category);
        params.put("pageSize", paging.getPerPageNum());
        params.put("offset", paging.getPageStart());

        List<EquipmentVO> list = equipmentService.getEquipmentList(params);
        int totalCount = equipmentService.getEquipmentCount(params);

        PageMaker pageMaker = new PageMaker();
        pageMaker.setPaging(paging);
        pageMaker.setTotalCount(totalCount);

        model.addAttribute("equipmentList", list);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("category", category);

        return "/board/EquipmentList";
    }

    @RequestMapping(value = "/equipmentByCategory.do", method = RequestMethod.GET)
    @ResponseBody
    public List<Map<String, Object>> getEquipmentByCategory(
            @RequestParam(value = "category") String category) {
        return equipmentService.getEquipmentByCategory(category);
    }

    @RequestMapping(value = "/myRentalList.do", method = RequestMethod.GET)
    @ResponseBody
    public List<Map<String, Object>> getMyRentalList(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return new java.util.ArrayList<>();
        return equipmentService.getMyRentalList(loginUser.getUserId());
    }

    @RequestMapping(value = "/rentalRequest.do", method = RequestMethod.GET)
    public String rentalRequestView() {
        return "/board/RentalRequest";
    }

    @RequestMapping(value = "/rentalRequest.do", method = RequestMethod.POST)
    public String rentalRequestSubmit(RentalVO rentalVO, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        rentalVO.setUserId(loginUser.getUserId());
        rentalService.insertRentalRequest(rentalVO);
        return "redirect:/main.do";
    }

    @RequestMapping(value = "/returnQr.do", method = RequestMethod.GET)
    public String returnQr() {
        return "/board/ReturnQr";
    }

    @RequestMapping(value = "/extendRequest.do", method = RequestMethod.GET)
    public String extendRequestView() {
        return "/board/ExtendRequest";
    }

    @RequestMapping(value = "/extendRequest.do", method = RequestMethod.POST)
    @ResponseBody
    public String extendRequestSubmit(
            @RequestParam("rentalId") Long rentalId,
            @RequestParam("newReturnDate") String newReturnDate,
            HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        rentalService.extendRental(rentalId, loginUser.getUserId(), newReturnDate);
        return "ok";
    }

    @RequestMapping(value = "/reportIssue.do", method = RequestMethod.GET)
    public String reportIssue() {
        return "/board/ReportIssue";
    }
}