package egovframework.asset.cmmn;

import org.egovframe.rte.fdl.cmmn.exception.handler.ExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AssetExcepHndlr implements ExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(AssetExcepHndlr.class);

    @Override
    public void occur(Exception ex, String packageName) {
        LOGGER.debug("AssetExcepHndlr - 예외 발생: {}", ex.getMessage());
    }
}
