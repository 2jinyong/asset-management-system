package egovframework.asset.equipment.web;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import egovframework.asset.cmmn.EquipmentPaging;
import egovframework.asset.cmmn.PageMaker;
import egovframework.asset.cmmn.QrCodeUtil;
import egovframework.asset.equipment.service.EquipmentService;
import egovframework.asset.equipment.service.EquipmentVO;
import egovframework.asset.rental.service.RentalService;
import egovframework.asset.rental.service.RentalVO;
import egovframework.asset.report.service.ReportService;
import egovframework.asset.report.service.ReportVO;
import egovframework.asset.user.service.UserVO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

@Controller
public class EquipmentController {

	@Value("${upload.report.dir}")
	private String reportUploadDir;

	@Value("${upload.qr.dir}")
	private String qrUploadDir;

	private final EquipmentService equipmentService;
	private final RentalService rentalService;
	private final ReportService reportService;

	public EquipmentController(EquipmentService equipmentService, RentalService rentalService,
			ReportService reportService) {
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
		return "/equipment/TestUI";
	}

	@RequestMapping("/equipmentList.do")
	public String equipmentList(@RequestParam(value = "category", defaultValue = "") String category,
			@RequestParam(value = "page", defaultValue = "1") int page, ModelMap model) {

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

		return "/equipment/EquipmentList";
	}

	@RequestMapping(value = "/equipmentForm.do", method = RequestMethod.GET)
	public String equipmentForm(@RequestParam(value = "equipmentId", required = false) Long equipmentId,
			ModelMap model) {
		if (equipmentId != null) {
			model.addAttribute("equipmentVO", equipmentService.getEquipmentById(equipmentId));
		} else {
			model.addAttribute("equipmentVO", new EquipmentVO());
		}
		model.addAttribute("categoryList", equipmentService.getAllCategoryNames());
		return "/admin/EquipmentForm";
	}

	@RequestMapping(value = "/categoryList.do", method = RequestMethod.GET)
	public String categoryList(@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "error", required = false) String error, ModelMap model) {

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
		return "/admin/CategoryList";
	}

	@PostMapping("/categoryRegister.do")
	public String categoryRegister(@RequestParam("categoryName") String categoryName) {
		equipmentService.registerCategory(categoryName);
		return "redirect:/categoryList.do";
	}

	@PostMapping("/categoryUpdate.do")
	public String categoryUpdate(@RequestParam("categoryId") Long categoryId,
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
	public String equipmentDelete(@RequestParam("equipmentId") Long equipmentId,
			@RequestParam(value = "category", defaultValue = "") String category) {
		try {
			equipmentService.deleteEquipment(equipmentId);
		} catch (org.springframework.dao.DataIntegrityViolationException e) {
			return "redirect:/equipmentList.do?category=" + encode(category) + "&error=hasHistory";
		}
		return "redirect:/equipmentList.do?category=" + encode(category);
	}

	@PostMapping("/qrGenerate.do")
	public String qrGenerate(@RequestParam("equipmentIds") List<Long> equipmentIds, HttpServletRequest request) {
		String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
				+ request.getContextPath();

		File dir = new File(qrUploadDir);
		if (!dir.exists()) {
			dir.mkdirs();
		}

		for (Long equipmentId : equipmentIds) {
			String content = baseUrl + "/returnQr.do?equipmentId=" + equipmentId;
			String fileName = "EQ_" + equipmentId + ".png";
			try {
				byte[] png = QrCodeUtil.generatePng(content);
				FileCopyUtils.copy(png, new File(dir, fileName));
			} catch (Exception e) {
				throw new RuntimeException("QR 코드 생성 실패: equipmentId=" + equipmentId, e);
			}
			equipmentService.updateQrImagePath(equipmentId, fileName);
		}

		String ids = equipmentIds.stream().map(String::valueOf).collect(Collectors.joining(","));
		return "redirect:/qrPrint.do?equipmentIds=" + ids;
	}

	@RequestMapping(value = "/qrPrint.do", method = RequestMethod.GET)
	public String qrPrint(@RequestParam("equipmentIds") String equipmentIds, ModelMap model) {
		List<EquipmentVO> list = new ArrayList<>();
		for (String idStr : equipmentIds.split(",")) {
			if (idStr.trim().isEmpty()) {
				continue;
			}
			list.add(equipmentService.getEquipmentById(Long.parseLong(idStr.trim())));
		}
		model.addAttribute("equipmentList", list);
		return "/admin/QrPrint";
	}

	@RequestMapping(value = "/qrImage.do", method = RequestMethod.GET)
	public void qrImage(@RequestParam("equipmentId") Long equipmentId, HttpServletResponse response) throws IOException {
		EquipmentVO equipmentVO = equipmentService.getEquipmentById(equipmentId);
		String qrImagePath = equipmentVO != null ? equipmentVO.getQrImagePath() : null;
		if (qrImagePath == null) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		File uploadDir = new File(qrUploadDir).getCanonicalFile();
		File file = new File(uploadDir, new File(qrImagePath).getName()).getCanonicalFile();
		if (!file.getPath().startsWith(uploadDir.getPath() + File.separator) || !file.isFile()) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		response.setContentType("image/png");
		try (InputStream in = new FileInputStream(file)) {
			FileCopyUtils.copy(in, response.getOutputStream());
		}
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
	public List<Map<String, Object>> getEquipmentByCategory(@RequestParam(value = "category") String category) {
		return equipmentService.getEquipmentByCategory(category);
	}

	@RequestMapping(value = "/myRentalList.do", method = RequestMethod.GET)
	@ResponseBody
	public List<Map<String, Object>> getMyRentalList(HttpSession session) {
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		if (loginUser == null)
			return new java.util.ArrayList<>();

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
		return "/equipment/RentalRequest";
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
		return "/equipment/ReturnQr";
	}

	@RequestMapping(value = "/returnSearch.do", method = RequestMethod.GET)
	@ResponseBody
	public Map<String, Object> returnSearch(@RequestParam("equipmentId") Long equipmentId) {
		Map<String, Object> result = rentalService.findRentalByEquipmentId(equipmentId);
		if (result == null) {
			result = new HashMap<>();
		}
		return result;
	}

	@RequestMapping(value = "/returnProcess.do", method = RequestMethod.POST)
	@ResponseBody
	public String returnProcess(@RequestParam("rentalId") Long rentalId,
			@RequestParam("equipmentId") Long equipmentId) {
		rentalService.processReturn(rentalId, equipmentId);
		return "ok";
	}

	@RequestMapping(value = "/extendRequest.do", method = RequestMethod.GET)
	public String extendRequestView() {
		return "/equipment/ExtendRequest";
	}

	@RequestMapping(value = "/extendRequest.do", method = RequestMethod.POST)
	@ResponseBody
	public String extendRequestSubmit(@RequestParam("rentalId") Long rentalId,
			@RequestParam("newReturnDate") String newReturnDate,
			@RequestParam(value = "reason", required = false) String reason, HttpSession session) {
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		rentalService.requestExtend(rentalId, loginUser.getUserId(), newReturnDate, reason);
		return "ok";
	}

	@RequestMapping(value = "/reportIssue.do", method = RequestMethod.GET)
	public String reportIssue() {
		return "/equipment/ReportIssue";
	}

	@RequestMapping(value = "/reportIssue.do", method = RequestMethod.POST)
	@ResponseBody
	public String reportIssueSubmit(@RequestParam("rentalId") Long rentalId,
			@RequestParam("equipmentId") Long equipmentId, @RequestParam("issueType") String issueType,
			@RequestParam("content") String content, @RequestParam("image") MultipartFile image, HttpSession session) {

		UserVO loginUser = (UserVO) session.getAttribute("loginUser");

		String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
		String savePath = reportUploadDir + fileName;

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
	public String approveList(@RequestParam(value = "type", defaultValue = "rental") String type,
			@RequestParam(value = "page", defaultValue = "1") int page, ModelMap model) {

		List<Map<String, Object>> fullList;
		if ("extend".equals(type)) {
			fullList = rentalService.getPendingExtends();
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
		return "/admin/ApproveList";
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

	@RequestMapping("/issueList.do")
	public String issueList(@RequestParam(value = "page", defaultValue = "1") int page, ModelMap model) {
		List<Map<String, Object>> fullList = reportService.getOpenReports();

		EquipmentPaging paging = new EquipmentPaging();
		paging.setPage(page);
		paging.setPerPageNum(10);

		PageMaker pageMaker = new PageMaker();
		pageMaker.setPaging(paging);
		pageMaker.setTotalCount(fullList.size());

		int from = Math.min(paging.getPageStart(), fullList.size());
		int to = Math.min(from + paging.getPerPageNum(), fullList.size());

		model.addAttribute("list", fullList.subList(from, to));
		model.addAttribute("pageMaker", pageMaker);
		return "/admin/IssueList";
	}

	@PostMapping("/reportConfirm.do")
	public String reportConfirm(@RequestParam("reportId") Long reportId) {
		reportService.confirmReport(reportId);
		return "redirect:/issueList.do";
	}

	@PostMapping("/reportStartRepair.do")
	public String reportStartRepair(@RequestParam("reportId") Long reportId) {
		reportService.startRepair(reportId);
		return "redirect:/issueList.do";
	}

	@PostMapping("/reportResolve.do")
	public String reportResolve(@RequestParam("reportId") Long reportId) {
		reportService.resolveReport(reportId);
		return "redirect:/issueList.do";
	}

	@PostMapping("/reportReject.do")
	public String reportReject(@RequestParam("reportId") Long reportId) {
		reportService.rejectReport(reportId);
		return "redirect:/issueList.do";
	}

	@RequestMapping(value = "/reportImage.do", method = RequestMethod.GET)
	public void reportImage(@RequestParam("reportId") Long reportId, HttpServletResponse response) throws IOException {
		Map<String, Object> report = reportService.getReport(reportId);
		String imagePath = report != null ? (String) report.get("imagePath") : null;
		if (imagePath == null) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		// 저장된 값이 절대경로/파일명 중 무엇이든 파일명만 취해서 업로드 폴더 기준으로 다시 조합한다
		// (경로 조작으로 업로드 폴더 밖의 파일을 읽지 못하도록 막기 위함).
		File uploadDir = new File(reportUploadDir).getCanonicalFile();
		File file = new File(uploadDir, new File(imagePath).getName()).getCanonicalFile();
		if (!file.getPath().startsWith(uploadDir.getPath() + File.separator) || !file.isFile()) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		String contentType = URLConnection.guessContentTypeFromName(file.getName());
		response.setContentType(contentType != null ? contentType : "application/octet-stream");
		try (InputStream in = new FileInputStream(file)) {
			FileCopyUtils.copy(in, response.getOutputStream());
		}
	}
}
