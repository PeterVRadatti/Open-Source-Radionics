package net.hydrogen2oxygen.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Protocol {

    private List<Map<String,Integer>> result = new ArrayList<>();
    private String output;
    private String input;
    private String level;
    private String synopsis;
    private String ratio;
    private Long dateTimeLong;
    private String dateTimeString;
    private String fileName;
}