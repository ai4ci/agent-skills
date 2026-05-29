import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvFileSource;

class GreeterTest {

	private final PrintStream standardOut = System.out;
	private ByteArrayOutputStream outputStreamCaptor;

	@BeforeEach
	public void setUp() {
		this.outputStreamCaptor = new ByteArrayOutputStream();
		System.setOut(new PrintStream(this.outputStreamCaptor));
	}

	@CsvFileSource(
			resources = "/test-data-001-mvp.csv",
			numLinesToSkip = 1,
			nullValues = "NA"
	) @ParameterizedTest
	void testGreeting(String name, String result) {

		// {@optional: test-scripts referenced from implementing code as path relative to project root}
		// [IMPLEMENTS](/design/test-scripts/test-001-script-for-mvp.md)

		String[] args = name == null ? new String[0] : new String[] { name };
		int exitCode = Greeter.run(args);

		assertTrue(exitCode == 0);
		assertEquals(
			result,
			this.outputStreamCaptor.toString()
				.trim()
		);
	}

	@Test
	void testHelp() {

		// {@optional: test-scripts referenced from implementing code as path relative to project root}
		// [IMPLEMENTS](/design/external-interfaces/interface-001-mvp-ui.md)

		int exitCode = Greeter.run(new String[] { "--help" });
		String message = this.outputStreamCaptor.toString()
			.toLowerCase()
			.trim();
		assertTrue(exitCode == 0);
		assertTrue(message.contains("the name of the person to greet"));
		assertTrue(message.contains("print version information and exit"));
	}

	@AfterEach
	public void tearDown() {
		String message = this.outputStreamCaptor.toString();
		System.setOut(this.standardOut);
		System.out.println(message);
	}
}
