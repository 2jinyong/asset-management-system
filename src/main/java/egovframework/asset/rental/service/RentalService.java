package egovframework.asset.rental.service;

import java.util.List;
import java.util.Map;

public interface RentalService {
    void insertRentalRequest(RentalVO rentalVO);
    void requestExtend(Long rentalId, Long userId, String newReturnDate, String reason);
    Map<String, Object> findRentalByEquipmentId(Long equipmentId);
    void processReturn(Long rentalId, Long equipmentId);

    List<Map<String, Object>> getPendingRentals();
    void approveRental(Long rentalId);
    void rejectRental(Long rentalId);

    List<Map<String, Object>> getPendingExtends();
    void approveExtend(Long rentalId);
    void rejectExtend(Long rentalId);
}
