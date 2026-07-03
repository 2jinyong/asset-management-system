package egovframework.asset.equipment;

import java.util.HashMap;
import egovframework.asset.cmmn.EquipmentPaging;
import egovframework.asset.cmmn.PageMaker;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/*
 * ============================================================
 * [로그인/관리자 권한 체크는 인터셉터가 담당합니다]
 * ============================================================
 * 이 컨트롤러의 모든 요청은 dispatcher-servlet.xml 에 등록된
 * LoginCheckInterceptor 를 거쳐야 도달합니다 (로그인 안 됐으면 로그인 화면으로 리다이렉트).
 * approveList.do 는 추가로 AdminCheckInterceptor 를 거쳐 ADMIN 권한까지 검사됩니다.
 * → 컨트롤러 메서드 안에서 session.getAttribute("loginUser") 를 직접 확인할 필요가 없습니다.
 * ============================================================
 */
@Controller
public class EquipmentController {

	private final EquipmentService equipmentService;

	public EquipmentController(EquipmentService equipmentService) {
		this.equipmentService = equipmentService;
	}

	@RequestMapping("/main.do")
	public String mainPage(ModelMap model) {
		List<Map<String, Object>> categorySummary = equipmentService.getCategorySummary();
		model.addAttribute("categorySummary", categorySummary);
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

	@RequestMapping("/rentalRequest.do")
	public String rentalRequest() {
		return "/board/RentalRequest";
	}

	@RequestMapping("/returnQr.do")
	public String returnQr() {
		return "/board/ReturnQr";
	}

	@RequestMapping("/extendRequest.do")
	public String extendRequest() {
		return "/board/ExtendRequest";
	}

	@RequestMapping("/reportIssue.do")
	public String reportIssue() {
		return "/board/ReportIssue";
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
