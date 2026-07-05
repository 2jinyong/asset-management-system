package egovframework.asset.equipment;
public class RentalVO {
	private Long rentalId;
	private Long equipmentId;
	private String equipmentName;   // 추가
	private Long userId;
	private int quantity;
	private String purpose;
	private String requestStatus;
	private String rentalDate;
	private String returnDate;
	private String actualReturnDate;
	private String extendStatus;
	private String requestedReturnDate;
	private String extendReason;
	// Getter / Setter
	public Long getRentalId() {
		return rentalId;
	}
	public void setRentalId(Long rentalId) {
		this.rentalId = rentalId;
	}
	public Long getEquipmentId() {
		return equipmentId;
	}
	public void setEquipmentId(Long equipmentId) {
		this.equipmentId = equipmentId;
	}
	public String getEquipmentName() {
		return equipmentName;
	}
	public void setEquipmentName(String equipmentName) {
		this.equipmentName = equipmentName;
	}
	public Long getUserId() {
		return userId;
	}
	public void setUserId(Long userId) {
		this.userId = userId;
	}
	public int getQuantity() {
		return quantity;
	}
	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}
	public String getPurpose() {
		return purpose;
	}
	public void setPurpose(String purpose) {
		this.purpose = purpose;
	}
	public String getRequestStatus() {
		return requestStatus;
	}
	public void setRequestStatus(String requestStatus) {
		this.requestStatus = requestStatus;
	}
	public String getRentalDate() {
		return rentalDate;
	}
	public void setRentalDate(String rentalDate) {
		this.rentalDate = rentalDate;
	}
	public String getReturnDate() {
		return returnDate;
	}
	public void setReturnDate(String returnDate) {
		this.returnDate = returnDate;
	}
	public String getActualReturnDate() {
		return actualReturnDate;
	}
	public void setActualReturnDate(String actualReturnDate) {
		this.actualReturnDate = actualReturnDate;
	}
	public String getExtendStatus() {
		return extendStatus;
	}
	public void setExtendStatus(String extendStatus) {
		this.extendStatus = extendStatus;
	}
	public String getRequestedReturnDate() {
		return requestedReturnDate;
	}
	public void setRequestedReturnDate(String requestedReturnDate) {
		this.requestedReturnDate = requestedReturnDate;
	}
	public String getExtendReason() {
		return extendReason;
	}
	public void setExtendReason(String extendReason) {
		this.extendReason = extendReason;
	}
}