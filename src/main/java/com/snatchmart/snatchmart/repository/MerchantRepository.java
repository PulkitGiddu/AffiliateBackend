package com.snatchmart.snatchmart.repository;

import com.snatchmart.snatchmart.entity.Merchant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface MerchantRepository extends JpaRepository<Merchant, UUID> {
    Optional<Merchant> findByNameIgnoreCase(String name);
}
