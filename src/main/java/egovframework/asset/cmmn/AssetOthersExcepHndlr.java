package egovframework.asset.cmmn;

import org.egovframe.rte.fdl.cmmn.exception.handler.ExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AssetOthersExcepHndlr implements ExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(AssetOthersExcepHndlr.class);

    @Override
    public void occur(Exception exception, String packageName) {
        LOGGER.debug("AssetOthersExcepHndlr - 예외 발생: {}", exception.getMessage());
    }
}
