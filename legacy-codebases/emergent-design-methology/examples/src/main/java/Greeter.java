import java.util.concurrent.Callable;

import org.apache.log4j.BasicConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Parameters;

/** The greet command. */
@Command(
		name = "greet",
		mixinStandardHelpOptions = true,
		description = "Greets a user",
		version = { "0.3.0" }
)
public class Greeter implements Callable<Integer> {

	static Logger log = LoggerFactory.getLogger(Greeter.class);
	// Links:
	// [IMPLEMENTS](/design/features/feat-001-prints-hello-world.md)
	// [IMPLEMENTS](/design/features/feat-002-greets-user-by-name.md)
	// {@required: features referenced from implementing code as path relative to
	// project root}

	@Parameters(
			index = "0",
			description = "The name of the person to greet",
			arity = "0..1"
	)
	private String name;

	private Greeter() {}

	/**
	 * Execute the hello world function
	 * 
	 * @param args command line arguments - see --help
	 */
	public static void main(String[] args) {
		BasicConfigurator.configure();
		log.trace("Excuting main function");
		int exitCode = run(args);
		log.trace("Exiting greeter with status: " + exitCode);
		System.exit(exitCode);
	}

	/**
	 * For testing
	 * 
	 * @param args command line arguments - see --help
	 * @return a status code (0 = success)
	 */
	protected static int run(String[] args) {
		return new CommandLine(new Greeter()).execute(args);
	}

	/**
	 * main execution engine of the greeter function.
	 *
	 * @return a status code (0 = success)
	 */
	@Override
	public Integer call() throws Exception {
		// EM: developer focussed documentation describing algorithm and control flow
		// EM: about 10-25% of code base expected to be comments describing implementation
		// {@required: ai added comments must be prefixed with EM: to confirm their provenance}
		// {and grepping a code base for //EM: will return useful developer comments}
		// {EM:TODO and EM:FIXME comments are supported}
		if (this.name == null) { this.name = "friend"; }
		log.trace("Greet.call with " + this.name);
		System.out.println("Hello world");
		System.out.println(String.format("How are you, %s?", this.name));
		return 0;
	}
}
