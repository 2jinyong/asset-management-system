package egovframework.asset.equipment;

import java.util.HashMap;
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
	public String equipmentList(@RequestParam(value = "category", defaultValue = "") String category,
			@RequestParam(value = "pageIndex", defaultValue = "1") int pageIndex, ModelMap model) {

		Map<String, Object> params = new HashMap<>();
		params.put("category", category);
		params.put("pageIndex", pageIndex);
		params.put("pageSize", 10);
		params.put("offset", (pageIndex - 1) * 10);

		List<EquipmentVO> list = equipmentService.getEquipmentList(params);
		int totalCount = equipmentService.getEquipmentCount(params);
		int totalPages = (int) Math.ceil((double) totalCount / 10);

		model.addAttribute("equipmentList", list);
		model.addAttribute("totalCount", totalCount);
		model.addAttribute("totalPages", totalPages);
		model.addAttribute("pageIndex", pageIndex);
		model.addAttribute("category", category);

		return "/board/EquipmentList";
	}
}