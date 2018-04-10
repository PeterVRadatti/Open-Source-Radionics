package net.hydrogen2oxygen.aetherone.connector;

import net.hydrogen2oxygen.aetherone.domain.AnalysisResult;
import net.hydrogen2oxygen.aetherone.domain.RateObject;
import net.hydrogen2oxygen.aetherone.domain.VitalityObject;
import net.hydrogen2oxygen.aetherone.hotbits.HotBitIntegers;
import net.hydrogen2oxygen.aetherone.hotbits.HotbitPackage;
import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import net.hydrogen2oxygen.aetherone.peristence.dao.CaseRepository;
import net.hydrogen2oxygen.aetherone.peristence.dao.RateRepository;
import net.hydrogen2oxygen.aetherone.peristence.dao.SessionRepository;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Case;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Rate;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Session;
import net.hydrogen2oxygen.aetherone.service.AnalyseService;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.IOException;
import java.util.*;

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

    @Autowired
    private AnalyseService analyseService;

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

    @RequestMapping("rate/groups")
    public Iterable<String> getAllGroups() {
        return rateRepository.getAllGroups();
    }

    @RequestMapping("rate/sources")
    public Iterable<String> getAllSources() {
        return rateRepository.getAllSources();
    }

    @RequestMapping("analysis/generalVitality")
    public Integer analyseGeneralVitality() {

        Map<Integer,Integer> vitalityMap = new HashMap<>();

        for (int x=0; x<101; x++) {

            vitalityMap.put(x,0);
        }

        for (int x=0; x<3456; x++) {

            Integer key = hotbitsClient.getInteger(0,100);
            Integer value = vitalityMap.get(key) + 1;
            vitalityMap.put(key,value);
        }

        List<VitalityObject> vitalityList = new ArrayList<>();

        for (int x=0; x<101; x++) {
            vitalityList.add(new VitalityObject(x,vitalityMap.get(x)));
        }

        Collections.sort(vitalityList, new Comparator<VitalityObject>() {
            @Override
            public int compare(VitalityObject o1, VitalityObject o2) {
                return o2.getValue().compareTo(o1.getValue());
            }
        });

        return vitalityList.get(0).getNumber();
    }

    @RequestMapping("analysis/{rateListName}")
    public AnalysisResult analysisRateList(@PathVariable String rateListName) throws IOException {

        AnalysisResult analysisResult = new AnalysisResult();

        Iterable<Rate> rates = rateRepository.findAllBySourceName(rateListName);
        return analyseService.getAnalysisResult(analysisResult, rates);
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