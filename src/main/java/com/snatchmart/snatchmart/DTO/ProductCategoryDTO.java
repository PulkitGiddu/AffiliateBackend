package com.snatchmart.snatchmart.DTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductCategoryDTO {
    private String id;
    private String category_name;
    // TODO: this sku_id should be unique given name and this for now we cannot keep as null let me check later
    private String sku_id; // it could be product unique name or id
    private Integer parent_id;
    private LocalDateTime created_at;
    private LocalDateTime updated_at;

}
