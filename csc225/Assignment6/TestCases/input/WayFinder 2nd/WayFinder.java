/* 
 * CSC 225 - Assignment 6
 * Name: 
 * Student number:
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
				if(cur=='A') return recSP(map,i,j,'B');
				if(cur=='B') return recSP(map,i,j,'A');
			}
		}
		return Integer.MAX_VALUE;
    }

	static int recSP(char[][] map, int i, int j, char cmp){
		int b = map.length;
		int[][] shift = {{1,0},{-1,0},{0,1},{0,-1}}; //paired shifts {i.j}
		int[][] depth = new int[b][b]; //tracks depth as well as checks if visited
		depth[i][j] = 1; //staring depth from 1, will just return parent's depth to get accurate depth
		Queue<int[]> queue = new LinkedList<>(); //using list as pair to store i,j of nodes
		queue.add(new int[]{i,j});

		while(!queue.isEmpty()){
			int[] cur = queue.poll();

			//checking for up, down, right, left
			for(int[] offset: shift){
				//applying offsets
				i = cur[0] + offset[0];
				j = cur[1] + offset[1];

				//checking bounds, if traversable, and if visited
				if((i>=0)&&(j>=0)&&(i<b)&&(j<b)&&(map[i][j]!='#')&&(depth[i][j]==0)){
					if(map[i][j] == cmp) return depth[cur[0]][cur[1]];
					queue.add(new int[]{i,j});
					depth[i][j] = depth[cur[0]][cur[1]] + 1;
				}
			}
		}
		return Integer.MAX_VALUE;
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