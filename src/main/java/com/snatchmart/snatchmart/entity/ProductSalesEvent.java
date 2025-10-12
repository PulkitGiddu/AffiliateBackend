package com.snatchmart.snatchmart.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "product_sales_events")
@IdClass(ProductSalesEventId.class)
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

    // Getters and setters
    // ...existing code...
}

// Composite key class
class ProductSalesEventId implements java.io.Serializable {
    private UUID productId;
    private UUID salesEventId;

    // equals and hashCode
    // ...existing code...
}

