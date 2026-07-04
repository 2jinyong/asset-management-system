package egovframework.asset.equipment;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper ("equipmentMapper")
public interface EquipmentMapper {
    List<EquipmentVO> selectEquipmentList(Map<String, Object> params);
    int selectEquipmentCount(Map<String, Object> params);
    List<Map<String, Object>> selectCategorySummary();
    List<Map<String, Object>> selectMyRentalList(Long userId);

    // 반환 타입 변경: EquipmentVO -> Map (모델별 그룹핑 + available_count 포함)
    List<Map<String, Object>> selectEquipmentByCategory(String category);

    // 추가: 특정 모델명의 AVAILABLE 비품 중 quantity개 equipment_id 조회
    List<Long> selectAvailableEquipmentIdsByName(Map<String, Object> params);
}