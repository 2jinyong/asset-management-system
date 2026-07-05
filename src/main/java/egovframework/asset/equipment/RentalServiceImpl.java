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

        // 승인 전까지는 비품 상태를 바꾸지 않는다 (관리자 승인 시점에 RENTED 로 전환).
        for (Long equipmentId : availableIds) {
            RentalVO row = new RentalVO();
            row.setEquipmentId(equipmentId);
            row.setUserId(rentalVO.getUserId());
            row.setPurpose(rentalVO.getPurpose());
            row.setRentalDate(rentalVO.getRentalDate());
            row.setReturnDate(rentalVO.getReturnDate());

            rentalMapper.insertRental(row);
        }
    }

    @Override
    public void requestExtend(Long rentalId, Long userId, String newReturnDate, String reason) {
        Map<String, Object> params = new HashMap<>();
        params.put("rentalId", rentalId);
        params.put("userId", userId);
        params.put("newReturnDate", newReturnDate);
        params.put("reason", reason);

        int updated = rentalMapper.requestExtend(params);
        if (updated == 0) {
            throw new IllegalStateException("연장 요청할 대여 건을 찾을 수 없습니다.");
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

    @Override
    public List<Map<String, Object>> getPendingRentals() {
        return rentalMapper.selectPendingRentals();
    }

    @Override
    public void approveRental(Long rentalId) {
        int updated = rentalMapper.approveRental(rentalId);
        if (updated == 0) {
            throw new IllegalStateException("승인할 대여 요청을 찾을 수 없습니다.");
        }
    }

    @Override
    public void rejectRental(Long rentalId) {
        int updated = rentalMapper.rejectRental(rentalId);
        if (updated == 0) {
            throw new IllegalStateException("반려할 대여 요청을 찾을 수 없습니다.");
        }
    }

    @Override
    public List<Map<String, Object>> getPendingExtends() {
        return rentalMapper.selectPendingExtends();
    }

    @Override
    public void approveExtend(Long rentalId) {
        int updated = rentalMapper.approveExtend(rentalId);
        if (updated == 0) {
            throw new IllegalStateException("승인할 연장 요청을 찾을 수 없습니다.");
        }
    }

    @Override
    public void rejectExtend(Long rentalId) {
        int updated = rentalMapper.rejectExtend(rentalId);
        if (updated == 0) {
            throw new IllegalStateException("반려할 연장 요청을 찾을 수 없습니다.");
        }
    }
}