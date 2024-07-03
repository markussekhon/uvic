/* 
 * CSC 225 - Assignment 6
 * Name: Markus Sekhon
 * Student number: V00000000
 */

import java.io.*;
import java.util.*;


public class WayFinder {
	
	
    static int shortestPath(char[][] map){
		int b = map.length;

		for(int i = 0;i<b;i++){
			for(int j = 0;j<b;j++){
				//starting and either A or B, finding the other
				char cur = map[i][j];
				if(cur=='A') return helperSP(map,i,j,'B');
				if(cur=='B') return helperSP(map,i,j,'A');
			}
		}
		return Integer.MAX_VALUE;
    }

	static int helperSP(char[][] map, int i, int j, char cmp){
		int b = map.length;

		int[][] shift = {{1,0},{-1,0},{0,1},{0,-1}};//paired shifts {i.j}

		int[][] depth = new int[b][b]; 				//tracks depth as well as checks if visited
		depth[i][j] = 1; 							//staring depth from 1, will just return parent's depth to get accurate depth

		Queue<int[]> queue = new LinkedList<>(); 	//using list as pair to store i,j of nodes
		queue.add(new int[]{i,j});

		//BFS with a queue
		while(!queue.isEmpty()){
			int[] cur = queue.poll();

			//checking for up, down, right, left
			//adds offset, then checks bounds
			//also checks if traversable character, and if not already visited
			for(int[] offset: shift){
				i = cur[0] + offset[0];
				j = cur[1] + offset[1];

				if((i>=0)&&(j>=0)&&(i<b)&&(j<b)&&(map[i][j]!='#')&&(depth[i][j]==0)){
					if(map[i][j] == cmp) return depth[cur[0]][cur[1]];	//return parents depth as it that tracks children's depth
					queue.add(new int[]{i,j});							//otherwise add to queue	
					depth[i][j] = depth[cur[0]][cur[1]] + 1;			//new node's depth
				}
			}
		}

		return Integer.MAX_VALUE;	//if never found A or B, return impossible
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