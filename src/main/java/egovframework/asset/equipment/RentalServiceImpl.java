package egovframework.asset.equipment;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RentalServiceImpl implements RentalService {

    private final RentalMapper rentalMapper;
    private final EquipmentMapper equipmentMapper;

    public RentalServiceImpl(RentalMapper rentalMapper, EquipmentMapper equipmentMapper) {
        this.rentalMapper = rentalMapper;
        this.equipmentMapper = equipmentMapper;
    }

    @Override
    @Transactional
    public void insertRentalRequest(RentalVO rentalVO) {
        Map<String, Object> params = new HashMap<>();
        params.put("equipmentName", rentalVO.getEquipmentName());
        params.put("quantity", rentalVO.getQuantity());

        List<Long> availableIds = equipmentMapper.selectAvailableEquipmentIdsByName(params);

        if (availableIds.size() < rentalVO.getQuantity()) {
            throw new IllegalStateException("재고가 부족합니다. 현재 대여 가능 수량: " + availableIds.size());
        }

        for (Long equipmentId : availableIds) {
            RentalVO row = new RentalVO();
            row.setEquipmentId(equipmentId);
            row.setUserId(rentalVO.getUserId());
            row.setPurpose(rentalVO.getPurpose());
            row.setRentalDate(rentalVO.getRentalDate());
            row.setReturnDate(rentalVO.getReturnDate());

            rentalMapper.insertRental(row);

            Map<String, Object> statusParams = new HashMap<>();
            statusParams.put("equipmentId", equipmentId);
            statusParams.put("status", "RENTED");
            rentalMapper.updateEquipmentStatus(statusParams);
        }
    }

    @Override
    public void extendRental(Long rentalId, Long userId, String newReturnDate) {
        Map<String, Object> params = new HashMap<>();
        params.put("rentalId", rentalId);
        params.put("userId", userId);
        params.put("newReturnDate", newReturnDate);

        int updated = rentalMapper.updateReturnDate(params);
        if (updated == 0) {
            throw new IllegalStateException("연장할 대여 건을 찾을 수 없습니다.");
        }
    }

    @Override
    public Map<String, Object> findRentalByEquipmentId(Long equipmentId) {
        return rentalMapper.selectRentalByEquipmentId(equipmentId);
    }

    @Override
    @Transactional
    public void processReturn(Long rentalId, Long equipmentId) {
        int deleted = rentalMapper.deleteRental(rentalId);
        if (deleted == 0) {
            throw new IllegalStateException("반납 처리할 대여 건을 찾을 수 없습니다.");
        }

        Map<String, Object> statusParams = new HashMap<>();
        statusParams.put("equipmentId", equipmentId);
        statusParams.put("status", "AVAILABLE");
        rentalMapper.updateEquipmentStatus(statusParams);
    }
}