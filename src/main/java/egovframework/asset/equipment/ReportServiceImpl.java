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
    @Transactional
    public void insertReport(ReportVO reportVO) {
        // 신고 접수 즉시 비품을 BROKEN 처리해 다른 사용자가 대여하지 못하게 막는다.
        // 신고자의 대여 건은 관리자가 고장접수(CONFIRMED) 처리할 때 종료한다.
        reportMapper.insertReport(reportVO);
        updateEquipmentStatus(reportVO.getEquipmentId(), "BROKEN");
    }

    @Override
    public List<Map<String, Object>> getOpenReports() {
        return reportMapper.selectOpenReports();
    }

    @Override
    public Map<String, Object> getReport(Long reportId) {
        return reportMapper.selectReportById(reportId);
    }

    @Override
    @Transactional
    public void confirmReport(Long reportId) {
        Map<String, Object> report = requireReport(reportId, "고장접수 처리할 신고를 찾을 수 없습니다.");

        updateReportStatus(reportId, "CONFIRMED");

        Long rentalId = (Long) report.get("rentalId");
        if (rentalId != null) {
            rentalMapper.deleteRental(rentalId);
        }
    }

    @Override
    public void startRepair(Long reportId) {
        requireReport(reportId, "수리 시작 처리할 신고를 찾을 수 없습니다.");
        updateReportStatus(reportId, "REPAIRING");
    }

    @Override
    @Transactional
    public void resolveReport(Long reportId) {
        Map<String, Object> report = requireReport(reportId, "수리완료 처리할 신고를 찾을 수 없습니다.");

        updateReportStatus(reportId, "RESOLVED");
        updateEquipmentStatus((Long) report.get("equipmentId"), "AVAILABLE");
    }

    @Override
    @Transactional
    public void rejectReport(Long reportId) {
        Map<String, Object> report = requireReport(reportId, "반려할 신고를 찾을 수 없습니다.");

        updateReportStatus(reportId, "REJECTED");
        updateEquipmentStatus((Long) report.get("equipmentId"), "RENTED");
    }

    private Map<String, Object> requireReport(Long reportId, String errorMessage) {
        Map<String, Object> report = reportMapper.selectReportById(reportId);
        if (report == null) {
            throw new IllegalStateException(errorMessage);
        }
        return report;
    }

    private void updateReportStatus(Long reportId, String status) {
        Map<String, Object> params = new HashMap<>();
        params.put("reportId", reportId);
        params.put("status", status);
        reportMapper.updateReportStatus(params);
    }

    private void updateEquipmentStatus(Long equipmentId, String status) {
        Map<String, Object> params = new HashMap<>();
        params.put("equipmentId", equipmentId);
        params.put("status", status);
        rentalMapper.updateEquipmentStatus(params);
    }
}
