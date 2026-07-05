package egovframework.asset.equipment;

import java.io.File;
import java.io.IOException;
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
import org.springframework.web.multipart.MultipartFile;

@Controller
public class EquipmentController {

    private final EquipmentService equipmentService;
    private final RentalService rentalService;
    private final ReportService reportService;

    public EquipmentController(EquipmentService equipmentService, RentalService rentalService, ReportService reportService) {
        this.equipmentService = equipmentService;
        this.rentalService = rentalService;
        this.reportService = reportService;
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

    @RequestMapping(value = "/returnSearch.do", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> returnSearch(
            @RequestParam("equipmentId") Long equipmentId) {
        Map<String, Object> result = rentalService.findRentalByEquipmentId(equipmentId);
        if (result == null) {
            result = new HashMap<>();
        }
        return result;
    }

    @RequestMapping(value = "/returnProcess.do", method = RequestMethod.POST)
    @ResponseBody
    public String returnProcess(
            @RequestParam("rentalId") Long rentalId,
            @RequestParam("equipmentId") Long equipmentId) {
        rentalService.processReturn(rentalId, equipmentId);
        return "ok";
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

    @RequestMapping(value = "/reportIssue.do", method = RequestMethod.POST)
    @ResponseBody
    public String reportIssueSubmit(
            @RequestParam("rentalId") Long rentalId,
            @RequestParam("equipmentId") Long equipmentId,
            @RequestParam("issueType") String issueType,
            @RequestParam("content") String content,
            @RequestParam("image") MultipartFile image,
            HttpSession session) {

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");

        String uploadDir = "C:/asset-uploads/report/";
        String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
        String savePath = uploadDir + fileName;

        try {
            image.transferTo(new File(savePath));
        } catch (IOException e) {
            throw new RuntimeException("이미지 저장 실패", e);
        }

        ReportVO reportVO = new ReportVO();
        reportVO.setRentalId(rentalId);
        reportVO.setEquipmentId(equipmentId);
        reportVO.setUserId(loginUser.getUserId());
        reportVO.setIssueType(issueType);
        reportVO.setContent(content);
        reportVO.setImagePath(savePath);

        reportService.insertReport(reportVO);

        return "ok";
    }

    @RequestMapping("/approveList.do")
    public String approveList(
            @RequestParam(value = "type", defaultValue = "rental") String type,
            @RequestParam(value = "page", defaultValue = "1") int page,
            ModelMap model) {

        // TODO: RENTAL/REPORT 테이블 연동 준비되면 더미 리스트를 실제 Service 조회로 교체
        List<Map<String, Object>> fullList = buildDummyApprovalList(type);

        EquipmentPaging paging = new EquipmentPaging();
        paging.setPage(page);
        paging.setPerPageNum(10);

        PageMaker pageMaker = new PageMaker();
        pageMaker.setPaging(paging);
        pageMaker.setTotalCount(fullList.size());

        int from = Math.min(paging.getPageStart(), fullList.size());
        int to = Math.min(from + paging.getPerPageNum(), fullList.size());

        model.addAttribute("type", type);
        model.addAttribute("list", fullList.subList(from, to));
        model.addAttribute("pageMaker", pageMaker);
        return "/board/ApproveList";
    }

    /**
     * 승인 관리 화면용 더미 데이터. type 별로 표시 항목이 달라 Map 으로 구성.
     * RENTAL/REPORT 실제 연동 전까지의 임시 데이터.
     */
    private List<Map<String, Object>> buildDummyApprovalList(String type) {
        List<Map<String, Object>> list = new java.util.ArrayList<>();

        if ("extend".equals(type)) {
            list.add(mapOf("applicant", "이도현", "itemName", "iPad Air 5세대 (TAB-001)",
                    "currentDue", "2026.07.01", "requestDue", "2026.07.08", "reason", "프로젝트 마감 연장으로 추가 사용 필요"));
        } else if ("report".equals(type)) {
            list.add(mapOf("applicant", "정하늘", "itemName", "빔프로젝터 Epson EB-X49 (PRJ-001)",
                    "issueType", "작동 불량", "content", "전원은 켜지는데 화면 출력이 안 됩니다."));
        } else {
            list.add(mapOf("applicant", "김재민", "itemName", "노트북 LG그램 15 (NTB-003)",
                    "startDate", "2026.07.03", "dueDate", "2026.07.10"));
            list.add(mapOf("applicant", "박소연", "itemName", "캐논 EOS R50 (CAM-002)",
                    "startDate", "2026.07.04", "dueDate", "2026.07.08"));
        }
        return list;
    }

    private Map<String, Object> mapOf(Object... kv) {
        Map<String, Object> map = new HashMap<>();
        for (int i = 0; i < kv.length; i += 2) {
            map.put((String) kv[i], kv[i + 1]);
        }
        return map;
    }
}