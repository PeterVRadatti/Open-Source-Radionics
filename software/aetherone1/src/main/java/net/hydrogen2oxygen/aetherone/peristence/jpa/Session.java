package net.hydrogen2oxygen.aetherone.peristence.jpa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Component;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * A session includes data of intention, anamnesis,
 * rate analysis and more, and represents a entry in the "diary" and it belongs to a case.
 * Multiple protocol entries are linked to one session.
 */
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Component
public class Session {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private Long caseID;

    /**
     * One session is also bound to one specific target / person
     */
    private Long targetID;

    private Calendar createdTime = Calendar.getInstance();

    @Lob
    @Column(length=2000,columnDefinition="TEXT")
    private String intentionDescription;
}