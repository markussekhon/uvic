//226 Lab 5 June 2023
// V00000000
// Markus Sekhon
//This java file contains a template for a bipartite checker.
//Your task is to complete the code, and test your solution using the testing harness in main().
import java.util.*;

public class BipartiteChecker {
    /**
     * Checks whether or not a graph is bipartite.
     * This function should use the fact that a graph is bipartite iff it contains no odd cycles, 
     * and that odd cycles can be detected by investigating cross edges in BFS. 
     * No other solutions will be accepted.
     * Run time requirement: O(v+e)
     * Space requirement: O(v)
     * @param graph the graph G, represented as an adjacency list
     * @return whether G is bipartite
     */
    public static boolean isBipartite(List<List<Integer>> graph) {
        int sizeOfGraph = graph.size();

        // handle empty edge case
        if (sizeOfGraph ==0) return true;

        int[] colours = new int[sizeOfGraph];

        for(int i=0;i<colours.length;i++){
            colours[i] = -1;
        } //-1 means not visited

        for(int s=0;s<sizeOfGraph;s++){
            if (colours[s]==-1){
                Queue<Integer> queue = new LinkedList<>();
                queue.add(s);
                colours[s]=0;

                while (!queue.isEmpty()){
                    int current = queue.poll();

                    for(int adjacent:graph.get(current)){
                        if(colours[adjacent]==colours[current]){
                            return false;
                        }//if same colour from previous setting
                        else if(colours[adjacent]==-1){
                            colours[adjacent] = 1 - colours[current];
                            queue.add(adjacent);
                        }//if not visited
                        //System.out.println("test");
                    }
                }
            }
        }
        return true; // Graph is bipartite
    }

    public static void main(String[] args) {
        // Empty graph - T
        List<List<Integer>> graph = new ArrayList<>();
        
        boolean isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The empty graph is bipartite.");
        } else {
            System.out.println("The empty graph is not bipartite.");
        }

        // Single vertex - T
        graph = new ArrayList<>();
        graph.add(Arrays.asList());

        isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The single vertex graph is bipartite.");
        } else {
            System.out.println("The single vertex is not bipartite.");
        }
        
        // Line graph - T
        graph = new ArrayList<>();
        graph.add(Arrays.asList(1));
        graph.add(Arrays.asList(0,2));
        graph.add(Arrays.asList(1));

        isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The line graph is bipartite.");
        } else {
            System.out.println("The line graph is not bipartite.");
        }

        // Square graph - T
        graph = new ArrayList<>();
        graph.add(Arrays.asList(1, 3));
        graph.add(Arrays.asList(0, 2));
        graph.add(Arrays.asList(1, 3));
        graph.add(Arrays.asList(0, 2));

        isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The square graph is bipartite.");
        } else {
            System.out.println("The square graph is not bipartite.");
        }

        // Connected bipartite graph - T
        graph = new ArrayList<>();
        graph.add(Arrays.asList(3, 4, 5, 6));
        graph.add(Arrays.asList(3, 4, 5, 6));
        graph.add(Arrays.asList(3, 4, 5, 6));
        graph.add(Arrays.asList(0, 1, 2));
        graph.add(Arrays.asList(0, 1, 2));
        graph.add(Arrays.asList(0, 1, 2));
        graph.add(Arrays.asList(0, 1, 2));

        isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The fully connected graph is bipartite.");
        } else {
            System.out.println("The fully connected graph is not bipartite.");
        }

        // Pentagon graph - F
        graph = new ArrayList<>();
        graph.add(Arrays.asList(1,4));
        graph.add(Arrays.asList(0,2));
        graph.add(Arrays.asList(1,3));
        graph.add(Arrays.asList(2,4));
        graph.add(Arrays.asList(0,3));

        isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The pentagon graph is bipartite.");
        } else {
            System.out.println("The pentagon graph is not bipartite.");
        }
        
        // Petersen graph - F
        graph = new ArrayList<>();
        graph.add(Arrays.asList(1, 2, 3));
        graph.add(Arrays.asList(0, 4, 5));
        graph.add(Arrays.asList(0, 4, 6));
        graph.add(Arrays.asList(0, 6, 7));
        graph.add(Arrays.asList(1, 2, 8));
        graph.add(Arrays.asList(1, 7, 8));
        graph.add(Arrays.asList(2, 3, 9));
        graph.add(Arrays.asList(3, 5, 9));
        graph.add(Arrays.asList(4, 5, 9));
        graph.add(Arrays.asList(6, 7, 8));

        isBipartite = isBipartite(graph);
        if (isBipartite) {
            System.out.println("The Petersen graph is bipartite.");
        } else {
            System.out.println("The Petersen graph is not bipartite.");
        }

    }
}