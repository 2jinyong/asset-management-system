package egovframework.asset.equipment;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import egovframework.asset.cmmn.EquipmentPaging;
import egovframework.asset.cmmn.PageMaker;
import egovframework.asset.user.service.UserVO;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PostMapping;
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
        if (loginUser != null && "USER".equals(loginUser.getRole())) {
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

    @RequestMapping(value = "/equipmentForm.do", method = RequestMethod.GET)
    public String equipmentForm(
            @RequestParam(value = "equipmentId", required = false) Long equipmentId,
            ModelMap model) {
        if (equipmentId != null) {
            model.addAttribute("equipmentVO", equipmentService.getEquipmentById(equipmentId));
        } else {
            model.addAttribute("equipmentVO", new EquipmentVO());
        }
        model.addAttribute("categoryList", equipmentService.getAllCategoryNames());
        return "/board/EquipmentForm";
    }

    @RequestMapping(value = "/categoryList.do", method = RequestMethod.GET)
    public String categoryList(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "error", required = false) String error,
            ModelMap model) {

        EquipmentPaging paging = new EquipmentPaging();
        paging.setPage(page);
        paging.setPerPageNum(15);

        Map<String, Object> params = new HashMap<>();
        params.put("pageSize", paging.getPerPageNum());
        params.put("offset", paging.getPageStart());

        List<Map<String, Object>> categories = equipmentService.getAllCategories(params);
        int totalCount = equipmentService.getCategoryCount();

        PageMaker pageMaker = new PageMaker();
        pageMaker.setPaging(paging);
        pageMaker.setTotalCount(totalCount);

        model.addAttribute("categories", categories);
        model.addAttribute("pageMaker", pageMaker);
        model.addAttribute("error", error);
        return "/board/CategoryList";
    }

    @PostMapping("/categoryRegister.do")
    public String categoryRegister(@RequestParam("categoryName") String categoryName) {
        equipmentService.registerCategory(categoryName);
        return "redirect:/categoryList.do";
    }

    @PostMapping("/categoryUpdate.do")
    public String categoryUpdate(
            @RequestParam("categoryId") Long categoryId,
            @RequestParam("categoryName") String categoryName) {
        equipmentService.updateCategory(categoryId, categoryName);
        return "redirect:/categoryList.do";
    }

    @PostMapping("/categoryDelete.do")
    public String categoryDelete(@RequestParam("categoryId") Long categoryId) {
        try {
            equipmentService.deleteCategory(categoryId);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            return "redirect:/categoryList.do?error=categoryInUse";
        }
        return "redirect:/categoryList.do";
    }

    @RequestMapping(value = "/equipmentRegister.do", method = RequestMethod.POST)
    public String equipmentRegister(EquipmentVO equipmentVO) {
        equipmentService.registerEquipment(equipmentVO);
        return "redirect:/equipmentList.do?category=" + encode(equipmentVO.getCategory());
    }

    @RequestMapping(value = "/equipmentUpdate.do", method = RequestMethod.POST)
    public String equipmentUpdate(EquipmentVO equipmentVO) {
        equipmentService.updateEquipment(equipmentVO);
        return "redirect:/equipmentList.do?category=" + encode(equipmentVO.getCategory());
    }

    @PostMapping("/equipmentDelete.do")
    public String equipmentDelete(
            @RequestParam("equipmentId") Long equipmentId,
            @RequestParam(value = "category", defaultValue = "") String category) {
        try {
            equipmentService.deleteEquipment(equipmentId);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            return "redirect:/equipmentList.do?category=" + encode(category) + "&error=hasHistory";
        }
        return "redirect:/equipmentList.do?category=" + encode(category);
    }

    private String encode(String value) {
        if (value == null) {
            return "";
        }
        try {
            return URLEncoder.encode(value, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
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

        // 연장/신고 대상 선택용 목록이므로, 승인되어 실제로 대여 중인 건만 내려준다.
        List<Map<String, Object>> approved = new java.util.ArrayList<>();
        for (Map<String, Object> rental : equipmentService.getMyRentalList(loginUser.getUserId())) {
            if ("APPROVED".equals(rental.get("requestStatus"))) {
                approved.add(rental);
            }
        }
        return approved;
    }

    @RequestMapping(value = "/rentalRequest.do", method = RequestMethod.GET)
    public String rentalRequestView(ModelMap model) {
        model.addAttribute("categoryList", equipmentService.getAllCategoryNames());
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
            @RequestParam(value = "reason", required = false) String reason,
            HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        rentalService.requestExtend(rentalId, loginUser.getUserId(), newReturnDate, reason);
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

        List<Map<String, Object>> fullList;
        if ("extend".equals(type)) {
            fullList = rentalService.getPendingExtends();
        } else if ("report".equals(type)) {
            fullList = reportService.getPendingReports();
        } else {
            fullList = rentalService.getPendingRentals();
        }

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

    @PostMapping("/approveRental.do")
    public String approveRental(@RequestParam("rentalId") Long rentalId) {
        rentalService.approveRental(rentalId);
        return "redirect:/approveList.do?type=rental";
    }

    @PostMapping("/rejectRental.do")
    public String rejectRental(@RequestParam("rentalId") Long rentalId) {
        rentalService.rejectRental(rentalId);
        return "redirect:/approveList.do?type=rental";
    }

    @PostMapping("/approveExtend.do")
    public String approveExtend(@RequestParam("rentalId") Long rentalId) {
        rentalService.approveExtend(rentalId);
        return "redirect:/approveList.do?type=extend";
    }

    @PostMapping("/rejectExtend.do")
    public String rejectExtend(@RequestParam("rentalId") Long rentalId) {
        rentalService.rejectExtend(rentalId);
        return "redirect:/approveList.do?type=extend";
    }

    @PostMapping("/approveReport.do")
    public String approveReport(@RequestParam("reportId") Long reportId) {
        reportService.approveReport(reportId);
        return "redirect:/approveList.do?type=report";
    }

    @PostMapping("/rejectReport.do")
    public String rejectReport(@RequestParam("reportId") Long reportId) {
        reportService.rejectReport(reportId);
        return "redirect:/approveList.do?type=report";
    }
}