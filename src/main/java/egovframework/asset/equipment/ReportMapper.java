package egovframework.asset.equipment;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper
public interface ReportMapper {
    int insertReport(ReportVO reportVO);
}