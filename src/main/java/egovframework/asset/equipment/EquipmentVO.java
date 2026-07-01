package egovframework.asset.equipment;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EquipmentVO {
    private Long equipmentId;
    private String equipmentName;
    private String category;
    private String status;
    private String qrImagePath;
    private String createdAt;
    private String updatedAt;
}