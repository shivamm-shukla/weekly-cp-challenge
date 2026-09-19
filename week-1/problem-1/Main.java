import java.io.*;

public class Main {
    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(
            new InputStreamReader(System.in)
        );

        int n = Integer.parseInt(br.readLine());

        int[] h = new int[n];
        String[] input = br.readLine().split(" ");

        for (int i = 0; i < n; i++) {
            h[i] = Integer.parseInt(input[i]);
        }

        int[] dp = new int[n];

        dp[0] = 0;

        for (int i = 1; i < n; i++) {
            int oneStep = dp[i - 1]
                + Math.abs(h[i] - h[i - 1]);

            int twoStep = Integer.MAX_VALUE;

            if (i >= 2) {
                twoStep = dp[i - 2]
                    + Math.abs(h[i] - h[i - 2]);
            }

            dp[i] = Math.min(oneStep, twoStep);
        }

        System.out.println(dp[n - 1]);
    }
}