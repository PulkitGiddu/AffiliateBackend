package com.snatchmart.snatchmart.DTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductsDTO {
    private String id;
    private String product_name;
    private String description_text;
    private String product_unique_id;
    private Integer original_price;
    private Integer sale_price;
    //TODO: parameters added to check ratings and reviews
    private String ratings;
    private String reviews;
    private String affiliate_url;
    private String image_url;
    private String merchant_id;  // NOT NULL value
    private String category_id;  // NOT NULL value
    private String is_active;
    private String deals_expires_at;
    private String created_at;
    private String updated_at;

}
