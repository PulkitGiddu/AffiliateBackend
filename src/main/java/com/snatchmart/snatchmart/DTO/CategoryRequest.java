package com.snatchmart.snatchmart.DTO;

import lombok.Data;

import java.util.UUID;

@Data
public class CategoryRequest {
    private String name;
    private String slug;
    private UUID parentId;
}
