package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.AffiliateClick;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface AffiliateClickRepository extends JpaRepository<AffiliateClick, UUID> {
}
