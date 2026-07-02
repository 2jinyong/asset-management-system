package egovframework.asset.cmmn;

public class PageMaker {
    private EquipmentPaging paging;
    private int totalCount;
    private int startPage;
    private int endPage;
    private boolean prev;
    private boolean next;
    private int displayPageNum = 5;

    public void setPaging(EquipmentPaging paging) {
        this.paging = paging;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
        calcData();
    }

    private void calcData() {
        this.endPage = (int) (Math.ceil(paging.getPage() / (double) displayPageNum) * displayPageNum);
        this.startPage = (this.endPage - displayPageNum) + 1;

        int tempEndPage = (int) (Math.ceil(totalCount / (double) paging.getPerPageNum()));
        if (this.endPage > tempEndPage) {
            this.endPage = tempEndPage;
        }

        this.prev = (this.startPage != 1);
        this.next = (this.endPage * paging.getPerPageNum() < totalCount);
    }

    public int getStartPage() { return startPage; }
    public int getEndPage() { return endPage; }
    public boolean isPrev() { return prev; }
    public boolean isNext() { return next; }
    public EquipmentPaging getPaging() { return paging; }
}