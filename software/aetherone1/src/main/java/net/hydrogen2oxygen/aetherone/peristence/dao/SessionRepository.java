package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Session;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

/**
 * A session is not "a technical session", but a session in the sense of a period of work,
 * sitting in front of the radionic device (or computer attached to the AetherOne) in order
 * to analyze, generate homeopathic remedies or broadcast information nonlocally.
 *
 * But in a technical sense a new session is generated for each case, target or even if you
 * just press the Button F5 refreshing your page.
 *
 * The session object therefore represents a condition for the protocol. This is useful when
 * one reads his journal of past sessions, learning from mistakes, or even to find out, that
 * the session was not useless at all.
 */
@RepositoryRestResource(collectionResourceRel = "session", path = "session")
public interface SessionRepository extends CrudRepository<Session, Long> {
}
