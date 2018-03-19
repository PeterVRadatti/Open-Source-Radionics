package net.hydrogen2oxygen.aetherone.connector;

import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import net.hydrogen2oxygen.aetherone.peristence.dao.CaseRepository;
import net.hydrogen2oxygen.aetherone.peristence.dao.SessionRepository;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Case;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
public class RestConnector {

    @Autowired
    private HotbitsClient hotbitsClient;

    @Autowired
    private SessionRepository sessionRepository;

    @Autowired
    private CaseRepository caseRepository;

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