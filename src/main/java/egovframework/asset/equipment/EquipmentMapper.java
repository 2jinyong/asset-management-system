package egovframework.asset.equipment;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper ("equipmentMapper")
public interface EquipmentMapper {
    List<EquipmentVO> selectEquipmentList(Map<String, Object> params);
    int selectEquipmentCount(Map<String, Object> params);
    List<Map<String, Object>> selectCategorySummary();
}