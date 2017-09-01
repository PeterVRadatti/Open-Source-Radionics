package net.hydrogen2oxygen.aetherone.hotbits;

import java.io.File;
import java.io.IOException;

public interface IHotbitsFactory {

	public File createHotbitPackage(int packageSize, String targetFolder) throws IOException;
}