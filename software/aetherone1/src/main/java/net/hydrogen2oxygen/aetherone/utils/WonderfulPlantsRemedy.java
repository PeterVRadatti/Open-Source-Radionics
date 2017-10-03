package net.hydrogen2oxygen.aetherone.utils;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class WonderfulPlantsRemedy {

    private String name;
    private String series;
    private String phase;
    private String stage;

    public String getKey() {
        return series + "." + phase + "."  + stage + " " + name;
    }

}
