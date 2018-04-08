package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Rate;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

/**
 * A rate (classical name for energetic signature) represents a remedy or trend
 */
@RepositoryRestResource(collectionResourceRel = "rate", path = "rate")
public interface RateRepository extends CrudRepository<Rate, Long> {

    Iterable<Rate> findAllByGroupName(String groupName);

    Iterable<Rate> findAllByName(String name);
}