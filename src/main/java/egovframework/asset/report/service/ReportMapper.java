package egovframework.asset.report.service;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper
public interface ReportMapper {
    int insertReport(ReportVO reportVO);

    List<Map<String, Object>> selectPendingReports();
    Map<String, Object> selectReportById(Long reportId);
    int approveReport(Long reportId);
    int rejectReport(Long reportId);
}
