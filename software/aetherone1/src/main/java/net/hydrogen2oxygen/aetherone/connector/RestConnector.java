package net.hydrogen2oxygen.aetherone.connector;

import net.hydrogen2oxygen.aetherone.domain.AnalysisResult;
import net.hydrogen2oxygen.aetherone.domain.RateObject;
import net.hydrogen2oxygen.aetherone.hotbits.HotBitIntegers;
import net.hydrogen2oxygen.aetherone.hotbits.HotbitPackage;
import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import net.hydrogen2oxygen.aetherone.peristence.dao.CaseRepository;
import net.hydrogen2oxygen.aetherone.peristence.dao.RateRepository;
import net.hydrogen2oxygen.aetherone.peristence.dao.SessionRepository;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Case;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Rate;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Session;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class RestConnector {

    @Autowired
    private HotbitsClient hotbitsClient;

    @Autowired
    private SessionRepository sessionRepository;

    @Autowired
    private CaseRepository caseRepository;

    @Autowired
    private RateRepository rateRepository;

    /**
     * The current case, from a "new case" action or by selection from a list
     */
    @Autowired
    private Case selectedCase;

    /**
     * The current session, by selecting a new or old case, or just by hitting F5.
     * <p>
     * A session is always connected to a case.
     */
    @Autowired
    private Session selectedSession;

    @RequestMapping("ping")
    public String ping() throws IOException {
        return "pong";
    }

    @RequestMapping("hotbits-status")
    public Boolean hotbitsStatus() throws IOException {
        return hotbitsClient.hotbitsAvalaible();
    }

    @RequestMapping("hotbits-integer/{min}/{max}/{ammount}")
    public HotBitIntegers getHotbitsInteger(@PathVariable Integer min, @PathVariable Integer max, @PathVariable Integer ammount) {

        HotBitIntegers hotBitIntegers = new HotBitIntegers();

        for (int i=0; i<ammount; i++){
            hotBitIntegers.getIntegerList().add(hotbitsClient.getInteger(min, max));
        }

        return hotBitIntegers;
    }

    @RequestMapping("analysis/{rateListName}")
    public AnalysisResult analysisRateList(@PathVariable String rateListName) throws IOException {

        AnalysisResult analysisResult = new AnalysisResult();

        List<String> rates = FileUtils.readLines(new File("src/main/resources/rates/" + rateListName + ".txt"), "UTF-8");
        Map<String, Integer> ratesValues = new HashMap<>();

        int max = rates.size() / 10;
        if (max > 100) max = 100;
        int count = 0;

        while (rates.size() > 0) {

            int x = hotbitsClient.getInteger(0,rates.size() - 1);
            String rate = rates.remove(x);
            ratesValues.put(rate,0);

            count +=1;

            if (count >= max) {
                break;
            }
        }

        for (int x=0; x<7; x++) {
            for (String rate : ratesValues.keySet()) {

                Integer energeticValue = ratesValues.get(rate);
                energeticValue += hotbitsClient.getInteger(0, 100);
                ratesValues.put(rate, energeticValue);
            }
        }

        for (String rate : ratesValues.keySet()) {
            analysisResult.getRateObjects().add(new RateObject(ratesValues.get(rate),rate));
        }

        return analysisResult.sort();
    }

    @RequestMapping(value = "case/selected/{id}", method = RequestMethod.GET)
    public Case selectCase(@PathVariable Long id) {
        selectedCase = caseRepository.findOne(id);
        return selectedCase;
    }

    @RequestMapping(value = "session/selected/{id}", method = RequestMethod.GET)
    public Session selectSession(@PathVariable Long id) {
        selectedSession = sessionRepository.findOne(id);
        return selectedSession;
    }

    @RequestMapping("case/selected")
    public Case getSelectedCase() {
        return selectedCase;
    }

    @RequestMapping("session/selected")
    public Session getSelectedSession() {
        return selectedSession;
    }
    
}