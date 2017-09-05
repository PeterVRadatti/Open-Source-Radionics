package net.hydrogen2oxygen.aetherone.connector;

import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import net.hydrogen2oxygen.aetherone.peristence.dao.TargetRepository;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Target;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@RestController
public class RestConnector {

    @Autowired
    private HotbitsClient hotbitsClient;

    @Autowired
    private TargetRepository targetRepository;

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

    @RequestMapping(value = "target", method = RequestMethod.POST, consumes = "application/json")
    public Target saveNewTarget(@RequestBody Target newTarget) {

        System.out.println("saving");
        return targetRepository.save(newTarget);
    }

    @RequestMapping(value = "target", method = RequestMethod.GET)
    public List<Target> getTarget() throws IOException {

        List<Target> list = new ArrayList<>();
        targetRepository.findAll().iterator().forEachRemaining(list::add);
        return list;
    }

    @RequestMapping(value = "target/{id}", method = RequestMethod.GET)
    public Target getTarget(@PathVariable Long id) throws IOException {

        return targetRepository.findOne(id);
    }

    @RequestMapping(value = "target/{id}", method = RequestMethod.DELETE)
    public void deleteTarget(@PathVariable Long id) throws IOException {

        targetRepository.delete(id);
    }
}