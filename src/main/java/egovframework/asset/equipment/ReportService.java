package egovframework.asset.equipment;

import java.util.List;
import java.util.Map;

public interface ReportService {
    void insertReport(ReportVO reportVO);

    List<Map<String, Object>> getPendingReports();
    void approveReport(Long reportId);
    void rejectReport(Long reportId);
}