// number operations to convert str1 to str2
// First need to compile it in terminal: 
		//javac EditDist.java
// In order to run it in terminal: 
		//java EditDist str1 str2
class EditDist {
	static int min(int x, int y, int z)
	{
		if (x <= y && x <= z)
			return x;
		if (y <= x && y <= z)
			return y;
		else
			return z;
	}

	static int editDistDP(String str1, String str2, int m, int n)
	{
		int D[][] = new int[m + 1][n + 1];

		// base cases
		for (int i = 0; i <= m; i++)
		{
			D[i][0] = i;  // Min. operations = i
		}

		for (int j = 0; j <= n; j++)
		{
			D[0][j] = j;  // Min. operations = j
		}

		// fill D[][] in bottom up manner
		for (int i = 1; i <= m; i++) {
			for (int j = 1; j <= n; j++) {
				// If last characters are same, ignore last character
				if (str1.charAt(i - 1) == str2.charAt(j - 1))
					D[i][j] = D[i - 1][j - 1];

				// If last character are different, consider all
				// possibilities and find minimum
				else
					D[i][j] = 1 + min(D[i][j - 1],  // Insert
									D[i - 1][j],  // Remove
									D[i - 1][j - 1]);  // Replace
			}
		}

		return D[m][n];
	}

	public static void main(String args[])
	{

		String str1 = args[0];
		String str2 = args[1];
		System.out.println(editDistDP(
			str1, str2, str1.length(), str2.length()));
	}
} 

