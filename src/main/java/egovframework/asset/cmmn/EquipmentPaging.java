package egovframework.asset.cmmn;

public class EquipmentPaging {
    private int page;
    private int perPageNum;

    public EquipmentPaging() {
        this.page = 1;
        this.perPageNum = 15;
    }

    public void setPage(int page) {
        if (page <= 0) { this.page = 1; return; }
        this.page = page;
    }

    public void setPerPageNum(int perPageNum) {
        if (perPageNum <= 0 || perPageNum > 100) { this.perPageNum = 15; return; }
        this.perPageNum = perPageNum;
    }

    public int getPage() { return page; }
    public int getPerPageNum() { return perPageNum; }
    public int getPageStart() { return (this.page - 1) * this.perPageNum; }
}