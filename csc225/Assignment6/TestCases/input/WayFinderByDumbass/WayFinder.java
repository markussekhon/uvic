/* 
 * CSC 225 - Assignment 6
 * Name: Parsa Peikani
 * Student number: V00955805
 */

import java.io.*;
import java.util.*;


public class WayFinder {
	
	
    static int shortestPath(char[][] map) {
		// Variable for distance of shortest path between A and B.
		int distance = Integer.MAX_VALUE;

		// Keeping track of the length of the map
		int n = map.length;
		// Creating our variables for the row and column of A
		int ARow = 0, ACol = 0;
	
		// Find the coordinates of the starting cell 'A'
		for (int i = 0; i < n; i++) { // Have to create a double for loop to go through each index in the matrix to find 'A'
			for (int j = 0; j < n; j++) {
				if (map[i][j] == 'A') {
					ARow = i;
					ACol = j;
					break; // We break as soon as we find A so that we don't waste time :)
				}
			}
		}
		// Use BFS to find the shortest path
		Queue<int[]> queue = new LinkedList<>(); // Creating an Empty queue
		boolean[][] visited = new boolean[n][n]; // Creating an nxn matrix of boolean false to keep track of the visited nodes
		int[] start = {ARow, ACol, 0}; // creating our start node with row, col and distance: {row, col, distance}
		queue.offer(start); // Poping the start value from the queue
		visited[ARow][ACol] = true; // Making starting position of the visited matrix as true since we visited this node
	
		while (!queue.isEmpty()) { // Creating a while to perfom the BFS here 
			int[] curr = queue.poll(); // Poping from the queue
			int row = curr[0], col = curr[1], dist = curr[2]; // Getting the row, col and distance of the item that we just poped from the queue
	
			if (map[row][col] == 'B') { // Making sure first if the newly poped item is B or not
				return dist; // If it is B then we will return the dist (which we passed to it as the third paramter)
			}
	
			// Finding the neighboring cells by making the up, right, down, left direction
			int[][] moves = {{-1, 0}, {0, 1}, {1, 0}, {0, -1}}; // Creating the directions
				for (int[] move : moves) { // Creating a for loop to create the for possible newRol and newCol for the neighbors
					int nextRow = row + move[0]; // NewRow
					int nextCol = col + move[1]; // NewCol
	
				// Check if the neighboring cell is within the map bounds and is not blocked and is also not visited
				if (nextRow < 0 || nextRow >= n) { // If the node's row value is out of boundaries, we dont' want to do anything
					continue;
				}
				if (nextCol < 0 || nextCol >= n) { // If the node's column value is out of boundaries, we dont' want to do anything
					continue;
				}
				if (map[nextRow][nextCol] == '#') { // If the node that we are at is #, we don't want to do anything
					continue;
				}
				if (visited[nextRow][nextCol]) { // If the node is visited we dont' want to do anything
					continue;
				}
				
				// If we got this far, then the move is valid
				int[] next = {nextRow, nextCol, dist + 1};
				queue.offer(next);
				visited[nextRow][nextCol] = true;
				
			}
		}
		return distance; // If we reach here, it means we couldn't find a path from 'A' to 'B' meaning we return the distance itself
	}
	
    public static void main(String[] args) {
		Scanner s;
		if (args.length > 0){
			try{
				s = new Scanner(new File(args[0]));
			} catch(java.io.FileNotFoundException e){
				System.out.printf("Unable to open %s\n",args[0]);
				return;
			}
			System.out.printf("Reading input values from %s.\n",args[0]);
		}else{
			s = new Scanner(System.in);
			System.out.printf("Reading input values from stdin.\n");
		}
		
		int n = s.nextInt();
		char[][] map = new char[n][n];
		for (int i = 0; i < n; i++){
			String temp = s.next();
			for (int j = 0; j < n; j++){
				map[i][j] = temp.charAt(j);
			}
		}	
		
		int distance = shortestPath(map);
		
		if (distance < Integer.MAX_VALUE)
			System.out.println(distance);
		else
			System.out.println("IMPOSSIBLE");
    }
}