package egovframework.asset.equipment;

import java.util.Map;

public interface RentalService {
    void insertRentalRequest(RentalVO rentalVO);
    void extendRental(Long rentalId, Long userId, String newReturnDate);
    Map<String, Object> findRentalByEquipmentId(Long equipmentId);
    void processReturn(Long rentalId, Long equipmentId);
}