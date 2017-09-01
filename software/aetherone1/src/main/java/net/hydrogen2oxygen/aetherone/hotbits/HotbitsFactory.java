package net.hydrogen2oxygen.aetherone.hotbits;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

import org.apache.commons.io.FileUtils;

public class HotbitsFactory implements IHotbitsFactory {

	public File createHotbitPackage(int packageSize, String targetFolder) throws IOException {

		String fileName = getActualFileName();
		File file = new File(targetFolder + "/" + fileName);

		List<Byte> data = new ArrayList<>();

		while (data.size() < packageSize) {
			data.addAll(Arrays.asList(HotbitsAccessor.getBytes(packageSize - data.size())));
		}

		byte[] bytes = new byte[packageSize];

		for (int x = 0; x < packageSize; x++) {
			bytes[x] = data.get(x);
		}

		FileUtils.writeByteArrayToFile(file, bytes);

		return file;
	}

	public static String getActualFileName() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmssSSS");
		String timeString = sdf.format(Calendar.getInstance().getTime());
		String fileName = String.format("hotbits_%s.dat", timeString);
		return fileName;
	}
}
