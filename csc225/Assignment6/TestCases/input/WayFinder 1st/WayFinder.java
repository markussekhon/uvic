/* 
 * CSC 225 - Assignment 6
 * Name: Markus Sekhon
 * Student number: V00000000
 */

import java.io.*;
import java.util.*;


public class WayFinder {
	
	
    static int shortestPath(char[][] map){
		
		// Variable for distance of shortest path between A and B.
		int distance = Integer.MAX_VALUE;

		int rowBound = map.length - 1;
		int colBound = map[0].length - 1;
		mapNode A = null;
		mapNode B = null ;
		mapNode cur = null;
		mapNode prev = null;
		mapNode anchC = null;
		mapNode anchR = null;

		for(int i = 0; i <= rowBound; i++){
			for(int j = 0; j <= colBound ;j++){
				cur = new mapNode(i,j,map[i][j]);

				if(cur.val == 'A') A = cur;

				else if(cur.val == 'B') B = cur;
				
				if(j!=0){
					cur.left = prev;
					prev.right = cur;
				}

				if(i!=0){
					cur.up = anchR;
					anchR.down = cur;
					anchR = anchR.right;
				}

				if(j==colBound) anchR = anchC;
				
				if(j==0) anchC = cur;
				
				prev = cur;

			}

		}

		return bfsSD(A, B);
        
    }

	static int bfsSD(mapNode A, mapNode B){
		LinkedList<mapNode> queue = new LinkedList<mapNode>();
		int index = 0;

		mapNode cur = null;

		A.exp = true;
		queue.add(A);

		while(queue.size() != 0){
			cur = queue.poll();

			if (cur.up != null && cur.up.val != '#' ) cur.adj.add(cur.up);
			if (cur.down != null && cur.down.val != '#') cur.adj.add(cur.down);
			if (cur.left != null && cur.left.val != '#') cur.adj.add(cur.left);
			if (cur.right != null && cur.right.val != '#') cur.adj.add(cur.right);

			Iterator<mapNode> i = cur.adj.listIterator(); 
	
			while(i.hasNext()){

				mapNode c = i.next();
				c.dep = cur.dep + 1;

				if (c.val==B.val) return c.dep;

				if(!c.exp){
					c.exp = true;
					queue.add(c);
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

class mapNode {
	int row ;
	int col ;
	int dep;
	char val;
	boolean exp;

	LinkedList<mapNode> adj;
	mapNode up;
	mapNode right;
	mapNode down;
	mapNode left;

	public mapNode(int i, int j, char val){
		this.row = i;
		this.col = j;
		this.val = val;
		this.exp = false;
		this.dep = 0;

		this.up = null;
		this.right = null;
		this.down = null;
		this.left = null;

		this.adj = new LinkedList<mapNode>();
		if (this.up != null ) this.adj.add(up);
		if (this.down != null ) this.adj.add(down);
		if (this.left != null ) this.adj.add(left);
		if (this.right != null ) this.adj.add(right);

		/*
		this.adj = new mapNode[4];
		this.adj[0] = this.up;
		this.adj[1] = this.down;
		this.adj[2] = this.left;
		this.adj[3] = this.right;
		*/
	}
}