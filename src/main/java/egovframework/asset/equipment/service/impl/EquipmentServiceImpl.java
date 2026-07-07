package egovframework.asset.equipment.service.impl;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

import egovframework.asset.equipment.service.EquipmentMapper;
import egovframework.asset.equipment.service.EquipmentService;
import egovframework.asset.equipment.service.EquipmentVO;

@Service
public class EquipmentServiceImpl implements EquipmentService {
    private final EquipmentMapper equipmentMapper;
    public EquipmentServiceImpl(EquipmentMapper equipmentMapper) {
        this.equipmentMapper = equipmentMapper;
    }
    @Override
    public List<EquipmentVO> getEquipmentList(Map<String, Object> params) {
        return equipmentMapper.selectEquipmentList(params);
    }
    @Override
    public int getEquipmentCount(Map<String, Object> params) {
        return equipmentMapper.selectEquipmentCount(params);
    }
    @Override
    public List<Map<String, Object>> getCategorySummary() {
        return equipmentMapper.selectCategorySummary();
    }

    @Override
    public List<Map<String, Object>> getMyRentalList(Long userId) {
        return equipmentMapper.selectMyRentalList(userId);
    }

    @Override
    public List<Map<String, Object>> getEquipmentByCategory(String category) {
        return equipmentMapper.selectEquipmentByCategory(category);
    }

    @Override
    public EquipmentVO getEquipmentById(Long equipmentId) {
        return equipmentMapper.selectEquipmentById(equipmentId);
    }

    @Override
    public void registerEquipment(EquipmentVO equipmentVO) {
        equipmentMapper.insertEquipment(equipmentVO);
    }

    @Override
    public void updateEquipment(EquipmentVO equipmentVO) {
        int updated = equipmentMapper.updateEquipment(equipmentVO);
        if (updated == 0) {
            throw new IllegalStateException("수정할 비품을 찾을 수 없습니다.");
        }
    }

    @Override
    public void deleteEquipment(Long equipmentId) {
        int deleted = equipmentMapper.deleteEquipment(equipmentId);
        if (deleted == 0) {
            throw new IllegalStateException("삭제할 비품을 찾을 수 없습니다.");
        }
    }

    @Override
    public List<String> getAllCategoryNames() {
        return equipmentMapper.selectAllCategoryNames();
    }

    @Override
    public void registerCategory(String categoryName) {
        equipmentMapper.insertCategory(categoryName);
    }

    @Override
    public List<Map<String, Object>> getAllCategories(Map<String, Object> params) {
        return equipmentMapper.selectAllCategories(params);
    }

    @Override
    public int getCategoryCount() {
        return equipmentMapper.selectCategoryCount();
    }

    @Override
    public void updateCategory(Long categoryId, String categoryName) {
        Map<String, Object> params = new HashMap<>();
        params.put("categoryId", categoryId);
        params.put("categoryName", categoryName);
        int updated = equipmentMapper.updateCategory(params);
        if (updated == 0) {
            throw new IllegalStateException("수정할 카테고리를 찾을 수 없습니다.");
        }
    }

    @Override
    public void deleteCategory(Long categoryId) {
        int deleted = equipmentMapper.deleteCategory(categoryId);
        if (deleted == 0) {
            throw new IllegalStateException("삭제할 카테고리를 찾을 수 없습니다.");
        }
    }
}
