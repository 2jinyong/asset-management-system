package egovframework.asset.equipment;
import java.util.List;
import java.util.Map;
import org.egovframe.rte.psl.dataaccess.mapper.Mapper;
@Mapper
public interface RentalMapper {
    int insertRental(RentalVO rentalVO);
    int updateEquipmentStatus(Map<String, Object> params);
    Map<String, Object> selectRentalByEquipmentId(Long equipmentId);
    int deleteRental(Long rentalId);

    List<Map<String, Object>> selectPendingRentals();
    int approveRental(Long rentalId);
    int rejectRental(Long rentalId);

    int requestExtend(Map<String, Object> params);
    List<Map<String, Object>> selectPendingExtends();
    int approveExtend(Long rentalId);
    int rejectExtend(Long rentalId);
}