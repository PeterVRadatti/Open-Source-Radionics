package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Target;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface TargetRepository extends CrudRepository<Target, Long> {

    List<Target> findByName(String name);
}
