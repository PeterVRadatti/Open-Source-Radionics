package net.hydrogen2oxygen.aetherone.hotbits;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Random;

import lombok.Data;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Data
@Component
public class HotbitsClient {

    private Random pseudoRandom;

    private byte[] currentData;
    private int currentPosition = 0;

    private final List<HotbitPackage> hotbitPackages = new ArrayList<>();

    private String hotbitServerUrls;
    private Long lastCall = null;

    @Value("${packageSize}")
    private int packageSize = 1000;
    @Value("${storageSize}")
    private Integer storageSize = 100;
    @Value("${packageFolder}")
    private String packageFolder = "hotbits";

    private boolean stop = false;
    private int errorCounter = 0;
    private HotbitsFactory hotbitsFactory;

    public HotbitsClient() throws Exception {

        // Fallback if hotbits are not available (local test for example)
        pseudoRandom = new Random(Calendar.getInstance().getTimeInMillis());
        hotbitsFactory = new HotbitsFactory();
        actualizeLastCallValue();
        initAsynchronousDownload();
    }

    private synchronized void actualizeLastCallValue() {
        lastCall = Calendar.getInstance().getTimeInMillis();
    }

    public synchronized void close() {
        System.out.println(hotbitPackages.size());
        stop = true;
    }

    private HotbitPackage downloadPackage() throws InterruptedException, IOException {

        System.out.println(hotbitPackages.size());

        File hotbitFile = hotbitsFactory.createHotbitPackage(packageSize, packageFolder);

        HotbitPackage hotbitPackage = HotbitPackage.builder().fileName(hotbitFile.getName()).hotbits(FileUtils.readFileToString(hotbitFile, "UTF-8")).build();
        hotbitPackage.setOriginalSize(hotbitPackage.getHotbits().length());
        return hotbitPackage;
    }

    public String getRandomHex(int length) {

        StringBuffer sb = new StringBuffer();
        while (sb.length() < length) {
            sb.append(Integer.toHexString(getRandom(getSeed(10)).nextInt()));
        }

        return sb.toString().substring(0, length).toUpperCase();
    }

    public boolean getBooleanByEven() {
        return (getSeed(1) & 1) == 0;
    }

    public boolean getBoolean() {
        return getRandom(getSeed(5)).nextBoolean();
    }

    public int getInteger(int bound) {
        return getRandom(getSeed(10)).nextInt(bound);
    }

    public int getInteger(Integer min, Integer max) {
        return getRandom(getSeed(10)).nextInt((max - min) + 1) + min;
    }

    public synchronized HotbitPackage getPackage() throws InterruptedException, IOException {

        actualizeLastCallValue();

        // First check the storage and trigger a download process
        if (hotbitPackages.isEmpty()) {

            HotbitPackage hotPackage = downloadPackage();

            if (hotPackage != null && hotPackage.getOriginalSize() > 0) {
                hotbitPackages.add(hotPackage);
                System.out.println("Wait a little in order to regain cache!");
                Thread.sleep(125);
                System.out.println("--- ok continue ---");
            }
        }

        if (!hotbitPackages.isEmpty()) {
            HotbitPackage hotPackage = hotbitPackages.remove(0);
            return hotPackage;
        }

        return null;
    }

    public Random getRandom(Long seed) {

        // Fallback to simulation
        if (seed == 0) {
            return pseudoRandom;
        }

        // The real deal: hotbits initialized random (delivers for one run true random numbers)
        return new Random(seed);
    }

    /**
     * If it return false it could mean that you are working on a developer machine or you have startet the application without sudo rights!
     *
     * @return true if available
     */
    public Boolean hotbitsAvalaible() {

        return getByte() != null;
    }

    public Long getSeed(int iterations) {

        long seed = 0;

        for (int x = 0; x < iterations; x++) {
            Byte b = getByte();

            if (b != null) {
                seed += b;
            }
        }

        if (seed < 0) {
            seed = seed * -1;
        }

        return seed;
    }

    public byte[] getBytes(int ammount) {

        byte[] bytes = new byte[ammount];

        for (int x = 0; x < ammount; x++) {
            bytes[x] = getByte();
        }

        return bytes;
    }

    public Byte getByte() {

        byte b = currentData[currentPosition];
        currentPosition++;

        if (currentPosition >= (packageSize - 1)) {

            currentPosition = 0;

            try {
                refreshActualPackage();
            } catch (InterruptedException e) {
                e.printStackTrace();
                return null;
            } catch (IOException e) {
                e.printStackTrace();
                return null;
            }
        }

        return b;
    }

    private void initAsynchronousDownload() {

        hotbitsFactory = new HotbitsFactory();

        try {
            if (HotbitsAccessor.getBytes(5) == null) {
                return;
            }
        } catch(Exception e) {
            return;
        }

        (new Thread() {
            public void run() {

                while (!stop) {

                    if (hotbitPackages.size() < storageSize) {

                        try {
                            HotbitPackage hotPackage = downloadPackage();

                            if (hotPackage != null && hotPackage.getOriginalSize() > 0) {
                                hotbitPackages.add(hotPackage);
                                errorCounter = 0;
                            }

                        } catch (InterruptedException e) {

                            if (errorCounter == 0) {
                                e.printStackTrace();
                            }

                            errorCounter++;
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }

                    if (errorCounter > 0) {
                        makePause(10000);
                    }

                    if (errorCounter > 20) {
                        makePause(60000);
                    }

                    makePause();
                }
            }

            private void makePause() {
                try {

                    long lastCallInMillis = Calendar.getInstance().getTimeInMillis() - lastCall;

                    if (lastCallInMillis < 60000) {
                        Thread.sleep(10);
                    } else {
                        System.out.println("slow mode");
                        Thread.sleep(10000);
                    }

                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            private void makePause(long millis) {
                try {
                    Thread.sleep(millis);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private void refreshActualPackage() throws InterruptedException, IOException {

        HotbitPackage hotbitPackage = getPackage();

        if (hotbitPackage == null) {
            System.err.println("No data available via REST services!");
            return;
        }

        currentData = hotbitPackage.getHotbits().getBytes();
        packageSize = currentData.length;
    }
}
