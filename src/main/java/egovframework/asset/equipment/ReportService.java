package egovframework.asset.equipment;

import java.util.List;
import java.util.Map;

public interface ReportService {
    void insertReport(ReportVO reportVO);

    List<Map<String, Object>> getOpenReports();
    Map<String, Object> getReport(Long reportId);

    void confirmReport(Long reportId);
    void startRepair(Long reportId);
    void resolveReport(Long reportId);
    void rejectReport(Long reportId);
}
