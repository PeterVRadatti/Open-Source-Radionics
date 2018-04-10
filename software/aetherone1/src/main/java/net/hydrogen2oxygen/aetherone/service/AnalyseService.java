package net.hydrogen2oxygen.aetherone.service;

import net.hydrogen2oxygen.aetherone.domain.AnalysisResult;
import net.hydrogen2oxygen.aetherone.domain.RateObject;
import net.hydrogen2oxygen.aetherone.hotbits.HotbitsClient;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Rate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class AnalyseService {

    @Autowired
    private HotbitsClient hotbitsClient;

    public AnalysisResult getAnalysisResult(AnalysisResult analysisResult, Iterable<Rate> rates) {
        List<Rate> rateList = new ArrayList<>();

        for (Rate rate : rates) {
            rateList.add(rate);
        }

        Map<String, Integer> ratesValues = new HashMap<>();

        int max = rateList.size() / 10;
        if (max > 100) max = 100;
        int count = 0;

        while (rateList.size() > 0) {

            int x = hotbitsClient.getInteger(0,rateList.size() - 1);
            Rate rate = rateList.remove(x);
            ratesValues.put(rate.getName(),0);

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
}
