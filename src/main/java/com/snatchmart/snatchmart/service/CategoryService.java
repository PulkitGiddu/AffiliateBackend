package com.snatchmart.snatchmart.service;

import com.snatchmart.snatchmart.DTO.CategoryRequest;
import com.snatchmart.snatchmart.DTO.CategoryResponse;

import java.util.List;
import java.util.UUID;

public interface CategoryService {
    List<CategoryResponse> getAll();
    CategoryResponse getById(UUID id);
    CategoryResponse create(CategoryRequest request);
    CategoryResponse update(UUID id, CategoryRequest request);
    void delete(UUID id);
}
