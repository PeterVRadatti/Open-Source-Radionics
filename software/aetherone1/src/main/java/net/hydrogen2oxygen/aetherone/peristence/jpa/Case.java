package net.hydrogen2oxygen.aetherone.peristence.jpa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Component;

import javax.persistence.*;
import java.util.*;

/**
 * A case persists of multiple sessions. It contains one target (person, animal, plant ...)
 * or multiple targets for agriculture or a family / group (epidemic).
 *
 * It represents something like a file folder (ring binder).
 */
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Component
public class Case {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private Calendar createdTime = Calendar.getInstance();

    private String name;

    private String description;

    @ElementCollection(targetClass=Long.class)
    private List<Long> targetIDs = new ArrayList<>();
}