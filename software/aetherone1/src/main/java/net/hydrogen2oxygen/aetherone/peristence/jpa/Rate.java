package net.hydrogen2oxygen.aetherone.peristence.jpa;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Rate {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private String name;

    /**
     * For example homeopathy rates
     */
    private String groupName;

    /**
     * For example "James Tyler Kent"
     */
    private String sourceName;

    private String signature;

    @Lob
    @Column(length=4000,columnDefinition="TEXT")
    private String description;

    @Lob
    @Column(length=16777215,columnDefinition="TEXT")
    private String jsonObject;

    @Lob
    @Basic(fetch = FetchType.LAZY)
    @Column(length=16777215)
    private byte[] base64File;

}
