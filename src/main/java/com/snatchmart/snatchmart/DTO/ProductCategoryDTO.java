package com.snatchmart.snatchmart.DTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;
import java.time.OffsetDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductCategoryDTO {
    private UUID id;
    private String name;
    private String slug;
    private UUID parent_id;
    private OffsetDateTime created_at;
    private OffsetDateTime updated_at;
}
