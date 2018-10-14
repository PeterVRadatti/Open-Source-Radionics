package net.hydrogen2oxygen.adapter;

import com.fasterxml.jackson.databind.ObjectMapper;
import net.hydrogen2oxygen.domain.Protocol;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

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

            if (!file.isFile()) continue;
            if (!file.getName().startsWith("protocol_")) continue;

            Protocol protocol = mapper.readValue(file, Protocol.class);

            if (!StringUtils.isEmpty(protocol.getInput())) {

                String[] parts = file.getName().split("_");
                Long dateLong = Long.parseLong(parts[1]);
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                Date date = new Date(dateLong);
                protocol.setDateTimeLong(dateLong);
                protocol.setDateTimeString(sdf.format(date));
                protocol.setFileName(file.getName());
                protocols.add(protocol);
            }
        }

        Collections.sort(protocols, new Comparator<Protocol>() {
            @Override
            public int compare(Protocol o1, Protocol o2) {
                return o2.getDateTimeLong().compareTo(o1.getDateTimeLong());
            }
        });

        return protocols;
    }

    @RequestMapping("/protocol/{id}")
    public Protocol get(@PathVariable Long id) throws IOException {

        String filePath = System.getProperty("user.home");
        filePath += "/AetherOne/";

        File aetherOneDirectory = new File(filePath);
        ObjectMapper mapper = new ObjectMapper();

        for (File file : aetherOneDirectory.listFiles()) {

            if (!file.isFile()) continue;
            if (!file.getName().startsWith("protocol_" + id)) continue;

            Protocol protocol = mapper.readValue(file, Protocol.class);
            String[] parts = file.getName().split("_");
            Long dateLong = Long.parseLong(parts[1]);
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = new Date(dateLong);
            protocol.setDateTimeLong(dateLong);
            protocol.setDateTimeString(sdf.format(date));
            protocol.setFileName(file.getName());
            return protocol;
        }

        return null;
    }
}
