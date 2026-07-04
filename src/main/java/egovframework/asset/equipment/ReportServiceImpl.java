package egovframework.asset.equipment;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReportServiceImpl implements ReportService {

    private final ReportMapper reportMapper;
    private final RentalMapper rentalMapper;

    public ReportServiceImpl(ReportMapper reportMapper, RentalMapper rentalMapper) {
        this.reportMapper = reportMapper;
        this.rentalMapper = rentalMapper;
    }

    @Override
    @Transactional
    public void insertReport(ReportVO reportVO) {
        reportMapper.insertReport(reportVO);

        rentalMapper.deleteRental(reportVO.getRentalId());

        Map<String, Object> statusParams = new HashMap<>();
        statusParams.put("equipmentId", reportVO.getEquipmentId());
        statusParams.put("status", "BROKEN");
        rentalMapper.updateEquipmentStatus(statusParams);
    }
}