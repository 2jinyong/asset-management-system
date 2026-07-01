package egovframework.asset.equipment;

import java.util.List;
import java.util.Map;

public interface EquipmentService {
    List<EquipmentVO> getEquipmentList(Map<String, Object> params);
    int getEquipmentCount(Map<String, Object> params);
    List<Map<String, Object>> getCategorySummary();
}