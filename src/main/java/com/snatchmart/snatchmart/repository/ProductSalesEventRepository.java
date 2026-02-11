package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.ProductSalesEvent;
import com.snatchmart.snatchmart.entity.ProductSalesEventId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductSalesEventRepository extends JpaRepository<ProductSalesEvent, ProductSalesEventId> {
}
