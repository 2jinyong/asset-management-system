package egovframework.asset.equipment;
import java.util.Map;
import org.egovframe.rte.psl.dataaccess.mapper.Mapper;
@Mapper
public interface RentalMapper {
    int insertRental(RentalVO rentalVO);
    int updateEquipmentStatus(Map<String, Object> params);
    int updateReturnDate(Map<String, Object> params);
    Map<String, Object> selectRentalByEquipmentId(Long equipmentId);
    int deleteRental(Long rentalId);
}