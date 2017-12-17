package net.hydrogen2oxygen.aetherone.peristence.dao;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Protocol;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

/**
 * Personally I regard the protocol as the heart of the AetherOne software.
 * Let me explain: If you want to explore dreams or even have lucid dreams,
 * you enter consciously another realm of consciousness, a altered state of
 * consciousness. Most of this work will be deleted after you wake up, which
 * is part of a security mechanism, a kind of garbage collector. So you will
 * not remember your dreams after an hour of being wake. Only if you keep a
 * dream journal your mind will regard your dreams as important enough in order
 * to remember them at least for a few minutes, enough for writing them down
 * into your dream journal and persisting them.
 *
 * The same applies for the work with radionics. You will with high probability
 * forget what you have analyzed during a session. And by reading the protocols
 * you will notice that you was indeed successful. In AetherOne some protocols
 * are generated automatically and some can be inserted manually (thoughts, notes
 * and so on).
 */
@RepositoryRestResource(collectionResourceRel = "protocol", path = "protocol")
public interface ProtocolRepository extends CrudRepository<Protocol, Long> {
}
