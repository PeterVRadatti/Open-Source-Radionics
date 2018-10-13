package net.hydrogen2oxygen.adapter;

import com.fasterxml.jackson.databind.ObjectMapper;
import net.hydrogen2oxygen.domain.Protocol;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@RestController
public class ProtocolRest {

    @RequestMapping("/protocol")
    public List<Protocol> getAll() throws IOException {

        List<Protocol> protocols = new ArrayList<>();
        String filePath = System.getProperty("user.home");
        filePath += "/AetherOne/";

        File aetherOneDirectory = new File(filePath);
        ObjectMapper mapper = new ObjectMapper();

        for (File file : aetherOneDirectory.listFiles()) {

            if (file.isFile() && file.getName().startsWith("protocol_")) {
                Protocol protocol = mapper.readValue(file, Protocol.class);
                protocols.add(protocol);
            }
        }

        return protocols;
    }
}
