package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Case;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

/**
 * A case is a collection of sessions to analyzing and rebalancing a patient / target.
 */
@RepositoryRestResource(collectionResourceRel = "case", path = "case")
public interface CaseRepository extends CrudRepository<Case, Long> {
}
