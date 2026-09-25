import java.io.*;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.StringTokenizer;

public class Main {

    public static void main(String[] args) throws Exception {

        BufferedReader br = new BufferedReader(
                new InputStreamReader(System.in)
        );

        StringTokenizer st = new StringTokenizer(br.readLine());

        int n = Integer.parseInt(st.nextToken());
        int m = Integer.parseInt(st.nextToken());

        List<List<Integer>> adj = new ArrayList<>();

        for (int i = 0; i <= n; i++) {
            adj.add(new ArrayList<>());
        }

        for (int i = 0; i < m; i++) {
            st = new StringTokenizer(br.readLine());

            int a = Integer.parseInt(st.nextToken());
            int b = Integer.parseInt(st.nextToken());

            adj.get(a).add(b);
        }

        boolean[] multiple = new boolean[1];

        List<Integer> result = solve(adj, n, multiple);

        if (result.size() < n) {
            System.out.println("CONTRADICTION");
            return;
        }

        if (multiple[0]) {
            System.out.println("MULTIPLE");
            return;
        }

        System.out.println("UNIQUE");

        for (int rank : result) {
            System.out.print(rank + " ");
        }
    }

    static List<Integer> solve(
            List<List<Integer>> adj,
            int n,
            boolean[] multiple
    ) {

        List<Integer> res = new ArrayList<>();
        Queue<Integer> q = new ArrayDeque<>();

        int[] indegree = new int[n + 1];

        for (int i = 1; i <= n; i++) {
            for (int num : adj.get(i)) {
                indegree[num]++;
            }
        }

        for (int i = 1; i <= n; i++) {
            if (indegree[i] == 0) {
                q.offer(i);
            }
        }

        while (!q.isEmpty()) {

            if (q.size() > 1) {
                multiple[0] = true;
            }

            int node = q.poll();

            res.add(node);

            for (int next : adj.get(node)) {

                indegree[next]--;

                if (indegree[next] == 0) {
                    q.offer(next);
                }
            }
        }

        return res;
    }
}