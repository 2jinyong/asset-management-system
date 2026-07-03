package egovframework.asset.equipment;
import java.util.List;
import java.util.Map;
public interface EquipmentService {
    List<EquipmentVO> getEquipmentList(Map<String, Object> params);
    int getEquipmentCount(Map<String, Object> params);
    List<Map<String, Object>> getCategorySummary();
    List<Map<String, Object>> getMyRentalList(Long userId);

    // 반환 타입 변경: EquipmentVO -> Map (모델별 그룹핑 + available_count)
    List<Map<String, Object>> getEquipmentByCategory(String category);
}