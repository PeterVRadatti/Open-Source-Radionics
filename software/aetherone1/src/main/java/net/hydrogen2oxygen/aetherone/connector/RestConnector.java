package net.hydrogen2oxygen.aetherone.connector;

import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;
import java.io.IOException;

@RestController
public class RestConnector {

    @Autowired
    private HotbitsClient hotbitsClient;

    @RequestMapping("ping")
    public String ping() throws IOException {
        return "pong";
    }

    @RequestMapping("hotbits-status")
    public Boolean hotbitsStatus() throws IOException {
        Boolean result = hotbitsClient.hotbitsAvalaible();
        System.out.println(result);
        return result;
    }


}