package egovframework.asset.equipment;

import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

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
}