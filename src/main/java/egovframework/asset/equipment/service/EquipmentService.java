package egovframework.asset.equipment.service;
import java.util.List;
import java.util.Map;
public interface EquipmentService {
    List<EquipmentVO> getEquipmentList(Map<String, Object> params);
    int getEquipmentCount(Map<String, Object> params);
    List<Map<String, Object>> getCategorySummary();
    List<Map<String, Object>> getMyRentalList(Long userId);

    // 반환 타입 변경: EquipmentVO -> Map (모델별 그룹핑 + available_count)
    List<Map<String, Object>> getEquipmentByCategory(String category);

    // 비품 등록/수정/삭제 (관리자 전용)
    EquipmentVO getEquipmentById(Long equipmentId);
    void registerEquipment(EquipmentVO equipmentVO);
    void updateEquipment(EquipmentVO equipmentVO);
    void deleteEquipment(Long equipmentId);

    // 카테고리 마스터 (관리자 전용)
    List<String> getAllCategoryNames();
    List<Map<String, Object>> getAllCategories(Map<String, Object> params);
    int getCategoryCount();
    void registerCategory(String categoryName);
    void updateCategory(Long categoryId, String categoryName);
    void deleteCategory(Long categoryId);
}
