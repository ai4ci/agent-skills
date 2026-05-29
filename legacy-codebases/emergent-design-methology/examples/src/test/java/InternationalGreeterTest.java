import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.Locale;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class InternationalGreeterTest {

	private final PrintStream standardOut = System.out;
	private ByteArrayOutputStream outputStreamCaptor;

	@BeforeEach
	public void setUp() {
		this.outputStreamCaptor = new ByteArrayOutputStream();
		System.setOut(new PrintStream(this.outputStreamCaptor));
	}

	@Test
	void testLocale() {
		// {@optional: issues referenced from implementing code as path relative to project root}
		// [REPRODUCES](/design/implementation/issues/issue-001-lack-of-internationalisation.md)
		Locale.setDefault(Locale.FRENCH);
		int exitCode = Greeter.run(new String[] { "Pierre" });
		String message = this.outputStreamCaptor.toString()
			.toLowerCase()
			.trim();
		assertTrue(exitCode == 0);
		assertTrue(message.contains("bonjour le monde"));
		assertTrue(message.contains("ca va, pierre?"));
	}

	@AfterEach
	public void tearDown() {
		String message = this.outputStreamCaptor.toString();
		System.setOut(this.standardOut);
		System.out.println(message);
	}
}
