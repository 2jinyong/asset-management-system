package egovframework.asset.equipment;

import java.util.HashMap;
import java.util.List;
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
    public void insertReport(ReportVO reportVO) {
        // 승인 전까지는 비품/대여 상태를 바꾸지 않는다 (관리자 승인 시점에 BROKEN 처리 + 대여 종료).
        reportMapper.insertReport(reportVO);
    }

    @Override
    public List<Map<String, Object>> getPendingReports() {
        return reportMapper.selectPendingReports();
    }

    @Override
    @Transactional
    public void approveReport(Long reportId) {
        Map<String, Object> report = reportMapper.selectReportById(reportId);
        if (report == null) {
            throw new IllegalStateException("승인할 신고를 찾을 수 없습니다.");
        }

        reportMapper.approveReport(reportId);

        Map<String, Object> statusParams = new HashMap<>();
        statusParams.put("equipmentId", report.get("equipmentId"));
        statusParams.put("status", "BROKEN");
        rentalMapper.updateEquipmentStatus(statusParams);

        Long rentalId = (Long) report.get("rentalId");
        if (rentalId != null) {
            rentalMapper.deleteRental(rentalId);
        }
    }

    @Override
    public void rejectReport(Long reportId) {
        int updated = reportMapper.rejectReport(reportId);
        if (updated == 0) {
            throw new IllegalStateException("반려할 신고를 찾을 수 없습니다.");
        }
    }
}