
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.util.StringTokenizer;

public class Main {

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(
                new InputStreamReader(System.in)
        );

        int n = Integer.parseInt(br.readLine());

        // dpA, dpB, dpC represent the maximum happiness
        // when the last activity is A, B, or C.
        int dpA = 0;
        int dpB = 0;
        int dpC = 0;

        for (int i = 0; i < n; i++) {

            StringTokenizer st = new StringTokenizer(br.readLine());

            int a = Integer.parseInt(st.nextToken());
            int b = Integer.parseInt(st.nextToken());
            int c = Integer.parseInt(st.nextToken());

            int newA = a + Math.max(dpB, dpC);
            int newB = b + Math.max(dpA, dpC);
            int newC = c + Math.max(dpA, dpB);

            dpA = newA;
            dpB = newB;
            dpC = newC;
        }

        System.out.println(Math.max(dpA, Math.max(dpB, dpC)));
    }
}