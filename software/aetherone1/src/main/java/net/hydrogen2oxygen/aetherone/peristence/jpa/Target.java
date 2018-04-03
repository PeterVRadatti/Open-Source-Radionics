package net.hydrogen2oxygen.aetherone.peristence.jpa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

/**
 * The target is the witness, patient or the input. (In this case the rate is the output and can be used to copy or broadcast).
 */
@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Target {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private String name;
    private String signature;

    @Lob
    @Column(length=4000,columnDefinition="TEXT")
    private String description;

    @Lob
    @Basic(fetch = FetchType.LAZY)
    @Column(length=16777215)
    private byte[] base64File;

    private String fileExtension;
}