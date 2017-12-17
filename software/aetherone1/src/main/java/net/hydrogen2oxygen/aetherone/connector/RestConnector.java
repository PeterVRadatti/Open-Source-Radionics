package net.hydrogen2oxygen.aetherone.connector;

import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
public class RestConnector {

    @Autowired
    private HotbitsClient hotbitsClient;

    /*@Autowired
    private TargetRepository targetRepository;

    @Autowired
    private CaseRepository caseRepository;*/

    @RequestMapping("ping")
    public String ping() throws IOException {
        return "pong";
    }

    @RequestMapping("hotbits-status")
    public Boolean hotbitsStatus() throws IOException {
        return hotbitsClient.hotbitsAvalaible();
    }

    /*@RequestMapping(value = "case", method = RequestMethod.POST, consumes = "application/json")
    public Case saveNewCase(@RequestBody Case c) {

        return caseRepository.save(c);
    }

    @RequestMapping(value = "case", method = RequestMethod.GET)
    public List<Case> getCase() throws IOException {

        List<Case> list = new ArrayList<>();
        caseRepository.findAll().iterator().forEachRemaining(list::add);
        return list;
    }

    @RequestMapping(value = "case/{id}", method = RequestMethod.GET)
    public Case getCase(@PathVariable Long id) throws IOException {

        return caseRepository.findOne(id);
    }

    @RequestMapping(value = "case/{id}", method = RequestMethod.DELETE)
    public void deleteCase(@PathVariable Long id) throws IOException {

        caseRepository.delete(id);
    }

    @RequestMapping(value = "target", method = RequestMethod.POST, consumes = "application/json")
    public Target saveNewTarget(@RequestBody Target newTarget) {

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

    @RequestMapping(value = "target/image/{id}", method = RequestMethod.GET)
    public String getTargetImage(@PathVariable Long id) throws IOException {

        return new String(targetRepository.findOne(id).getBase64File());
    }

    @RequestMapping(value = "target/{id}", method = RequestMethod.DELETE)
    public void deleteTarget(@PathVariable Long id) throws IOException {

        targetRepository.delete(id);
    }*/
}