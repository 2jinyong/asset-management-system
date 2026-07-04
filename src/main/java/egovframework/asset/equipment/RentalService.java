package egovframework.asset.equipment;
public interface RentalService {
    void insertRentalRequest(RentalVO rentalVO);
    void extendRental(Long rentalId, Long userId, String newReturnDate);
}