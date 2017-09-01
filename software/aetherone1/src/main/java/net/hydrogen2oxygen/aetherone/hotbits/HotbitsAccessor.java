package net.hydrogen2oxygen.aetherone.hotbits;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

/**
 * True random numbers deriving from a diode inside the Raspberry Pi. They seed
 * a standard java.util.Random.
 * 
 * @author Peter
 *
 */
public class HotbitsAccessor {

	private static Long counterError = 0L;

	private HotbitsAccessor() {
	}

	public static Byte[] getBytes(Integer n) {

		FileInputStream in = null;

		try {

			in = getFileInputStream();

			Byte[] data = new Byte[n];

			for (int x = 0; x < n; x++)
				data[x] = (byte) in.read();

			return data;

		} catch (Exception e) {
			counterError++;

			System.err.println("Error while accessing hotbits = " + e.getMessage());
			System.out.println("wait a little and then proceed");

			try {
				Thread.sleep(250);
			} catch (InterruptedException e1) {
			}

			System.out.println("continue");
		} finally {

			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return null;
	}

	/**
	 * The actual access to the TRNG of the Raspberry Pi
	 * @return FileInputStream ... a stream of Qubits
	 * @throws FileNotFoundException
	 */
	public static FileInputStream getFileInputStream() throws FileNotFoundException {

		return new FileInputStream("/dev/hwrng");
	}

}