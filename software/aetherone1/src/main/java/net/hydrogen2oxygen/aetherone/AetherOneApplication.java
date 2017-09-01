package net.hydrogen2oxygen.aetherone;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.PropertySource;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;

@SpringBootApplication
@PropertySource(value={"classpath:application.properties"})
public class AetherOneApplication {

	public static void main(String[] args) throws UnknownHostException {

		System.out.println("My IP-address is = [" +  InetAddress.getLocalHost().getHostAddress() + "]");
		SpringApplication.run(AetherOneApplication.class, args);
	}
}