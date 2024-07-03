/* 
 * CSC 225 - Assignment 3
 * Name: Markus Sekhon
 * Student number: V00000000
 */
 
/* 
 *Algorithm analysis goes here.
 *
 *T(n) = n, when n=1
 *T(n) = 3T(n/2) + n/2, otherwise
 *
 *Worse Case Analysis:
 *T(n) is O(n^log3) *log is base 2*
 */
 
 
import java.io.*;
import java.util.*;

public class ArrayMatch {
    
    static boolean match(int[] a, int[] b){
  
        
        /*
         *Your recusive solution goes here.   
         */

		/*
		 *Arrays.equals() is a built in java function doing O(n) work
		 *it will return boolean based on if the values at each index match between two given arrays
		 *it uses another function called mismatch, which returns the first index location that there is a mismatch
		 *mismatch is the function actually doing the work, which is O(n)
		 */
		if(Arrays.equals(a,b)){
			return true;
		}

		if(isEven(a.length)){
			ArrayPairs pair = splitArray(a,b);
			int[] a1 = pair.array1;
			int[] a2 = pair.array2;
			int[] b1 = pair.array3;
			int[] b2 = pair.array4;

			/*
			 *by only doing two recursive calls and storing the results
			 *and then filtering which 3rd recursive call to do based upon the results
			 *we can reduce the work from 6T(n/2) to 3T(n/2)
			 */
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

	static ArrayPairs splitArray(int[] a, int []b){
		int half = a.length/2;

		int[] a1 = new int[half];
		int[] a2 = new int[half];
		int[] b1 = new int[half];
		int[] b2 = new int[half];

		/*
		 * n/2 efficency by using the same half loop to make all 4 lists,
		 * improved on from using 4 seperate n/2 loops, so 2n work to n/2 work
		 */
		for(int i = 0; i < half ; i++){
			a1[i] = a[i];
			a2[i] = a[i+half];
			b1[i] = b[i];
			b2[i] = b[i+half];
		}

		return new ArrayPairs(a1, a2, b1, b2);
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

/*
 *ArrayPairs helps me return 4 lists from a function call
 */

class ArrayPairs {
    public int[] array1;
    public int[] array2;
	public int[] array3;
	public int[] array4;

    public ArrayPairs(int[] array1, int[] array2, int[] array3, int[] array4) {
        this.array1 = array1;
        this.array2 = array2;
		this.array3 = array3;
		this.array4 = array4;

    }
}