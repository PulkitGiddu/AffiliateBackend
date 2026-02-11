package com.snatchmart.snatchmart.service.serviceImpl;

import com.snatchmart.snatchmart.DTO.CategoryRequest;
import com.snatchmart.snatchmart.DTO.CategoryResponse;
import com.snatchmart.snatchmart.entity.Category;
import com.snatchmart.snatchmart.repository.CategoryRepository;
import com.snatchmart.snatchmart.service.CategoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class CategoryServiceImpl implements CategoryService {
    private final CategoryRepository categoryRepository;

    public CategoryServiceImpl(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Override
    public List<CategoryResponse> getAll() {
        return categoryRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public CategoryResponse getById(UUID id) {
        return toResponse(getCategory(id));
    }

    @Override
    public CategoryResponse create(CategoryRequest request) {
        Category parent = null;
        if (request.getParentId() != null) {
            parent = getCategory(request.getParentId());
        }
        Category category = Category.builder()
                .name(request.getName())
                .slug(request.getSlug())
                .parent(parent)
                .build();
        return toResponse(categoryRepository.save(category));
    }

    @Override
    public CategoryResponse update(UUID id, CategoryRequest request) {
        Category category = getCategory(id);
        if (request.getName() != null) {
            category.setName(request.getName());
        }
        if (request.getSlug() != null) {
            category.setSlug(request.getSlug());
        }
        if (request.getParentId() != null) {
            Category parent = getCategory(request.getParentId());
            category.setParent(parent);
        }
        return toResponse(categoryRepository.save(category));
    }

    @Override
    public void delete(UUID id) {
        categoryRepository.deleteById(id);
    }

    private Category getCategory(UUID id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
    }

    private CategoryResponse toResponse(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .slug(category.getSlug())
                .parentId(category.getParent() != null ? category.getParent().getId() : null)
                .build();
    }
}
