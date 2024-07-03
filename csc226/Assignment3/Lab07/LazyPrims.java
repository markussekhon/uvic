
// CSC226 - Summer 2023 - Lazy Prim's starter code
import edu.princeton.cs.algs4.*;
/********************************************************************************************************************
 * Compilation: javac -cp ./algs4.jar LazyPrims.java
 * Execution: java -cp .;./algs4.jar LazyPrims small.txt
 * 
 * Jar download:    https://algs4.cs.princeton.edu/code/algs4.jar
 * 
 * Data structure
 * documentation:   https://algs4.cs.princeton.edu/code/ - includes .jar installation options
 * 
 * 
 * Test files:      https://algs4.cs.princeton.edu/43mst/tinyEWG.txt
 *                  https://algs4.cs.princeton.edu/43mst/mediumEWG.txt
 *                  https://algs4.cs.princeton.edu/43mst/largeEWG.txt
 * 
 * 
 * Task: Compute a minimum spanning forest using a lazy version of Prim's
 * algorithm, using the EdgeWeightedGraph, Edge, MinPQ, and Queue data structures
 * implemented at edu.princeton.cs.algs4.
 * 
 * Overview: Prim's algorithm is a greedy algorithm which finds the MST of a 
 * graph G(V,E). Prim's grows the MST by repeatedly adding the lowest weight edge that is
 * currently incident to the growing tree, until the number of nodes in the MST = |V-1|.
 * 
 * Details: This implementation requires the use of a PQ to keep track of the
 * minimum weight incident crossing edge between your MST and the rest of the graph. 
 * Additionally, it is required that the consistency of the edges in the PQ be checked
 * in a "lazy" manner, by deferring testing to when an edge is removed from the PQ, as 
 * discussed during the lab.
 *  
 ********************************************************************************************************************/
public class LazyPrims {
    private static final double FLOATING_POINT_EPSILON = 1e-12;
    private double weight; // total weight of MST
    private Queue<Edge> mst; // edges in the MST
    private boolean[] marked; // marked[v] = true iff v in MST
    private MinPQ<Edge> pq; // edges with one endpoint in tree

    /**
     * Compute a minimum spanning tree (or forest) of an edge-weighted graph.
     * 
     * @param G the edge-weighted graph
     */
    public LazyPrims(EdgeWeightedGraph G) {
        // initialize data structures
        mst = new Queue<Edge>();
        pq = new MinPQ<Edge>();
        marked = new boolean[G.V()];

        // run lazy_prim until each component is covered
        for (int v = 0; v < G.V(); v++)
            if (!marked[v])
                lazy_prim(G, v);

        // test your MST / forest
        assert _check(G);
    }

    public Iterable<Edge> edges() {
        return mst;
    }

    public double weight() {
        return weight;
    }

    // run lazy variant of Prim's algorithm
    private void lazy_prim(EdgeWeightedGraph G, int v) {
        // add first edges onto PQ

        // iterate until MST has correct number of edges
        // while(){

        // select smallest edge e on PQ

        // ensure that e has an endpoint in your MST

        // lazily confirm whether or not e is in fact a crossedge

        // if so, add e to your MST. if not, move on

        // increase the MST's weight

        // continue growing the tree using scan

        // }

    }

    // helper function to add incident edges to v onto PQ
    private void scan(EdgeWeightedGraph G, int v) {

        marked[v] = true;
        
        for (Edge e : G.adj(v)) { 
            if (!marked[e.other(v)]) pq.insert(e);

        }
    }

    // test your MST (DO NOT NEED TO CHANGE THIS CODE)
    private boolean _check(EdgeWeightedGraph G) {

        // check weight
        double totalWeight = 0.0;
        for (Edge e : edges()) {
            totalWeight += e.weight();
        }
        if (Math.abs(totalWeight - weight()) > FLOATING_POINT_EPSILON) {
            System.err.printf("Weight of edges does not equal weight(): %f vs. %f\n", totalWeight, weight());
            return false;
        }

        // check that it is acyclic
        UF uf = new UF(G.V());
        for (Edge e : edges()) {
            int v = e.either(), w = e.other(v);
            if (uf.find(v) == uf.find(w)) {
                System.err.println("Not a forest");
                return false;
            }
            uf.union(v, w);
        }

        // check that it is a spanning forest
        for (Edge e : G.edges()) {
            int v = e.either(), w = e.other(v);
            if (uf.find(v) != uf.find(w)) {
                System.err.println("Not a spanning forest");
                return false;
            }
        }

        // check that it is a minimal spanning forest (cut optimality conditions)
        for (Edge e : edges()) {

            // all edges in MST except e
            uf = new UF(G.V());
            for (Edge f : mst) {
                int x = f.either(), y = f.other(x);
                if (f != e)
                    uf.union(x, y);
            }

            // check that e is min weight edge in crossing cut
            for (Edge f : G.edges()) {
                int x = f.either(), y = f.other(x);
                if (uf.find(x) != uf.find(y)) {
                    if (f.weight() < e.weight()) {
                        System.err.println("Edge " + f + " violates cut optimality conditions");
                        return false;
                    }
                }
            }

        }

        return true;
    }

    /**
     * Unit tests the {@code LazyPrim} data type.
     *
     * @param args the command-line arguments - corresponds to test file
     */
    public static void main(String[] args) {
        In in = new In(args[0]);
        EdgeWeightedGraph G = new EdgeWeightedGraph(in);
        LazyPrims mst = new LazyPrims(G);
        for (Edge e : mst.edges()) {
            StdOut.println(e);
        }
        StdOut.printf("%.5f\n", mst.weight());
    }
}

// This codebase is based on Robert Sedgewick and Kevin Wayne's work at https://algs4.cs.princeton.edu/