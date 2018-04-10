package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Rate;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

/**
 * A rate (classical name for energetic signature) represents a remedy or trend
 */
@RepositoryRestResource(collectionResourceRel = "rate", path = "rate")
public interface RateRepository extends CrudRepository<Rate, Long> {

    Iterable<Rate> findAllBySourceName(String sourceName);

    Iterable<Rate> findAllByGroupName(String groupName);

    Iterable<Rate> findAllByName(String name);

    @Query("SELECT r.groupName, r.sourceName FROM Rate r GROUP BY r.groupName, r.sourceName")
    Iterable<String> getAllGroups();

    @Query("SELECT r.sourceName, r.groupName FROM Rate r GROUP BY r.sourceName, r.groupName")
    Iterable<String> getAllSources();
}