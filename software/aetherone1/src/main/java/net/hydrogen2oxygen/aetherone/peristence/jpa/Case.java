package net.hydrogen2oxygen.aetherone.peristence.jpa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Component;

import javax.persistence.*;
import java.util.*;

/**
 * A case persists of multiple sessions. It represents the main target.
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
}