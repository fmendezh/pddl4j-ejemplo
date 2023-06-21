package fmendez;
import fr.uga.pddl4j.heuristics.state.StateHeuristic;
import fr.uga.pddl4j.planners.LogLevel;
import fr.uga.pddl4j.planners.statespace.FF;
public class Pddl4jExample {

    public static void main(String[] args) throws Exception {
        // Planificador
        FF planner = new FF();
        // Dominio
        planner.setDomain(args[0]);
        // Problema
        planner.setProblem(args[1]);
        // Log level
        planner.setLogLevel(LogLevel.DEBUG);
        // Heurístico
        planner.setHeuristic(StateHeuristic.Name.FAST_FORWARD);
        // Sets the weight of the heuristic
        planner.setHeuristicWeight(1.2);
        planner.solve();
    }
}
