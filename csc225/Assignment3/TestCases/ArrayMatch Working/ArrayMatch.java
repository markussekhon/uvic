/* 
 * CSC 225 - Assignment 3
 * Name: Markus Sekhon
 * Student number: 
 */
 
/* 
Algorithm analysis goes here.
*/
 
 
import java.io.*;
import java.util.*;

public class ArrayMatch {
    
    static boolean match(int[] a, int[] b){
  
        
        /*
         Your recusive solution goes here.   
         */

		if(Arrays.equals(a,b)){
			return true;
		}

		if(isEven(a.length)){
			ArrayPair pairA = splitArray(a);
			ArrayPair pairB = splitArray(b);
			int[] a1 = pairA.array1;
			int[] a2 = pairA.array2;
			int[] b1 = pairB.array1;
			int[] b2 = pairB.array2;

			boolean c1 = match(a1, b1);
			boolean c2 = match(a2, b2);

			if (c1 & c2){
				return true;
			} else if(c1){
				return match(a1, b2);
			} else if (c2){
				return match(a2, b1);
			}

		}

		return false;

    }


	static boolean isEven(int n){
		return (n % 2 == 0);
	}

	static ArrayPair splitArray(int[] arr){
		int middle = arr.length/2;

		int[] a1 = Arrays.copyOfRange(arr, 0, middle);
		int[] a2 = Arrays.copyOfRange(arr, middle, arr.length);

		return new ArrayPair(a1, a2);
	}
    
    public static void main(String[] args) {
    /* Read input from STDIN. Print output to STDOUT. Your class should be named ArrayMatch. 

	You should be able to compile your program with the command:
   
		javac ArrayMatch.java
	
   	To conveniently test your algorithm, you can run your solution with any of the tester input files using:
   
		java ArrayMatch inputXX.txt
	
	where XX is 00, 01, ..., 13.
	*/

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
        int[] a = new int[n];
        int[] b = new int[n];
        
        for(int j = 0; j < n; j++){
            a[j] = s.nextInt();
        }
        
        for(int j = 0; j < n; j++){
            b[j] = s.nextInt();
        }
        
        System.out.println((match(a, b) ? "YES" : "NO"));
    }
}

class ArrayPair {
    public int[] array1;
    public int[] array2;

    public ArrayPair(int[] array1, int[] array2) {
        this.array1 = array1;
        this.array2 = array2;
    }
}