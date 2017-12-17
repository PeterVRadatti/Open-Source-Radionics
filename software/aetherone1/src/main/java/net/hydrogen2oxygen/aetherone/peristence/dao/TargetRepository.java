package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Target;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Targets are entities to which the operators links. For example a witness, a patient, a morphic field and so on.
 * They are used as input or output, depending on the intention of the radionic operator.
 */
@RepositoryRestResource(collectionResourceRel = "target", path = "target")
public interface TargetRepository extends CrudRepository<Target, Long> {

    List<Target> findByName(String name);
}