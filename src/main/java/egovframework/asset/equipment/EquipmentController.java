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
}