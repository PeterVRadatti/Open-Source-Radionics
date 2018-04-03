package net.hydrogen2oxygen.aetherone.peristence.jpa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.Calendar;

/**
 * Every action or insight during a session will be logged in a protocol.
 */
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Protocol {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private Calendar createdTime;

    @Lob
    @Column(length=2000,columnDefinition="TEXT")
    private String text;

    private Long sessionId;
}
