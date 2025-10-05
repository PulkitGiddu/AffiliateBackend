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
public class MerchantDTO {
    private String id;
    private String storeName;
    private String logo_url;
    private LocalDateTime created_at;
    private LocalDateTime updated_at;
}
