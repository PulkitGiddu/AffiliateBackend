package com.snatchmart.snatchmart.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Entity
@Table(name = "product_sales_events")
@IdClass(ProductSalesEventId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductSalesEvent {
    @Id
    @Column(name = "product_id")
    private UUID productId;

    @Id
    @Column(name = "sales_event_id")
    private UUID salesEventId;

    @ManyToOne
    @JoinColumn(name = "product_id", insertable = false, updatable = false)
    private Product product;

    @ManyToOne
    @JoinColumn(name = "sales_event_id", insertable = false, updatable = false)
    private SalesEvent salesEvent;
}
